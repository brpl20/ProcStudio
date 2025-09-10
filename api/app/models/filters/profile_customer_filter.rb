# frozen_string_literal: true

class ProfileCustomerFilter
  class << self
    def retrieve_customer(id)
      ProfileCustomer.includes(:phones, :addresses, :emails, :bank_accounts).find(id)
    end

    def retrieve_customers
      ProfileCustomer.includes(:customer, :phones, :addresses, :emails, :bank_accounts).all
    end
  end
end
