# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_bank_accounts
#
#  id               :bigint(8)        not null, primary key
#  bank_account_id  :bigint(8)        not null
#  profile_admin_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class AdminBankAccount < ApplicationRecord
  belongs_to :bank_account
  belongs_to :profile_admin
end
