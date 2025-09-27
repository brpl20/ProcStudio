# frozen_string_literal: true

module Api
  module V1
    class OfficesController < BackofficeController # rubocop:disable Metrics/ClassLength
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
        # Extract non-model attributes before creating office
        logo = params[:office].delete(:logo)
        social_contracts = params[:office].delete(:social_contracts)
        params[:office].delete(:profit_distribution)
        params[:office].delete(:partners_with_pro_labore)

        Rails.logger.info "Current team: #{current_team.inspect}"
        Rails.logger.info "Current team ID: #{current_team&.id}"

        @office = current_team.offices.build(offices_params)
        @office.created_by = current_user if current_user

        Rails.logger.info "Office team_id after build: #{@office.team_id}"

        if @office.save
          # Handle logo upload if present
          if logo.present?
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

          # Handle social contracts upload if present
          if social_contracts.present?
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

          # Handle social contract generation if requested (separate from upload)
          if @office.create_social_contract == 'true'
            Rails.logger.info "Social contract generation requested for office #{@office.id}"
            # TODO: Call generate_social_contract service when implemented
          end

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
          render_error_response(@office)
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
        # Extract non-model attributes before updating office
        logo = params[:office].delete(:logo)
        social_contracts = params[:office].delete(:social_contracts)
        params[:office].delete(:profit_distribution)
        params[:office].delete(:partners_with_pro_labore)

        # Check if only file uploads were sent (no other office attributes)
        # In this case, skip the update and just process the files
        should_update_office = params[:office].present? && !params[:office].empty?

        if !should_update_office || @office.update(offices_params)
          # Handle logo upload if present
          if logo.present?
            metadata_params = {
              uploaded_by_id: current_user.id,
              description: "Logo for #{@office.name}"
            }
            @office.upload_logo(logo, metadata_params)
          end

          # Handle social contracts upload if present
          if social_contracts.present?
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

          # Handle social contract generation if requested (separate from upload)
          if @office.create_social_contract == 'true'
            Rails.logger.info "Social contract generation requested for office #{@office.id}"
            # TODO: Call generate_social_contract service when implemented
          end

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

        # Validate file type
        unless params[:logo].content_type.in?(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
          return render json: {
            success: false,
            message: 'Formato de arquivo inválido. Use imagens JPEG, PNG, GIF ou WEBP'
          }, status: :unprocessable_entity
        end

        metadata_params = {
          document_date: params[:document_date],
          description: params[:description],
          custom_metadata: params[:custom_metadata],
          uploaded_by_id: current_user.id
        }

        if @office.upload_logo(params[:logo], metadata_params)

          serialized = OfficeSerializer.new(
            @office,
            { params: { action: 'show' } }
          ).serializable_hash

          render json: {
            success: true,
            message: 'Logo atualizado com sucesso',
            data: serialized[:data]
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Erro ao fazer upload do logo',
            errors: @office.errors.full_messages
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Logo upload failed: #{e.message}"
        render json: {
          success: false,
          message: 'Erro ao fazer upload do logo',
          errors: [e.message]
        }, status: :internal_server_error
      end

      def upload_contracts
        retrieve_office

        service = OfficeContractUploadService.new(@office, current_user)

        if service.upload_contracts(params[:contracts], params)
          serialized = OfficeSerializer.new(
            @office,
            { params: { action: 'show' } }
          ).serializable_hash

          render json: {
            success: true,
            message: "#{service.uploaded_count} contrato(s) adicionado(s) com sucesso",
            data: serialized[:data]
          }, status: :ok
        else
          render json: {
            success: false,
            message: service.errors.first || 'Erro ao fazer upload dos contratos',
            errors: service.errors
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Contract upload failed: #{e.message}"
        Rails.logger.error e.backtrace.first(10).join("\n") if e.backtrace
        render json: {
          success: false,
          message: 'Erro ao fazer upload dos contratos',
          errors: [e.message]
        }, status: :internal_server_error
      end

      def remove_attachment
        retrieve_office

        attachment = @office.social_contracts.find(params[:attachment_id])

        # Remove metadata
        @office.attachment_metadata.find_by(blob_id: attachment.blob.id)&.destroy

        # Remove attachment
        attachment.purge

        render json: {
          success: true,
          message: 'Anexo removido com sucesso',
          data: { id: params[:attachment_id] }
        }, status: :ok
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "Attachment not found: #{e.message}"
        render json: {
          success: false,
          message: 'Anexo não encontrado'
        }, status: :not_found
      rescue StandardError => e
        Rails.logger.error "Attachment removal failed: #{e.message}"
        Rails.logger.error e.backtrace.first(10).join("\n") if e.backtrace
        render json: {
          success: false,
          message: 'Erro ao remover anexo',
          errors: [e.message]
        }, status: :internal_server_error
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

      def render_error_response(object, status = :unprocessable_entity)
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
        ['phones_attributes', 'addresses_attributes', 'emails_attributes', 'office_emails_attributes', 'bank_accounts_attributes', 'user_offices_attributes'].each do |attr|
          next unless params[:office][attr].is_a?(String)

          begin
            params[:office][attr] = JSON.parse(params[:office][attr])
          rescue JSON::ParserError => e
            Rails.logger.error "Error parsing #{attr}: #{e.message}"
          end
        end
      end

      def perform_authorization
        authorize [:admin, :office], :"#{action_name}?"
      end
    end
  end
end
