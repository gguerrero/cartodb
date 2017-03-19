# encoding: utf-8

require_relative '../../../spec_helper'
require_relative '../../../../app/controllers/carto/api/database_groups_controller'
require_relative '.././../../factories/visualization_creation_helpers'
# require_relative '../../../../app/controllers/carto/api/organizations_controller'

describe Carto::Api::OrganizationUsersController do
  include_context 'organization with users helper'
  include Rack::Test::Methods
  include Warden::Test::Helpers


  before(:all) do
    @carto_org_user_1 = Carto::User.find(@org_user_1.id)
    @org_user_1_json = { "id" => @org_user_1.id,
                         "username" => @org_user_1.username,
                         "avatar_url" => @org_user_1.avatar_url,
                         "base_url" => @org_user_1.public_url,
                         "viewer" => false
                       }
    @carto_org_user_2 = Carto::User.find(@org_user_2.id)

    @group_1 = FactoryGirl.create(:random_group, display_name: 'g_1', organization: @carto_organization)
    @group_1_json = { 'id' => @group_1.id, 'organization_id' => @group_1.organization_id, 'name' => @group_1.name, 'display_name' => @group_1.display_name }
    @group_2 = FactoryGirl.create(:random_group, display_name: 'g_2', organization: @carto_organization)
    @group_2_json = { 'id' => @group_2.id, 'organization_id' => @group_2.organization_id, 'name' => @group_2.name, 'display_name' => @group_2.display_name }
    @group_3 = FactoryGirl.create(:random_group, display_name: 'g_3', organization: @carto_organization)
    @group_3_json = { 'id' => @group_3.id, 'organization_id' => @group_3.organization_id, 'name' => @group_3.name, 'display_name' => @group_3.display_name }
    @headers = {'CONTENT_TYPE'  => 'application/json', :format => "json" }
  end

  after(:all) do
    @group_1.destroy
    @group_2.destroy
    @group_3.destroy
  end

  before(:each) do
    @carto_organization.reload
  end

  describe('group list') do
  end

  describe('group show') do
  end

  describe('group creation') do
    it 'returns 401 for non authorized calls' do
      post api_v2_organization_groups_create_url(id_or_name: @carto_organization.name)
      last_response.status.should == 401
    end

    it 'returns 401 for non authorized users' do
      login(@carto_org_user_1)

      post api_v2_organization_groups_create_url(id_or_name: @carto_organization.name)
      last_response.status.should == 401
    end

    it 'accepts org owners' do
      login(@carto_organization.owner)

      post api_v2_organization_groups_create_url(id_or_name: @carto_organization.name)
      last_response.status.should == 410
    end
  end

  describe('group update')
  describe('group destroy')
end
