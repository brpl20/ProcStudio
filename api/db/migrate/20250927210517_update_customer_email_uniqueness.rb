# frozen_string_literal: true

class UpdateCustomerEmailUniqueness < ActiveRecord::Migration[8.0]
  def change
    # Remove the global unique index
    remove_index :customers, name: 'index_customers_on_email_where_not_deleted'

    # Add a compound unique index for team-scoped uniqueness
    add_index :team_customers, [:team_id, :customer_id],
              unique: true,
              name: 'index_team_customers_on_team_and_customer'

    # Add a regular index for email queries (non-unique)
    add_index :customers, :email,
              where: 'deleted_at IS NULL',
              name: 'index_customers_on_email_not_deleted'
  end
end
