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

  belongs_to :user, inverse_of: :user_profile
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

  # Polymorphic associations for addresses and phones
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :phones, as: :phoneable, dependent: :destroy

  has_many :user_bank_accounts, dependent: :destroy
  has_many :bank_accounts, through: :user_bank_accounts

  has_many :user_profile_works, dependent: :destroy
  has_many :works, through: :user_profile_works

  has_many :job_user_profiles, dependent: :destroy
  has_many :jobs, through: :job_user_profiles

  # Nested attributes for API
  accepts_nested_attributes_for :phones,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['phone_number'].blank? }

  accepts_nested_attributes_for :addresses,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['street'].blank? || attrs['city'].blank? }

  accepts_nested_attributes_for :bank_accounts,
                                allow_destroy: true,
                                reject_if: :all_blank

  accepts_nested_attributes_for :user,
                                reject_if: :all_blank

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

  def last_phone
    return I18n.t('general.without_phone') if phones.blank?

    phones.last.phone_number
  end

  private

  def office_same_team
    errors.add(:office, 'deve pertencer ao mesmo team') unless office.team == user.team
  end
end
