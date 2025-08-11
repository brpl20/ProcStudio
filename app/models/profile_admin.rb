# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_admins
#
#  id                   :bigint(8)        not null, primary key
#  role                 :string
#  name                 :string
#  last_name            :string
#  gender               :string
#  oab                  :string
#  rg                   :string
#  cpf                  :string
#  nationality          :string
#  civil_status         :string
#  birth                :date
#  mother_name          :string
#  status               :string
#  admin_id             :bigint(8)        not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  office_id            :bigint(8)
#  origin               :string
#  deleted_at           :datetime
#  individual_entity_id :bigint(8)
#  legal_entity_id      :bigint(8)
#
class ProfileAdmin < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :admin
  belongs_to :office, optional: true
  belongs_to :individual_entity, optional: true
  belongs_to :legal_entity, optional: true

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
    inactive: 'inactive'
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

  has_many :profile_admin_works, dependent: :destroy
  has_many :works, through: :profile_admin_works

  has_many :jobs, dependent: :destroy

  accepts_nested_attributes_for :admin, reject_if: :all_blank
  accepts_nested_attributes_for :individual_entity, reject_if: :all_blank

  scope :by_team, ->(team) { 
    joins(admin: :team_memberships)
    .where(team_memberships: { team_id: team.id, status: 'active' })
  }

  # Only validate ProfileAdmin-specific fields, personal data is validated in IndividualEntity
  validates :oab, presence: true, if: :lawyer?
  validates :role, presence: true

  def full_name
    individual_entity&.full_name || "#{name} #{last_name}".squish
  end

  def last_email
    return I18n.t('general.without_email') unless individual_entity&.emails&.present?

    individual_entity.emails.last.address
  end

  def emails_attributes=(attributes)
    current_email_ids = attributes.map { |attr| attr[:id].to_i }.compact
    admin_emails.where.not(email_id: current_email_ids).destroy_all

    super(attributes)
  end

  def phones_attributes=(attributes)
    current_phone_ids = attributes.map { |attr| attr[:id].to_i }.compact

    admin_phones.where.not(phone_id: current_phone_ids).destroy_all

    super(attributes)
  end
end
