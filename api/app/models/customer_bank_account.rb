# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_bank_accounts
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  bank_account_id     :bigint           not null
#  profile_customer_id :bigint           not null
#
# Indexes
#
#  index_customer_bank_accounts_on_bank_account_id      (bank_account_id)
#  index_customer_bank_accounts_on_deleted_at           (deleted_at)
#  index_customer_bank_accounts_on_profile_customer_id  (profile_customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (bank_account_id => bank_accounts.id)
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#

class CustomerBankAccount < ApplicationRecord
  acts_as_paranoid

  belongs_to :profile_customer
  belongs_to :bank_account
end
