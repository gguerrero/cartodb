# encoding: utf-8

require_relative './group_presenter'

module Carto
  module Api
    class OrganizationGroupsController < ::Api::ApplicationController
      include OrganizationGroupsHelper

      ssl_required :index, :show, :create, :update, :destroy

      before_filter :load_organization
      before_filter :owners_only
      before_filter :load_group, only: [:show, :update, :destroy]

      def index
        presentations = Carto::Group.where(organization_id: @organization.id).each do |group|
          Carto::Api::GroupPresenter.new(group).to_poro
        end

        render_jsonp presentations, 200
      end

      def show
        presentation = Carto::Api::GroupPresenter.full(@group).to_poro

        render_jsonp presentation, 200
      end

      def create
        render_jsonp('No create params provided', 410) && return if create_params.empty?

        group = Carto::Group.create_group_with_extension(@organization, create_params[:display_name])

        presentation = Carto::Api::GroupPresenter.full(group).to_poro
        render_jsonp(presentation, 200)

      rescue CartoDB::ModelAlreadyExistsError => e
        CartoDB::Logger.debug(message: 'Group already exists', exception: e, params: params)
        render json: { errors: ["A group with that name already exists"] }, status: 409
      rescue => e
        CartoDB.notify_exception(e, grop: group.inspect)

        render_jsonp('An error has ocurred. Please contact support', 500)
      end

      def update
        # Maybe can add users on this actions through a 'users_params' method.
        render_jsonp 'Action not permitted yet...', 401
      end

      def destroy
        render_jsonp 'Action not permitted yet...', 401
      end

      private

      COMMON_MUTABLE_ATTRIBUTES = [
        :display_name
      ].freeze

      # TODO: Use native strong params when in Rails 4+
      def create_params
        @create_params ||=
          permit(COMMON_MUTABLE_ATTRIBUTES)
      end

      # TODO: Use native strong params when in Rails 4+
      def update_params
        @update_params ||= permit(COMMON_MUTABLE_ATTRIBUTES)
      end
    end
  end
end
