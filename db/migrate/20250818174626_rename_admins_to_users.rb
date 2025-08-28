# frozen_string_literal: true

class RenameAdminsToUsers < ActiveRecord::Migration[7.0]
  def change
    rename_table :admins, :users
    rename_table :profile_admins, :user_profiles
    # Removed admin_addresses and admin_phones - using polymorphic now
    rename_table :admin_emails, :user_emails
    rename_table :admin_bank_accounts, :user_bank_accounts
    rename_table :profile_admin_works, :user_profile_works

    # Update foreign key columns
    rename_column :user_profiles, :admin_id, :user_id
    # Removed user_addresses and user_phones columns - using polymorphic now
    rename_column :user_emails, :profile_admin_id, :user_profile_id
    rename_column :user_bank_accounts, :profile_admin_id, :user_profile_id
    rename_column :user_profile_works, :profile_admin_id, :user_profile_id

    # The created_by_id columns already reference the correct tables after admin table rename
  end
end
