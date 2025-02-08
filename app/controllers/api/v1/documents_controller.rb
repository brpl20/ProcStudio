# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < BackofficeController
      before_action :set_work
      before_action :set_document

      def update
        if params[:file].present?
          @document.file.purge

          begin
            @document.file.attach(
              io: params[:file],
              filename: params[:file].original_filename,
              content_type: params[:file].content_type
            )

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
