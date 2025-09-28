# frozen_string_literal: true

module Customers
  class CreationService
    def self.create_customer(params:, current_user:, current_team:)
      customer = build_customer(params, current_user)

      if customer.save
        associate_with_team(customer, current_team)
        Result.success(customer)
      else
        Result.failure(customer.errors.full_messages)
      end
    rescue StandardError => e
      handle_creation_error(e)
    end

    def self.build_customer(params, current_user)
      customer = Customer.new(params)
      customer.created_by_id = current_user&.id
      customer
    end

    def self.handle_creation_error(error)
      Rails.logger.error "Customer creation error: #{error.class} - #{error.message}"
      Rails.logger.error error.backtrace.first(10).join("\n") if error.backtrace
      Result.failure(['Erro ao criar cliente. Tente novamente.'])
    end

    def self.associate_with_team(customer, team)
      TeamCustomer.create!(
        team: team,
        customer: customer,
        customer_email: customer.email
      )
    end

    class Result
      attr_reader :customer, :errors

      def initialize(success:, customer: nil, errors: nil)
        @success = success
        @customer = customer
        @errors = errors
      end

      def success?
        @success
      end

      def failure?
        !@success
      end

      def self.success(customer)
        new(success: true, customer: customer)
      end

      def self.failure(errors)
        new(success: false, errors: errors)
      end
    end
  end
end
