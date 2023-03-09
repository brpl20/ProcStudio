# frozen_string_literal: true

class ProfileCustomerFilter
  class << self
    def retrieve_customer(id)
      ProfileCustomer.find(id)
    end

    def retrieve_customers
      ProfileCustomer.includes(:customer).all
    end
  end
end
