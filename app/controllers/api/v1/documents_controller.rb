module Api
  module V1
    class DocumentsController < BackofficeController
      before_action :set_work
      before_action :set_document

      def update
        if params[:file].present?
          @document.document_docx.purge_later # Remove o arquivo anterior (assíncrono)
          @document.document_docx.attach(params[:file]) # Faz o upload do novo arquivo

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
        params.require(:document).permit(:file) # Assumindo que `file` é o campo do upload
      end
    end
  end
end
