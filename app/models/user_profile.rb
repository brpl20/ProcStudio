# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id           :bigint           not null, primary key
#  birth        :date
#  civil_status :string
#  cpf          :string
#  deleted_at   :datetime
#  gender       :string
#  last_name    :string
#  mother_name  :string
#  name         :string
#  nationality  :string
#  oab          :string
#  origin       :string
#  rg           :string
#  role         :string
#  status       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  office_id    :bigint
#  user_id      :bigint           not null
#
# Indexes
#
#  index_user_profiles_on_deleted_at  (deleted_at)
#  index_user_profiles_on_office_id   (office_id)
#  index_user_profiles_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (user_id => users.id)
#

class UserProfile < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :user
  belongs_to :office, optional: true

  delegate :team, to: :user

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

  has_many :user_addresses, dependent: :destroy
  has_many :addresses, through: :user_addresses

  has_many :user_phones, dependent: :destroy
  has_many :phones, through: :user_phones

  has_many :user_emails, dependent: :destroy
  has_many :emails, through: :user_emails

  has_many :user_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :user_bank_accounts

  has_many :user_profile_works, dependent: :destroy
  has_many :works, through: :user_profile_works

  has_many :jobs, dependent: :destroy

  accepts_nested_attributes_for :user, :addresses, :phones, :emails, :bank_accounts, reject_if: :all_blank

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
    user_emails.where.not(email_id: current_email_ids).destroy_all

    super
  end

  def phones_attributes=(attributes)
    current_phone_ids = attributes.filter_map { |attr| attr[:id].to_i }

    user_phones.where.not(phone_id: current_phone_ids).destroy_all

    super
  end

  private

  def office_same_team
    errors.add(:office, 'deve pertencer ao mesmo team') unless office.team == user.team
  end
end
