# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < BackofficeController
      before_action :set_work
      before_action :set_document

      def update
        if params[:file].present?
          if params[:is_signed_pdf].present? && params[:is_signed_pdf] == 'true'
            handle_signed_pdf
          else
            handle_docx
          end
        else
          render json: { error: 'Arquivo não fornecido' }, status: :unprocessable_entity
        end
      end

      private

      def set_work
        @work = Work.find(params[:work_id])
      end

      def set_document
        @document = @work.documents.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Documento não encontrado' }, status: :not_found
      end

      def document_params
        params.require(:document).permit(:file)
      end

      def handle_signed_pdf
        unless valid_pdf?(params[:file])
          render json: { error: 'O arquivo deve ser um PDF' }, status: :unprocessable_entity
          return
        end

        attach_signed_file(params[:file])
        update_document_status(:signed, :manual_signature)

        if @document.save
          render json: { message: 'Documento assinado atualizado com sucesso!' }, status: :ok
        else
          render json: { error: @document.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveStorage::IntegrityError => e
        render json: { error: "Erro de integridade ao anexar o documento: #{e.message}" }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: "Erro ao salvar documento: #{e.message}" }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: "Erro ao atualizar documento: #{e.message}" }, status: :internal_server_error
      end

      def handle_docx
        unless valid_docx?(params[:file])
          render json: { error: 'O arquivo deve ser um DOCX' }, status: :unprocessable_entity
          return
        end

        attach_source_file(params[:file])

        if @document.save
          render json: { message: 'Documento atualizado com sucesso!' }, status: :ok
        else
          render json: { error: @document.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveStorage::IntegrityError => e
        render json: { error: "Erro de integridade ao anexar o documento: #{e.message}" }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: "Erro ao salvar documento: #{e.message}" }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: "Erro ao atualizar documento: #{e.message}" }, status: :internal_server_error
      end

      def valid_pdf?(file)
        file.content_type == 'application/pdf'
      end

      def valid_docx?(file)
        file.content_type == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      end

      def attach_signed_file(file)
        @document.signed.purge if @document.signed.attached?
        S3UploadManager.upload_file(file, @document, :signed)
      end

      def attach_source_file(file)
        @document.original.purge if @document.original.attached?
        S3UploadManager.upload_file(file, @document, :original)
      end

      def update_document_status(status, sign_source)
        @document.status = status
        @document.sign_source = sign_source
      end
    end
  end
end
