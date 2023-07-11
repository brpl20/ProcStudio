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
          Works::DocumentProcurationService.call(@work, document)
        when 'waiver'
          Works::DocumentWaiverService.call(@work, document)
        else
          Works::DocumentDeficiencyStatementService.call(@work, document)
        end
      end
    end
  end
end
