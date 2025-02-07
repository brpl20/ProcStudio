# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < BackofficeController
      before_action :set_work
      before_action :set_document

      def update
        if params[:file].present?
          Rails.logger.info("Rails.env: #{Rails.env}")
          @document.document_docx.purge
          @document.document_docx.attach(params[:file])

          render json: { message: 'Documento atualizado com sucesso!' }, status: :ok
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
    end
  end
end
