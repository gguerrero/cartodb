 # encoding: UTF-8
require_dependency 'carto/uuidhelper'

module OrganizationGroupsHelper
  include Carto::UUIDHelper

  def load_organization
    id_or_name = params[:id_or_name]

    @organization = ::Organization.where(is_uuid?(id_or_name) ? { id: id_or_name } : { name: id_or_name }).first

    unless @organization
      render_jsonp({}, 401) # Not giving clues to guessers via 404
      return false
    end
  end

  def owners_only
    unless current_viewer_is_owner?
      render_jsonp({}, 401)
      return false
    end
  end

  def load_group
    @group = Carto::Group.where(name: params[:g_groupname], organization_id: @organization.id).first

    if @group.nil?
      render_jsonp("No group with groupname '#{params[:g_groupname]}' in '#{@organization.name}'", 404)
      return false
    end
  end

  def current_viewer_is_owner?
    current_viewer.id == @organization.owner.id
  end

  # To help with strong params until Rails 4+
  def permit(*permitted)
    hardened_params = params.dup

    hardened_params.keep_if { |k, _v| permitted.flatten.include?(k.to_sym) }

    hardened_params.symbolize_keys
  end
end
