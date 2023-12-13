# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id           :bigint(8)        not null, primary key
#  bank_name    :string
#  type_account :string
#  agency       :string
#  account      :string
#  operation    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  pix          :string
#
class BankAccount < ApplicationRecord
  has_many :admin_bank_accounts, dependent: :destroy
  has_many :profile_admins, through: :admin_bank_accounts

  has_many :office_bank_accounts, dependent: :destroy
  has_many :offices, through: :office_bank_accounts
end
