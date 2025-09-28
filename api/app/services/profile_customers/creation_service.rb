# frozen_string_literal: true

module ProfileCustomers
  class CreationService
    def initialize(current_user:, current_team:)
      @current_user = current_user
      @current_team = current_team
    end

    def call(params, options = {})
      profile_customer = build_profile_customer(params)

      if profile_customer.save
        profile_customer.reload
        associate_with_team(profile_customer)
        handle_document_creation(profile_customer, options)
        Result.success(profile_customer)
      else
        log_validation_errors(profile_customer, params)
        Result.failure(profile_customer.errors.full_messages)
      end
    end

    private

    attr_reader :current_user, :current_team

    def build_profile_customer(params)
      profile_customer = ProfileCustomer.new(params)
      profile_customer.created_by_id = current_user.id
      profile_customer
    end

    def associate_with_team(profile_customer)
      return unless profile_customer.customer.present? && current_team.present?

      TeamCustomer.create!(
        team: current_team,
        customer: profile_customer.customer,
        customer_email: profile_customer.customer.email
      )
    end

    def handle_document_creation(profile_customer, options)
      return unless options[:issue_documents]

      ProfileCustomers::CreateDocumentService.call(profile_customer, current_user)
    end

    def log_validation_errors(profile_customer, params)
      Rails.logger.error 'ProfileCustomer validation failed:'
      Rails.logger.error "Errors: #{profile_customer.errors.full_messages}"
      Rails.logger.error "Attributes: #{params.inspect}"
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
