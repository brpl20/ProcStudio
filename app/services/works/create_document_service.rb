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
        class_name = document.document_type.classify
        klass = "Works::Document#{class_name}Service".safe_constantize

        klass.call(document.id)
      end
    end
  end
end
