require 'active_record'

class Carto::Layer < ActiveRecord::Base
  serialize :options, JSON

  has_and_belongs_to_many :maps, class_name: Carto::Map

  has_many :layers_user
  has_many :users, :through => :layers_user

  has_many :children, class_name: Carto::Layer, foreign_key: :parent_id

  def affected_tables
    (tables_from_query_option + tables_from_table_name_option).compact.uniq
  end

  def legend
    @legend ||= options['legend']
  end

  private

  def tables_from_query_option
    ::Table.get_all_by_names(affected_table_names, user)
  end

  # replaces special mapnik tokens in a query like !bbox! !pixel_width! !pixel_height! with dummy values
  def replace_mapnik_tokens(query)
    # zoom 0 resolution
    res = '156543.03515625';
    # full webmercator extent
    ext = 'ST_MakeEnvelope(-20037508.5,-20037508.5,20037508.5,20037508.5,3857)';
    query.sub('!bbox!', ext)
       .sub('!pixel_width!', res)
       .sub('!pixel_height!', res);
  end

  def affected_table_names
    return [] unless query.present?

    # TODO: This is the same that CartoDB::SqlParser().affected_tables does. Maybe remove that class?
    query_tables = user.in_database.execute("SELECT CDB_QueryTables(#{user.in_database.quote(replace_mapnik_tokens(query))})").first
    query_tables['cdb_querytables'].split(',').map do |table_name|
      t = table_name.gsub!(/[\{\}]/, '')
      (t.blank? ? nil : t)
    end.compact.uniq
  end

  def tables_from_table_name_option
    return[] if options.empty?
    ::Table.get_all_by_names([options.symbolize_keys[:table_name]], user)
  end

  def query
    options.symbolize_keys[:query]
  end

  def user
    @user ||= maps.first.user
  end
end
