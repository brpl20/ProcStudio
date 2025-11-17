# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id            :bigint           not null, primary key
#  avatar_s3_key :string
#  birth         :date
#  civil_status  :string
#  cpf           :string
#  deleted_at    :datetime
#  gender        :string
#  last_name     :string
#  mother_name   :string
#  name          :string
#  nationality   :string
#  oab           :string
#  origin        :string
#  rg            :string
#  role          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  office_id     :bigint
#  user_id       :bigint           not null
#
# Indexes
#
#  index_user_profiles_on_avatar_s3_key  (avatar_s3_key)
#  index_user_profiles_on_deleted_at     (deleted_at)
#  index_user_profiles_on_office_id      (office_id)
#  index_user_profiles_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (user_id => users.id)
#

class UserProfile < ApplicationRecord
  include DeletedFilterConcern
  include Draftable

  acts_as_paranoid

  # Define draftable form types
  draft_form_types :profile_edit, :complete_profile, :bank_account_setup, :address_update

  belongs_to :user, inverse_of: :user_profile
  belongs_to :office, optional: true

  # New S3 file management system
  has_many :file_metadata, as: :attachable, dependent: :destroy
  has_many :notifications, dependent: :destroy

  delegate :team, to: :user
  delegate :status, :active?, :inactive?, to: :user

  validate :office_same_team, if: -> { office.present? }

  enum :role, {
    lawyer: 'lawyer',
    paralegal: 'paralegal',
    trainee: 'trainee',
    secretary: 'secretary',
    counter: 'counter',
    excounter: 'excounter',
    representant: 'representant'
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

  # Polymorphic associations for addresses, phones, emails, and bank accounts
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :phones, as: :phoneable, dependent: :destroy
  has_many :emails, as: :emailable, dependent: :destroy
  has_many :bank_accounts, as: :bankable, dependent: :destroy

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

  accepts_nested_attributes_for :emails,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['email'].blank? }

  accepts_nested_attributes_for :bank_accounts,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs['bank_name'].blank? || attrs['account'].blank? }

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

  def last_email
    return I18n.t('general.without_email') if emails.blank?

    emails.last.email
  end

  # S3 File Management Methods

  def avatar
    file_metadata.by_category('avatar').first
  end

  def upload_avatar(file, user_profile: nil, **options)
    # Delete old avatar if exists
    avatar&.destroy

    # Upload new avatar
    # Note: user_profile parameter can be self or another UserProfile (e.g., admin uploading for user)
    S3Manager.upload(
      file,
      model: self,
      user_profile: user_profile || self,
      metadata: options.merge(file_type: 'avatar')
    )
  end

  def avatar_url(expires_in: 3600)
    avatar&.url(expires_in: expires_in)
  end

  def delete_avatar
    avatar&.destroy
  end

  private

  def office_same_team
    errors.add(:office, 'deve pertencer ao mesmo team') unless office.team == user.team
  end
end
