# frozen_string_literal: true

module ProfileCustomers
  class CreateDocumentService < ApplicationService
    def initialize(profile_customer, current_admin)
      @documents = profile_customer.customer_files.simple_procuration
      @profile_admin = current_admin.profile_admin
    end

    def call
      return if @documents.nil?

      create_document
    end

    private

    def create_document
      @documents.each do |document|
        ProfileCustomers::SimpleProcurationService.call(document.id, @profile_admin.id)
      end
    end
  end
end
