# frozen_string_literal: true

module Api
  module V1
    class ZapsignController < BackofficeController
      before_action :set_work
      before_action :set_documents
      before_action :initialize_zapsign_service

      def create
        valid_documents, invalid_documents = validate_documents(@documents)

        results = valid_documents.map do |document|
          begin
            result = @zapsign_service.create_document(document)
            { document_id: document.id, status: :success, response: result }
          rescue StandardError => e
            { document_id: document.id, status: :error, error: e.message }
          end
        end

        render json: {
          success: results.select { |r| r[:status] == :success },
          errors: results.select { |r| r[:status] == :error } + invalid_documents
        }, status: :ok
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
        @zapsign_service = ZapsignService.new('479ea6a3-50db-4621-9a9f-f9a4a4e67d3b0880c773-a70b-4db2-8121-f671306d3d0e')
      end

      def validate_documents(documents)
        valid_documents = []
        invalid_documents = []

        documents.each do |document|
          if document.format == "pdf" && document.status == "approved" && document.sign_source == "no_signature"
            valid_documents << document
          else
            invalid_documents << {
              document_id: document.id,
              status: :error,
              error: "Documento não atende aos requisitos: format=pdf, status=approved, sign_source=no_signature"
            }
          end
        end

        [valid_documents, invalid_documents]
      end
    end
  end
end
