# frozen_string_literal: true

module Api
  module V1
    class OfficesController < BackofficeController
      before_action :retrieve_office, only: [:show, :update]
      before_action :retrieve_deleted_office, only: [:restore]
      before_action :perform_authorization, except: [:with_lawyers]

      after_action :verify_authorized

      def index
        @offices = OfficeFilter.retrieve_offices(current_team)

        filter_by_deleted_params.each do |key, value|
          next if value.blank?

          @offices = @offices.public_send("filter_by_#{key}", value.strip)
        end

        serialized = OfficeSerializer.new(
          @offices,
          meta: {
            total_count: @offices.offset(nil).limit(nil).count
          }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Escritórios listados com sucesso',
          data: serialized[:data],
          meta: serialized[:meta]
        }, status: :ok
      end

      def show
        serialized = OfficeSerializer.new(
          @office,
          { params: { action: 'show' } }
        ).serializable_hash

        render json: {
          success: true,
          message: 'Escritório encontrado com sucesso',
          data: serialized[:data]
        }, status: :ok
      end

      def create
        @office = current_team.offices.build(offices_params)
        @office.created_by = current_user if current_user

        if @office.save
          serialized = OfficeSerializer.new(
            @office,
            { params: { action: 'show' } }
          ).serializable_hash

          render json: {
            success: true,
            message: 'Escritório criado com sucesso',
            data: serialized[:data]
          }, status: :created
        else
          error_messages = @office.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Office creation failed: #{e.message}"
        Rails.logger.error e.backtrace.first(10).join("\n") if e.backtrace
        error_message = 'Erro ao criar escritório. Tente novamente.'
        render json: {
          success: false,
          message: error_message,
          errors: [error_message]
        }, status: :internal_server_error
      end

      def update
        if @office.update(offices_params)
          serialized = OfficeSerializer.new(
            @office,
            { params: { action: 'show' } }
          ).serializable_hash

          render json: {
            success: true,
            message: 'Escritório atualizado com sucesso',
            data: serialized[:data]
          }, status: :ok
        else
          error_messages = @office.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        if destroy_fully?
          office = current_team.offices.with_deleted.find(params[:id])
          office.destroy_fully!
          message = 'Escritório removido permanentemente'
        else
          retrieve_office
          @office.deleted_by = current_user if current_user
          @office.destroy
          message = 'Escritório removido com sucesso'
        end

        render json: {
          success: true,
          message: message,
          data: { id: params[:id] }
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Escritório não encontrado',
          errors: ['Escritório não encontrado']
        }, status: :not_found
      end

      def with_lawyers
        authorize [:admin, :office], :index?

        offices = OfficeFilter.retrieve_offices_with_lawyers(current_team)
        serialized = OfficeWithLawyersSerializer.new(offices).serializable_hash

        render json: {
          success: true,
          message: 'Escritórios com advogados listados com sucesso',
          data: serialized[:data]
        }, status: :ok
      end

      def restore
        if @office.recover
          serialized = OfficeSerializer.new(
            @office,
            { params: { action: 'show' } }
          ).serializable_hash

          render json: {
            success: true,
            message: 'Escritório restaurado com sucesso',
            data: serialized[:data]
          }, status: :ok
        else
          error_messages = @office.errors.full_messages
          render json: {
            success: false,
            message: error_messages.first,
            errors: error_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def retrieve_office
        @office = OfficeFilter.retrieve_office(params[:id], current_team)
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Escritório não encontrado',
          errors: ['Escritório não encontrado']
        }, status: :not_found
      end

      def retrieve_deleted_office
        @office = current_team.offices.with_deleted.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          message: 'Escritório não encontrado',
          errors: ['Escritório não encontrado']
        }, status: :not_found
      end

      def offices_params
        params.require(:office).permit(
          :name, :cnpj, :oab_id, :oab_status, :oab_inscricao, :oab_link,
          :society, :foundation, :site, :accounting_type,
          :quote_value, :number_of_quotes,
          :logo,
          phones_attributes: [:id, :phone_number, :_destroy],
          addresses_attributes: [:id, :street, :number, :complement, :neighborhood,
                                 :city, :state, :zip_code, :address_type, :_destroy],
          emails_attributes: [:id, :email, :_destroy],
          bank_accounts_attributes: [:id, :bank_name, :type_account, :agency,
                                     :account, :operation, :pix, :_destroy],
          user_offices_attributes: [:id, :user_id, :partnership_type,
                                    :partnership_percentage, :_destroy]
        )
        # rubocop:enable Rails/StrongParametersExpect
      end

      def perform_authorization
        authorize [:admin, :office], :"#{action_name}?"
      end
    end
  end
end
