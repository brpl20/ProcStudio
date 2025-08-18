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
#  office_id    :bigint(8)
#  origin       :string
#  deleted_at   :datetime
#
class ProfileAdmin < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :admin
  belongs_to :office, optional: true

  delegate :team, to: :admin

  validate :office_same_team, if: -> { office.present? }

  enum :role, {
    lawyer: 'lawyer',
    paralegal: 'paralegal',
    trainee: 'trainee',
    secretary: 'secretary',
    counter: 'counter',
    excounter: 'excounter',
    representant: 'representant',
    super_admin: 'super_admin'
  }

  enum :status, {
    active: 'active',
    inactive: 'inactive'
  }

  enum :civil_status, {
    single: 'single',
    married: 'married',
    divorced: 'divorced',
    widower: 'widower',
    union: 'union'
  }

  enum :gender, {
    male: 'male',
    female: 'female',
    other: 'other'
  }

  enum :nationality, {
    brazilian: 'brazilian',
    foreigner: 'foreigner'
  }

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

  has_many :jobs, dependent: :destroy

  accepts_nested_attributes_for :admin, :addresses, :phones, :emails, :bank_accounts, reject_if: :all_blank

  with_options presence: true do
    validates :name
    validates :oab, if: :lawyer?
  end

  # Validações opcionais - não obrigatórias para criação inicial
  # Serão preenchidas pelo usuário via modal no frontend
  # validates :civil_status, presence: true
  # validates :cpf, presence: true
  # validates :gender, presence: true
  # validates :nationality, presence: true
  # validates :rg, presence: true

  def full_name
    "#{name} #{last_name}".squish
  end

  def last_email
    return I18n.t('general.without_email') if emails.blank?

    emails.last.email
  end

  def emails_attributes=(attributes)
    current_email_ids = attributes.filter_map { |attr| attr[:id].to_i }
    admin_emails.where.not(email_id: current_email_ids).destroy_all

    super
  end

  def phones_attributes=(attributes)
    current_phone_ids = attributes.filter_map { |attr| attr[:id].to_i }

    admin_phones.where.not(phone_id: current_phone_ids).destroy_all

    super
  end

  private

  def office_same_team
    errors.add(:office, 'deve pertencer ao mesmo team') unless office.team == admin.team
  end
end
