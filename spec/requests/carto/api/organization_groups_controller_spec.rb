# encoding: utf-8

require_relative '../../../spec_helper'
require_relative '../../../../app/controllers/carto/api/database_groups_controller'
require_relative '.././../../factories/visualization_creation_helpers'
# require_relative '../../../../app/controllers/carto/api/organizations_controller'

describe Carto::Api::OrganizationUsersController do
  include_context 'organization with users helper'
  include Rack::Test::Methods
  include Warden::Test::Helpers

  describe('group list') do
    pending
  end

  describe('group show') do
    pending
  end

  describe('group creation') do
    it 'returns 401 for non authorized calls' do
      post api_v2_organization_groups_create_url(id_or_name: @carto_organization.name)
      last_response.status.should == 401
    end

    it 'returns 401 for non authorized users' do
      login(@org_user_1)

      post api_v2_organization_groups_create_url(id_or_name: @carto_organization.name)
      last_response.status.should == 401
    end

    it 'accepts org owners' do
      login(@carto_organization.owner)

      post api_v2_organization_groups_create_url(id_or_name: @carto_organization.name)
      last_response.status.should == 410
    end

    it "correctly creates a group" do
      display_name = 'a new group'
      name = 'a new group'

      # Replacement for extension interaction
      fake_database_role = 'fake_database_role'
      fake_group_creation = Carto::Group.new_instance(@carto_organization.database_name, name, fake_database_role)
      fake_group_creation.save
      Carto::Group.expects(:create_group_extension_query).with(anything, name).returns(fake_group_creation)

      params = { display_name: display_name }
      post api_v2_organization_groups_create_url(user_domain: @org_user_owner.username, id_or_name: @carto_organization.name, api_key: @org_user_owner.api_key), params

      last_response.status.should eq 200

      # Also check database data because Group changes something after extension interaction
      last_response_body = JSON.parse(last_response.body)
      new_group = Carto::Group.find(last_response_body['id'])
      new_group.organization_id.should == @carto_organization.id
      new_group.name.should == name
      new_group.display_name.should == display_name
      new_group.database_role.should_not be_nil
      end
  end

  describe('group update') do
    pending
  end

  describe('group destroy') do
    pending
  end
end
