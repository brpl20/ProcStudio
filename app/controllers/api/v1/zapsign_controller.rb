# frozen_string_literal: true

module Api
  module V1
    class ZapsignController < BackofficeController
      before_action :set_work, only: [:create]
      before_action :set_documents, only: [:create]
      before_action :initialize_zapsign_service, only: [:create]

      def create
        valid_documents, invalid_documents = validate_documents(@documents)

        results = valid_documents.map do |document|
          result = @zapsign_service.create_document(document)
          { document_id: document.id, status: :success, response: result }
        rescue StandardError => e
          { document_id: document.id, status: :error, error: e.message }
        end

        render json: {
          success: results.select { |r| r[:status] == :success },
          errors: results.select { |r| r[:status] == :error } + invalid_documents
        }, status: :ok
      end

      def webhook
        binding.pry
        payload = JSON.parse(request.body.read, symbolize_names: true)
        document = Document.find_by(id: payload[:external_id])

        if document
          if payload[:status] == 'signed'
            document.update(status: :signed, sign_source: :zapsign)
            render json: { message: 'Documento atualizado para signed.' }, status: :ok
          else
            render json: { message: 'Documento não está assinado.' }, status: :ok
          end
        else
          render json: { error: 'Documento não encontrado.' }, status: :not_found
        end
      end

      private

      def set_work
        @work = Work.find(params[:work_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Work não encontrado' }, status: :not_found
      end

      def set_documents
        @documents = @work.documents
      end

      def initialize_zapsign_service
        @zapsign_service = ZapsignService.new
      end

      def validate_documents(documents)
        valid_documents = []
        invalid_documents = []

        documents.each do |document|
          if document.format == 'pdf' && document.status == 'approved'
            valid_documents << document
          else
            invalid_documents << {
              document_id: document.id,
              status: :error,
              error: 'Documento não atende aos requisitos: format=pdf, status=approved, sign_source=no_signature'
            }
          end
        end

        [valid_documents, invalid_documents]
      end
    end
  end
end
