# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_customers
#
#  id             :bigint(8)        not null, primary key
#  customer_type  :string
#  name           :string
#  last_name      :string
#  gender         :string
#  rg             :string
#  cpf            :string
#  cnpj           :string
#  nationality    :string
#  civil_status   :string
#  capacity       :string
#  profession     :string
#  company        :string
#  birth          :date
#  mother_name    :string
#  number_benefit :string
#  status         :integer
#  document       :json
#  nit            :string
#  inss_password  :string
#  invalid_person :integer
#  customer_id    :bigint(8)        not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ProfileCustomer < ApplicationRecord
  belongs_to :customer

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
    counter: 'conter'
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

  has_one :represent

  accepts_nested_attributes_for :customer_files, :customer, :addresses,
                                :phones, :emails, :bank_accounts, :represent,
                                reject_if: :all_blank

  validates :name, presence: true
  validates :gender, presence: true

  def full_name
    [name, last_name].join(' ')
  end

  def last_email
    return I18n.t('general.without_email') unless emails.present?

    emails.last.email
  end

  def unable?
    capacity == 'unable'
  end
end
