# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id           :bigint           not null, primary key
#  account      :string
#  agency       :string
#  bank_name    :string
#  operation    :string
#  pix          :string
#  type_account :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class BankAccount < ApplicationRecord
  has_many :admin_bank_accounts, dependent: :destroy
  has_many :profile_admins, through: :admin_bank_accounts

  has_many :office_bank_accounts, dependent: :destroy
  has_many :offices, through: :office_bank_accounts
end
