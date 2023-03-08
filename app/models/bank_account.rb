# frozen_string_literal: true

class BankAccount < ApplicationRecord
  has_many :admin_bank_accounts, dependent: :destroy
  has_many :profile_admins, through: :admin_bank_accounts

  has_many :office_bank_accounts, dependent: :destroy
  has_many :offices, through: :office_bank_accounts
end
