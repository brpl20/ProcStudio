# frozen_string_literal: true

module Api
  module V1
    class ProfileAdminsController < BackofficeController
      before_action :retrieve_profile_admin, only: %i[update show]
      before_action :retrieve_deleted_profile_admin, only: %i[restore]
      before_action :perform_authorization
      skip_before_action :perform_authorization, only: %i[me create]

      after_action :verify_authorized
      skip_after_action :verify_authorized, only: %i[me create]

      def me
        profile_admin = current_admin.profile_admin
        
        if profile_admin
          render json: ProfileAdminSerializer.new(profile_admin), status: :ok
        else
          render json: { error: 'Profile not found' }, status: :not_found
        end
      end

      def index
        profile_admins = current_team ? ProfileAdmin.by_team(current_team) : ProfileAdmin.all

        filter_by_deleted_params.each do |key, value|
          next unless value.present?

          profile_admins = profile_admins.public_send("filter_by_#{key}", value.strip)
        end

        render json: ProfileAdminSerializer.new(
          profile_admins,
          meta: {
            total_count: profile_admins.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        profile_admin = ProfileAdmin.new(profile_admins_params)
        profile_admin.admin = current_admin
        
        if profile_admin.save
          render json: ProfileAdminSerializer.new(
            profile_admin,
            params: { action: 'show' }
          ), status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: profile_admin.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def update
        if @profile_admin.update(profile_admins_params)
          render json: ProfileAdminSerializer.new(
            @profile_admin
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @profile_admin.errors.full_messages }] }
          )
        end
      end

      def show
        render json: ProfileAdminSerializer.new(
          @profile_admin,
          params: { action: 'show' }
        ), status: :ok
      end

      def destroy
        if destroy_fully?
          ProfileAdmin.with_deleted.find(params[:id]).destroy_fully!
        else
          retrieve_profile_admin
          @profile_admin.destroy
        end
      end

      def restore
        if @profile_admin.recover
          render json: ProfileAdminSerializer.new(
            @profile_admin
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @profile_admin.errors.full_messages }] }
          )
        end
      end

      private

      def profile_admins_params
        params.require(:profile_admin).permit(
          :role, :status, :admin_id, :office_id, :name, :last_name, :gender, :oab,
          :rg, :cpf, :nationality, :civil_status, :birth, :mother_name, :origin,
          admin_attributes: %i[id email access_email password password_confirmation],
          office_attributes: %i[name cnpj],
          addresses_attributes: %i[id description zip_code street number neighborhood city state],
          bank_accounts_attributes: %i[id bank_name type_account agency account operation pix],
          phones_attributes: %i[id phone_number],
          emails_attributes: %i[id email]
        )
      end

      def retrieve_profile_admin
        @profile_admin = ProfileAdmin.find(params[:id])
      end

      def retrieve_deleted_profile_admin
        @profile_admin = ProfileAdmin.with_deleted.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :work], "#{action_name}?".to_sym
      end
    end
  end
end
