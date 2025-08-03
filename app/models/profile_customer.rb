# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_customers
#
#  id                   :bigint(8)        not null, primary key
#  customer_type        :string
#  name                 :string
#  last_name            :string
#  gender               :string
#  rg                   :string
#  cpf                  :string
#  cnpj                 :string
#  nationality          :string
#  civil_status         :string
#  capacity             :string
#  profession           :string
#  company              :string
#  birth                :date
#  mother_name          :string
#  number_benefit       :string
#  document             :json
#  nit                  :string
#  inss_password        :string
#  invalid_person       :integer
#  customer_id          :bigint(8)        not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  accountant_id        :integer
#  deleted_at           :datetime
#  created_by_id        :bigint(8)
#  status               :string           default("active"), not null
#  individual_entity_id :bigint(8)
#  legal_entity_id      :bigint(8)
#
class ProfileCustomer < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :customer, -> { with_deleted }, optional: true
  belongs_to :accountant, class_name: 'ProfileCustomer', optional: true

  enum gender: {
    male: 'male',
    female: 'female',
    other: 'other'
  }

  enum nationality: {
    brazilian: 'brazilian',
    foreigner: 'foreigner'
  }

  enum capacity: {
    able: 'able',
    relatively: 'relatively',
    unable: 'unable'
  }

  enum status: {
    active: 'active',
    inactive: 'inactive'
  }

  enum civil_status: {
    single: 'single',
    married: 'married',
    divorced: 'divorced',
    widower: 'widower',
    union: 'union'
  }

  enum customer_type: {
    physical_person: 'physical_person',
    legal_person: 'legal_person',
    representative: 'representative',
    counter: 'counter'
  }

  has_many_attached :files

  has_many :customer_addresses, dependent: :destroy
  has_many :addresses, through: :customer_addresses

  has_many :customer_phones, dependent: :destroy
  has_many :phones, through: :customer_phones

  has_many :customer_emails, dependent: :destroy
  has_many :emails, through: :customer_emails

  has_many :customer_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :customer_bank_accounts

  has_many :customer_works, dependent: :destroy
  has_many :works, through: :customer_works

  has_many :customer_files, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :recommendations, dependent: :destroy

  has_many :represented_customers, class_name: 'Represent', foreign_key: 'representor_id', dependent: :nullify
  has_one :represent, dependent: :destroy

  accepts_nested_attributes_for :customer_files, :customer, :addresses,
                                :phones, :emails, :bank_accounts, :represent,
                                reject_if: :all_blank

  accepts_nested_attributes_for :customer_emails, allow_destroy: true

  with_options presence: true do
    validates :capacity
    validates :civil_status
    validates :cpf
    validates :gender
    validates :name
    validates :nationality
    validates :profession
    validates :rg
  end

  validates_with PhoneNumberValidator

  def full_name
    "#{name} #{last_name}".squish
  end

  def last_email
    return I18n.t('general.without_email') unless emails.present?

    emails.last.email
  end

  def last_phone
    return I18n.t('general.without_phone') unless phones.present?

    phones.last.phone_number
  end

  def unable?
    capacity == 'unable'
  end

  def emails_attributes=(attributes)
    current_email_ids = attributes.map { |attr| attr[:id].to_i }.compact

    customer_emails.where.not(email_id: current_email_ids).destroy_all

    super(attributes)
  end

  def phones_attributes=(attributes)
    current_phone_ids = attributes.map { |attr| attr[:id].to_i }.compact

    customer_phones.where.not(phone_id: current_phone_ids).destroy_all

    super(attributes)
  end
end
