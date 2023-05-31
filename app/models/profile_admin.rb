# frozen_string_literal: true

class ProfileAdmin < ApplicationRecord
  belongs_to :admin
  belongs_to :office

  enum :role, %i[lawyer paralegal trainee secretary counter excounter]
  enum :status, %i[active inactive pending]

  has_many :admin_addresses, dependent: :destroy
  has_many :addresses, through: :admin_addresses

  has_many :admin_phones, dependent: :destroy
  has_many :phones, through: :admin_phones

  has_many :admin_emails, dependent: :destroy
  has_many :emails, through: :admin_emails

  has_many :admin_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :admin_bank_accounts

  accepts_nested_attributes_for :admin, :addresses, :phones, :emails, :bank_accounts, reject_if: :all_blank
end
