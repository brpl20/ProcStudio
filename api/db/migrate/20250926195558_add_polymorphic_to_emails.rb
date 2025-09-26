# frozen_string_literal: true

class AddPolymorphicToEmails < ActiveRecord::Migration[8.0]
  def change
    # Add polymorphic columns
    add_reference :emails, :emailable, polymorphic: true, index: true

    # Add deleted_at for soft delete support
    add_column :emails, :deleted_at, :datetime
    add_index :emails, :deleted_at

    # Add email_type column (similar to address_type)
    add_column :emails, :email_type, :string, default: 'main'

    # Migrate existing data
    reversible do |dir|
      dir.up do
        # Migrate office emails
        execute <<-SQL.squish
          UPDATE emails e
          SET emailable_type = 'Office',
              emailable_id = oe.office_id
          FROM office_emails oe
          WHERE e.id = oe.email_id
        SQL

        # Migrate customer emails
        execute <<-SQL.squish
          UPDATE emails e
          SET emailable_type = 'ProfileCustomer',
              emailable_id = ce.profile_customer_id
          FROM customer_emails ce
          WHERE e.id = ce.email_id
        SQL

        # NOTE: UserProfile doesn't have emails currently, so no migration needed
      end
    end
  end
end
