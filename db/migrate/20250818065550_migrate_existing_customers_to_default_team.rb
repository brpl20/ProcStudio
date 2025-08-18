# frozen_string_literal: true

class MigrateExistingCustomersToDefaultTeam < ActiveRecord::Migration[7.0]
  def up
    # Buscar team padrão
    default_team = Team.find_by(subdomain: 'default')
    return unless default_team

    # Migrar todos os customers existentes para o team padrão
    Customer.find_each do |customer|
      TeamCustomer.create!(
        team: default_team,
        customer: customer,
        customer_email: customer.email
      )
    end
  end

  def down
    # Remove todas as associações team_customers
    TeamCustomer.destroy_all
  end
end
