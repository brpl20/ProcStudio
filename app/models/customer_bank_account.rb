# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_bank_accounts
#
#  id                  :bigint(8)        not null, primary key
#  profile_customer_id :bigint(8)        not null
#  bank_account_id     :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class CustomerBankAccount < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :bank_account
end
