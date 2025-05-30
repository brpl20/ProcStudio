# frozen_string_literal: true

module Api
  module V1
    class AdminsController < BackofficeController
      before_action :retrieve_admin, only: %i[update show]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        admins = Admin.includes(:profile_admin).all

        filter_by_deleted_params.each do |key, value|
          next unless value.present?

          admins = admins.public_send("filter_by_#{key}", value.strip)
        end

        render json: AdminSerializer.new(
          admins,
          meta: {
            total_count: admins.offset(nil).limit(nil).count
          },
          include: %i[profile_admin]
        ), status: :ok
      end

      def create
        admin = Admin.new(admins_params)
        if admin.save
          render json: AdminSerializer.new(
            admin
          ), status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: admin.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def update
        if @admin.update(admins_params)
          render json: AdminSerializer.new(
            @admin
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @admin.errors.full_messages }] }
          )
        end
      end

      def show
        render json: AdminSerializer.new(
          @admin,
          include: %i[profile_admin]
        ), status: :ok
      end

      def destroy
        if destroy_fully?
          Admin.with_deleted.find(params[:id]).destroy_fully!
        else
          retrieve_admin
          @admin.destroy
        end
      end

      def restore
        admin = Admin.with_deleted.find(params[:id])
        if admin.recover
          render json: AdminSerializer.new(
            admin
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: admin.errors.full_messages }] }
          )
        end
      end

      private

      def admins_params
        params.require(:admin).permit(
          :email, :password, :password_confirmation, :status,
          profile_admin_attributes: %i[
            role status admin_id office_id name last_name gender oab
            rg cpf nationality civil_status birth mother_name
          ]
        )
      end

      def retrieve_admin
        @admin = Admin.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :admin], "#{action_name}?".to_sym
      end
    end
  end
end
