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
        ActiveRecord::Base.transaction do
          # Create IndividualEntity first with personal and contact data
          individual_entity = IndividualEntity.new(individual_entity_params)
          
          unless individual_entity.save
            return render(
              status: :bad_request,
              json: { errors: [{ code: individual_entity.errors.full_messages }] }
            )
          end
          
          # Create ProfileAdmin linked to IndividualEntity
          profile_admin = ProfileAdmin.new(profile_admin_only_params)
          profile_admin.admin = current_admin
          profile_admin.individual_entity = individual_entity
          
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
        end
      rescue StandardError => e
        render(
          status: :bad_request,
          json: { errors: [{ code: e.message }] }
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
          individual_entity_attributes: [
            :name, :last_name, :cpf, :rg, :birth, :gender, :nationality,
            :civil_status, :capacity, :mother_name, :profession, :number_benefit,
            contact_addresses_attributes: %i[id street number neighborhood city state zip_code complement address_type is_primary _destroy],
            contact_phones_attributes: %i[id number phone_type is_whatsapp is_primary _destroy],
            contact_emails_attributes: %i[id address email_type is_verified is_primary _destroy],
            contact_bank_accounts_attributes: %i[id bank_name bank_code agency account_number account_type operation pix_key _destroy]
          ]
        )
      end

      def individual_entity_params
        profile_params = params.require(:profile_admin)
        
        # Build entity params hash properly
        entity_params = {
          name: profile_params[:name],
          last_name: profile_params[:last_name],
          cpf: profile_params[:cpf],
          rg: profile_params[:rg],
          birth: profile_params[:birth],
          gender: convert_gender(profile_params[:gender]),
          nationality: profile_params[:nationality],
          civil_status: profile_params[:civil_status],
          mother_name: profile_params[:mother_name],
          capacity: 'able'
        }
        
        # Map address data to contact_addresses_attributes
        if profile_params[:addresses_attributes].present?
          entity_params[:contact_addresses_attributes] = profile_params[:addresses_attributes].map do |addr|
            addr_hash = addr.to_unsafe_h
            # Map description to complement for ContactAddress model
            if addr_hash['description']
              addr_hash['complement'] = addr_hash.delete('description')
            end
            addr_hash
          end
        end
        
        entity_params.compact
      end

      def profile_admin_only_params
        params.require(:profile_admin).permit(:role, :status, :office_id, :oab, :origin)
      end

      def convert_gender(gender_value)
        case gender_value&.to_s&.downcase
        when 'male'
          'M'
        when 'female'
          'F'
        when 'other'
          'O'
        else
          gender_value # Retorna o valor original se não reconhecer
        end
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
