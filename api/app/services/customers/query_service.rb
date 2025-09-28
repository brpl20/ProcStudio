# frozen_string_literal: true

module Customers
  class QueryService
    def self.build_query(team:, filter_params:)
      customers = team.customers.includes(
        profile_customer: [
          :customer, :emails, :phones, :addresses, :bank_accounts,
          :customer_files, :represented_customers, :active_represents
        ]
      )

      apply_filters(customers, filter_params)
    end

    def self.apply_filters(customers, filter_params)
      filter_params.each do |key, value|
        next if value.blank?

        customers = customers.public_send("filter_by_#{key}", value.strip)
      end
      customers
    end
  end
end
