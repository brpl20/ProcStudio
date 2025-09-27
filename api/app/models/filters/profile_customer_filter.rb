# frozen_string_literal: true

class ProfileCustomerFilter
  class << self
    def retrieve_customer(id, team = nil)
      scope = team_scoped_customers(team)
      scope.includes(:phones, :addresses, :emails, :bank_accounts).find(id)
    end

    def retrieve_customers(team = nil)
      scope = team_scoped_customers(team)
      scope.includes(:customer, :phones, :addresses, :emails, :bank_accounts)
    end

    private

    def team_scoped_customers(team)
      return ProfileCustomer.all unless team

      # Get profile customers that belong to the team through team_customers
      # First get the IDs to avoid DISTINCT issues with JSON columns
      customer_ids = Customer.joins(:team_customers)
                       .where(team_customers: { team_id: team.id })
                       .pluck(:id)

      ProfileCustomer.where(customer_id: customer_ids)
    end
  end
end
