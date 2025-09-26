# frozen_string_literal: true

class AddPolymorphicToBankAccounts < ActiveRecord::Migration[8.0]
  def change
    # Add polymorphic columns
    add_reference :bank_accounts, :bankable, polymorphic: true, index: true

    # Add deleted_at for soft delete support
    add_column :bank_accounts, :deleted_at, :datetime
    add_index :bank_accounts, :deleted_at

    # Add account_type column for better categorization
    add_column :bank_accounts, :account_type, :string, default: 'main'

    # Migrate existing data
    reversible do |dir|
      dir.up do
        # Migrate office bank accounts
        execute <<-SQL.squish
          UPDATE bank_accounts ba
          SET bankable_type = 'Office',
              bankable_id = oba.office_id
          FROM office_bank_accounts oba
          WHERE ba.id = oba.bank_account_id
        SQL

        # Migrate customer bank accounts
        execute <<-SQL.squish
          UPDATE bank_accounts ba
          SET bankable_type = 'ProfileCustomer',
              bankable_id = cba.profile_customer_id
          FROM customer_bank_accounts cba
          WHERE ba.id = cba.bank_account_id
        SQL

        # Migrate user bank accounts
        execute <<-SQL.squish
          UPDATE bank_accounts ba
          SET bankable_type = 'UserProfile',
              bankable_id = uba.user_profile_id
          FROM user_bank_accounts uba
          WHERE ba.id = uba.bank_account_id
        SQL
      end
    end
  end
end
