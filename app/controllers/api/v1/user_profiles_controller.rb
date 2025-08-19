# frozen_string_literal: true

module Api
  module V1
    class UserProfilesController < BackofficeController
      before_action :retrieve_user_profile, only: [:update, :show]
      before_action :retrieve_deleted_user_profile, only: [:restore]
      before_action :perform_authorization

      after_action :verify_authorized

      def index
        user_profiles = UserProfile.all

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          user_profiles = user_profiles.public_send("filter_by_#{key}", value.strip)
        end

        render json: UserProfileSerializer.new(
          user_profiles,
          meta: {
            total_count: user_profiles.offset(nil).limit(nil).count
          }
        ), status: :ok
      end

      def show
        render json: UserProfileSerializer.new(
          @user_profile,
          params: { action: 'show' }
        ), status: :ok
      end

      def create
        user_profile = UserProfile.new(user_profiles_params)
        if user_profile.save
          render json: UserProfileSerializer.new(
            user_profile,
            params: { action: 'show' }
          ), status: :created
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: user_profile.errors.full_messages }] }
          )
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e }] }
        )
      end

      def update
        if @user_profile.update(user_profiles_params)
          render json: UserProfileSerializer.new(
            @user_profile
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @user_profile.errors.full_messages }] }
          )
        end
      end

      def destroy
        if destroy_fully?
          UserProfile.with_deleted.find(params[:id]).destroy_fully!
        else
          retrieve_user_profile
          @user_profile.destroy
        end
      end

      def restore
        if @user_profile.recover
          render json: UserProfileSerializer.new(
            @user_profile
          ), status: :ok
        else
          render(
            status: :bad_request,
            json: { errors: [{ code: @user_profile.errors.full_messages }] }
          )
        end
      end

      private

      def user_profiles_params
        params.expect(
          user_profile: [:role, :status, :user_id, :office_id, :name, :last_name, :gender, :oab,
                         :rg, :cpf, :nationality, :civil_status, :birth, :mother_name, :origin,
                         { user_attributes: [:id, :email, :access_email, :password, :password_confirmation],
                           office_attributes: [:name, :cnpj],
                           addresses_attributes: [:id, :description, :zip_code, :street, :number, :neighborhood, :city, :state],
                           bank_accounts_attributes: [:id, :bank_name, :type_account, :agency, :account, :operation, :pix],
                           phones_attributes: [:id, :phone_number],
                           emails_attributes: [:id, :email] }]
        )
      end

      def retrieve_user_profile
        @user_profile = UserProfile.find(params[:id])
      end

      def retrieve_deleted_user_profile
        @user_profile = UserProfile.with_deleted.find(params[:id])
      end

      def perform_authorization
        authorize [:admin, :work], :"#{action_name}?"
      end
    end
  end
end
