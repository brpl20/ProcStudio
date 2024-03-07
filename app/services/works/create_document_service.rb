# frozen_string_literal: true

module Works
  class CreateDocumentService < ApplicationService
    def initialize(work)
      @work = work
      @documents = @work.documents
    end

    def call
      return if @documents.nil?

      create_document
    end

    private

    def create_document
      @documents.each do |document|
        case document.document_type
        when 'procuration'
          Works::DocumentProcurationService.call(document.id)
        when 'waiver'
          Works::DocumentWaiverService.call(document.id)
        when 'deficiency_statement'
          Works::DocumentDeficiencyStatementService.call(document.id)
        when 'honorary'
          Works::DocumentHonoraryService.call(document.id)
        end
      end
    end
  end
end
