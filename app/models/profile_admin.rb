# frozen_string_literal: true

class ProfileAdmin < ApplicationRecord
  belongs_to :admin
  belongs_to :office, optional: true

  enum role: {
    lawyer: 'lawyer',
    paralegal: 'paralegal',
    trainee: 'trainee',
    secretary: 'secretary',
    counter: 'counter',
    excounter: 'excounter'
  }

  enum status: {
    active: 'active',
    inactive: 'inactive',
    pending: 'pending'
  }

  scope :lawyer, -> { where(role: 'lawyer') }
  scope :paralegal, -> { where(role: 'paralegal') }
  scope :trainee, -> { where(role: 'trainee') }
  scope :secretary, -> { where(role: 'secretary') }
  scope :counter, -> { where(role: 'counter') }
  scope :excounter, -> { where(role: 'excounter') }

  has_many :admin_addresses, dependent: :destroy
  has_many :addresses, through: :admin_addresses

  has_many :admin_phones, dependent: :destroy
  has_many :phones, through: :admin_phones

  has_many :admin_emails, dependent: :destroy
  has_many :emails, through: :admin_emails

  has_many :admin_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :admin_bank_accounts

  has_many :profile_admin_works, dependent: :destroy
  has_many :works, through: :profile_admin_works

  has_many :jobs

  accepts_nested_attributes_for :admin, :addresses, :phones, :emails, :bank_accounts, reject_if: :all_blank

  def full_name
    [name, last_name].join(' ')
  end
end
