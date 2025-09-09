# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_customers
#
#  id             :bigint           not null, primary key
#  birth          :date
#  capacity       :string
#  civil_status   :string
#  cnpj           :string
#  company        :string
#  cpf            :string
#  customer_type  :string
#  deceased_at    :datetime
#  deleted_at     :datetime
#  document       :json
#  gender         :string
#  inss_password  :string
#  last_name      :string
#  mother_name    :string
#  name           :string
#  nationality    :string
#  nit            :string
#  number_benefit :string
#  profession     :string
#  rg             :string
#  status         :string           default("active"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  accountant_id  :integer
#  created_by_id  :bigint
#  customer_id    :bigint           not null
#
# Indexes
#
#  index_profile_customers_on_accountant_id  (accountant_id)
#  index_profile_customers_on_created_by_id  (created_by_id)
#  index_profile_customers_on_customer_id    (customer_id)
#  index_profile_customers_on_deceased_at    (deceased_at)
#  index_profile_customers_on_deleted_at     (deleted_at)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (customer_id => customers.id)
#
class ProfileCustomer < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Track changes for compliance, only tracking capacity changes manually
  has_paper_trail only: [:capacity], on: [:update]

  belongs_to :customer, -> { with_deleted }, optional: true
  belongs_to :accountant, class_name: 'ProfileCustomer', optional: true

  # Compliance callback for manual capacity changes
  after_update :check_compliance_for_capacity_change, if: :saved_change_to_capacity?

  enum :gender, {
    male: 'male',
    female: 'female',
    other: 'other'
  }

  enum :nationality, {
    brazilian: 'brazilian',
    foreigner: 'foreigner'
  }

  enum :capacity, {
    able: 'able',
    relatively: 'relatively',
    unable: 'unable'
  }

  enum :status, {
    active: 'active',
    inactive: 'inactive',
    deceased: 'deceased'
  }

  enum :civil_status, {
    single: 'single',
    married: 'married',
    divorced: 'divorced',
    widower: 'widower',
    union: 'union'
  }

  enum :customer_type, {
    physical_person: 'physical_person',
    legal_person: 'legal_person',
    representative: 'representative',
    counter: 'counter'
  }

  has_many_attached :files

  # Polymorphic associations for addresses and phones
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :phones, as: :phoneable, dependent: :destroy

  # Nested attributes for API
  accepts_nested_attributes_for :phones,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['phone_number'].blank? }

  accepts_nested_attributes_for :addresses,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['street'].blank? || attrs['city'].blank? }

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
  has_many :drafts, as: :draftable, dependent: :destroy

  # Relationships for representation
  # As a representor (guardian/assistant), this person can represent multiple customers
  has_many :represented_customers, class_name: 'Represent', foreign_key: 'representor_id', dependent: :nullify

  # As a represented person (unable/relatively incapable), can have multiple representors
  has_many :represents, dependent: :destroy
  has_many :representors, through: :represents, source: :representor
  has_many :active_represents, -> { active.current }, class_name: 'Represent', dependent: :destroy
  has_many :active_representors, through: :active_represents, source: :representor

  accepts_nested_attributes_for :customer_files, :customer, :represents,
                                :addresses, :phones, :emails, :bank_accounts,
                                reject_if: :all_blank

  accepts_nested_attributes_for :customer_emails, allow_destroy: true

  with_options presence: true do
    validates :capacity
    validates :civil_status
    validates :cpf
    validates :gender
    validates :name
    validates :nationality
    validates :rg
  end

  # Profession is required only for able and relatively incapable persons
  validates :profession, presence: true, unless: :unable?

  validates :cpf, cpf: true
  validates :birth, birth_date: { set_capacity: true }, allow_blank: true

  validates_with PhoneNumberValidator

  attr_accessor :capacity_message

  def full_name
    "#{name} #{last_name}".squish
  end

  def last_email
    return I18n.t('general.without_email') if emails.blank?

    emails.last.email
  end

  def last_phone
    return I18n.t('general.without_phone') if phones.blank?

    phones.last.phone_number
  end

  private

  def check_compliance_for_capacity_change
    # Only create compliance notification for manual changes
    # Automatic age-based changes are handled by AgeTransitionCheckerJob
    Compliance::CapacityChangeService.new(self).handle_manual_change
  end
end
