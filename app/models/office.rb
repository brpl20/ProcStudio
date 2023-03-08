# frozen_string_literal: true

class Office < ApplicationRecord
  belongs_to :office_type
  belongs_to :profile_admin

  enum :society, %i[sole_proprietorship company individual]

  has_many :office_phones, dependent: :destroy
  has_many :phones, through: :office_phones

  has_many :office_emails, dependent: :destroy
  has_many :emails, through: :office_emails

  has_many :office_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :office_bank_accounts

  accepts_nested_attributes_for :phones, :emails, :bank_accounts, reject_if: :all_blank
end
