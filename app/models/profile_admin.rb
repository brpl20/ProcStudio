# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_admins
#
#  id           :bigint(8)        not null, primary key
#  role         :string
#  name         :string
#  last_name    :string
#  gender       :string
#  oab          :string
#  rg           :string
#  cpf          :string
#  nationality  :string
#  civil_status :string
#  birth        :date
#  mother_name  :string
#  status       :string
#  admin_id     :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  office_id    :bigint(8)        default(1), not null
#
class ProfileAdmin < ApplicationRecord
  belongs_to :admin
  belongs_to :office, optional: true

  enum role: {
    lawyer: 'lawyer',
    paralegal: 'paralegal',
    trainee: 'trainee',
    secretary: 'secretary',
    counter: 'counter',
    excounter: 'excounter',
    representant: 'representant'
  }

  enum status: {
    active: 'active',
    inactive: 'inactive',
    pending: 'pending'
  }

  enum civil_status: {
    single: 'single',
    married: 'married',
    divorced: 'divorced',
    widower: 'widower',
    union: 'union'
  }

  enum gender: {
    male: 'male',
    female: 'female',
    other: 'other'
  }

  enum nationality: {
    brazilian: 'brazilian',
    foreigner: 'foreigner'
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
