# frozen_string_literal: true

module Customers
  class SerializerService
    def self.serialize_customers(customers)
      CustomerSerializer.new(
        customers,
        include: [:profile_customer],
        meta: { total_count: customers.offset(nil).limit(nil).count }
      ).serializable_hash
    end

    def self.serialize_customer(customer, action: nil)
      options = { include: [:profile_customer] }
      options[:params] = { action: action } if action

      CustomerSerializer.new(customer, options).serializable_hash
    end
  end
end
