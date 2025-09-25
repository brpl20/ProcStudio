# frozen_string_literal: true

require 'docx'

module DocxServices
  class BaseTemplate
    attr_reader :document, :work, :customer, :address, :lawyers, :office

    def initialize(document_id)
      @document = Document.find(document_id)
      @work = document.work
      @customer = document.profile_customer
      @address = customer.addresses.first
      @lawyers = work.user_profiles
      @office = work.office
    end

    def call
      process_document
      save_document
    end
  end
end
