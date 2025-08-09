# frozen_string_literal: true

class ProfileCustomerFilter
  class << self
    def retrieve_customer(id, team = nil)
      scope = ProfileCustomer.includes(:phones, :addresses, :emails, :bank_accounts)
      scope = scope.by_team(team) if team.present?
      scope.find(id)
    end

    def retrieve_customers(team = nil)
      scope = ProfileCustomer.includes(:customer, :phones, :addresses, :emails, :bank_accounts)
      team.present? ? scope.by_team(team) : scope.all
    end
  end
end
