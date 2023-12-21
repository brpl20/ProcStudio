# frozen_string_literal: true

module Api
  module V1
    class ProfileAdminsController < BackofficeController
      before_action :retrieve_profile_admin, only: %i[update show]

      def index
        profile_admins = ProfileAdmin.all
        render json: ProfileAdminSerializer.new(
          profile_admins,
          meta: {
            total_count: profile_admins.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def create
        profile_admin = ProfileAdmin.new(profile_admins_params)
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
          @profile_admin
        ), status: :ok
      end

      private

      def profile_admins_params
        params.require(:profile_admin).permit(
          :role, :status, :admin_id, :office_id, :name, :last_name, :gender, :oab,
          :rg, :cpf, :nationality, :civil_status, :birth, :mother_name,
          admin_attributes: %i[id email password password_confirmation],
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
    end
  end
end
