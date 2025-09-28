# frozen_string_literal: true

module Api
  module V1
    class OfficesController < BackofficeController # rubocop:disable Metrics/ClassLength
      include OfficeResponses

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
        file_params = extract_file_params
        @office = build_office

        if @office.save
          process_file_uploads(file_params)
          render_create_success
        else
          render_error_response(@office)
        end
      rescue StandardError => e
        log_creation_error(e)
        render_creation_error
      end

      def update
        file_params = extract_file_params
        should_update_office = should_update_office_attributes?

        if !should_update_office || @office.update(offices_params)
          process_file_uploads(file_params)
          render_update_success
        else
          render_error_response(@office)
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
          render_error_response(@office)
        end
      end

      # Attachment-specific actions

      def upload_logo
        retrieve_office
        service = Offices::LogoUploadService.new(@office, current_user)

        metadata_params = logo_metadata_params
        result = service.call(params[:logo], metadata_params)

        if result == true || (result.respond_to?(:success) && result.success != false)
          office_upload_success_response(@office, 'Logo atualizado com sucesso')
        else
          office_error_response(
            result.respond_to?(:message) ? result.message : 'Erro ao fazer upload do logo',
            @office.errors.full_messages
          )
        end
      rescue StandardError => e
        office_internal_error_response(e, 'Erro ao fazer upload do logo')
      end

      def upload_contracts
        retrieve_office
        service = Offices::ContractsUploadService.new(@office, current_user)

        result = service.call(params[:contracts], contract_metadata_params)

        if result.success
          office_upload_success_response(@office, result.message)
        else
          office_upload_error_response(result)
        end
      rescue StandardError => e
        office_internal_error_response(e, 'Erro ao fazer upload dos contratos')
      end

      def remove_attachment
        retrieve_office
        service = Offices::AttachmentRemovalService.new(@office)

        result = service.call(params[:attachment_id])

        if result.success
          office_success_response(result.message, result.data)
        else
          office_error_response(result.message, nil, :not_found)
        end
      rescue StandardError => e
        office_internal_error_response(e, 'Erro ao remover anexo')
      end

      def update_attachment_metadata
        retrieve_office

        metadata = @office.attachment_metadata.find_by(blob_id: params[:blob_id])

        unless metadata
          return render json: {
            success: false,
            message: 'Metadados do anexo não encontrados'
          }, status: :not_found
        end

        metadata_params = params.permit(:document_date, :description, :custom_metadata)

        if metadata.update(metadata_params)
          render json: {
            success: true,
            message: 'Metadados atualizados com sucesso',
            data: {
              blob_id: metadata.blob_id,
              document_date: metadata.document_date,
              description: metadata.description,
              custom_metadata: metadata.custom_metadata
            }
          }, status: :ok
        else
          render_error_response(metadata)
        end
      end

      private

      def extract_file_params
        {
          logo: params[:office].delete(:logo),
          social_contracts: params[:office].delete(:social_contracts)
        }.tap do
          params[:office].delete(:profit_distribution)
          params[:office].delete(:partners_with_pro_labore)
        end
      end

      def build_office
        Rails.logger.info "Current team: #{current_team.inspect}"
        Rails.logger.info "Current team ID: #{current_team&.id}"

        office = current_team.offices.build(offices_params)
        office.created_by = current_user if current_user

        Rails.logger.info "Office team_id after build: #{office.team_id}"
        office
      end

      def process_file_uploads(file_params)
        process_logo_upload(file_params[:logo]) if file_params[:logo].present?
        process_social_contracts_upload(file_params[:social_contracts]) if file_params[:social_contracts].present?
        process_social_contract_generation if @office.create_social_contract == 'true'
      end

      def process_logo_upload(logo)
        Rails.logger.info "Uploading logo for office #{@office.id}"
        metadata_params = {
          uploaded_by_id: current_user.id,
          description: "Logo for #{@office.name}"
        }
        if @office.upload_logo(logo, metadata_params)
          Rails.logger.info 'Logo uploaded successfully'
        else
          Rails.logger.error "Logo upload failed: #{@office.errors.full_messages}"
        end
      end

      def process_social_contracts_upload(social_contracts)
        Rails.logger.info "Uploading social contracts for office #{@office.id}"
        Array(social_contracts).each do |contract|
          next if contract.blank?

          metadata_params = {
            uploaded_by_id: current_user.id,
            document_date: Date.current,
            description: "Social contract for #{@office.name}"
          }
          if @office.upload_social_contract(contract, metadata_params)
            Rails.logger.info 'Social contract uploaded successfully'
          else
            Rails.logger.error "Social contract upload failed: #{@office.errors.full_messages}"
          end
        end
      end

      def process_social_contract_generation
        Rails.logger.info "Social contract generation requested for office #{@office.id}"
        # TODO: Call generate_social_contract service when implemented
      end

      def render_create_success
        serialized = OfficeSerializer.new(@office, { params: { action: 'show' } }).serializable_hash

        render json: {
          success: true,
          message: 'Escritório criado com sucesso',
          data: serialized[:data]
        }, status: :created
      end

      def log_creation_error(error)
        Rails.logger.error "Office creation failed: #{error.message}"
        Rails.logger.error error.backtrace.first(10).join("\n") if error.backtrace
      end

      def render_creation_error
        error_message = 'Erro ao criar escritório. Tente novamente.'
        render json: {
          success: false,
          message: error_message,
          errors: [error_message]
        }, status: :internal_server_error
      end

      def should_update_office_attributes?
        params[:office].present? && !params[:office].empty?
      end

      def render_update_success
        serialized = OfficeSerializer.new(@office, { params: { action: 'show' } }).serializable_hash

        render json: {
          success: true,
          message: 'Escritório atualizado com sucesso',
          data: serialized[:data]
        }, status: :ok
      end

      def render_error_response(object, status = :unprocessable_content)
        error_messages = object.errors.full_messages
        render json: {
          success: false,
          message: error_messages.first || 'An error occurred',
          errors: error_messages
        }, status: status
      end

      def render_success_response(message, data = nil, status = :ok)
        response = {
          success: true,
          message: message
        }
        response[:data] = data if data
        render json: response, status: status
      end

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
        # Parse JSON strings for nested attributes if they come as strings
        parse_nested_json_attributes if params[:office]

        params.require(:office).permit(
          :name, :cnpj, :oab_id, :oab_status, :oab_inscricao, :oab_link,
          :society, :foundation, :site, :accounting_type,
          :quote_value, :number_of_quotes,
          :create_social_contract, # Virtual attribute - just a trigger, not saved
          phones_attributes: [:id, :phone_number, :_destroy],
          addresses_attributes: [:id, :street, :number, :complement, :neighborhood,
                                 :city, :state, :zip_code, :address_type, :_destroy],
          office_emails_attributes: [:id, :email_id, :_destroy],
          emails_attributes: [:id, :email, :_destroy],
          bank_accounts_attributes: [:id, :bank_name, :account_type, :agency,
                                     :account, :operation, :pix, :_destroy],
          user_offices_attributes: [:id, :user_id, :partnership_type,
                                    :partnership_percentage, :is_administrator,
                                    :cna_link, :entry_date, :_destroy,
                                    { compensations_attributes: [:id, :compensation_type,
                                                                 :amount, :effective_date,
                                                                 :end_date, :payment_frequency,
                                                                 :notes, :_destroy] }]
        )
        # rubocop:enable Rails/StrongParametersExpect
      end

      def parse_nested_json_attributes
        ['phones_attributes', 'addresses_attributes', 'emails_attributes', 'office_emails_attributes',
         'bank_accounts_attributes', 'user_offices_attributes'].each do |attr|
          next unless params[:office][attr].is_a?(String)

          begin
            params[:office][attr] = JSON.parse(params[:office][attr])
          rescue JSON::ParserError => e
            Rails.logger.error "Error parsing #{attr}: #{e.message}"
          end
        end
      end

      def valid_contract?(contract, errors)
        allowed_types = [
          'application/pdf',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        ]

        unless contract.content_type.in?(allowed_types)
          errors << "Formato de arquivo inválido para #{contract.original_filename}. Use PDF ou DOCX"
          return false
        end
        true
      end

      def build_contract_metadata(contract, params)
        filename_key = contract.original_filename

        {
          document_date: params["document_date_#{filename_key}"] || params[:document_date],
          description: params["description_#{filename_key}"] || params[:description],
          custom_metadata: params["custom_metadata_#{filename_key}"] || params[:custom_metadata],
          uploaded_by_id: current_user.id
        }
      end

      def logo_metadata_params
        {
          document_date: params[:document_date],
          description: params[:description],
          custom_metadata: params[:custom_metadata]
        }
      end

      def contract_metadata_params
        {
          document_date: params[:document_date],
          description: params[:description],
          custom_metadata: params[:custom_metadata]
        }
      end

      def perform_authorization
        authorize [:admin, :office], :"#{action_name}?"
      end
    end
  end
end
