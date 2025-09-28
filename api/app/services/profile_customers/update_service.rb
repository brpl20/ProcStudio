# frozen_string_literal: true

module ProfileCustomers
  class UpdateService
    def initialize(profile_customer:, current_admin:)
      @profile_customer = profile_customer
      @current_admin = current_admin
    end

    def call(params, options = {})
      if profile_customer.update(params)
        handle_document_regeneration(options)
        handle_email_confirmation_if_changed
        Result.success(profile_customer)
      else
        Result.failure(profile_customer.errors.full_messages)
      end
    end

    private

    attr_reader :profile_customer, :current_admin

    def handle_document_regeneration(options)
      return unless options[:regenerate_documents]

      ProfileCustomers::CreateDocumentService.call(profile_customer, current_admin)
    end

    def handle_email_confirmation_if_changed
      return unless profile_customer.customer&.saved_change_to_email?

      profile_customer.customer.send_confirmation_instructions
    end

    class Result
      attr_reader :profile_customer, :errors

      def initialize(success:, profile_customer: nil, errors: nil)
        @success = success
        @profile_customer = profile_customer
        @errors = errors
      end

      def success?
        @success
      end

      def failure?
        !@success
      end

      def self.success(profile_customer)
        new(success: true, profile_customer: profile_customer)
      end

      def self.failure(errors)
        new(success: false, errors: errors)
      end
    end
  end
end
