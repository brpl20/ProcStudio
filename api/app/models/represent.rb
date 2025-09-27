# frozen_string_literal: true

# == Schema Information
#
# Table name: represents
#
#  id                  :bigint           not null, primary key
#  active              :boolean          default(TRUE), not null
#  end_date            :date
#  notes               :text
#  relationship_type   :string           default("representation")
#  start_date          :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_customer_id :bigint           not null
#  representor_id      :bigint
#  team_id             :bigint
#
# Indexes
#
#  index_represents_on_active                          (active)
#  index_represents_on_profile_customer_id             (profile_customer_id)
#  index_represents_on_profile_customer_id_and_active  (profile_customer_id,active)
#  index_represents_on_relationship_type               (relationship_type)
#  index_represents_on_representor_id                  (representor_id)
#  index_represents_on_representor_id_and_active       (representor_id,active)
#  index_represents_on_team_id                         (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#  fk_rails_...  (representor_id => profile_customers.id)
#  fk_rails_...  (team_id => teams.id)
#

class Represent < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :representor, class_name: 'ProfileCustomer'
  belongs_to :team

  # Enums
  enum :relationship_type, {
    representation: 'representation', # Full legal representation (for unable persons)
    assistance: 'assistance',         # Legal assistance (for relatively incapable)
    curatorship: 'curatorship',       # Court-appointed curator
    tutorship: 'tutorship'            # Court-appointed tutor
  }

  # Validations
  validates :relationship_type, presence: true
  # NOTE: Multiple representors per client are allowed (e.g., father and mother representing a minor)
  # This validation only prevents the SAME representor from having duplicate active representations of the SAME client
  validates :representor_id, uniqueness: {
    scope: [:profile_customer_id, :active],
    conditions: -> { where(active: true) },
    message: -> { I18n.t('pundit.represent.already_representing') }
  }
  validate :validate_representor_capacity
  validate :validate_dates
  validate :prevent_self_representation

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :current, lambda {
    active.where('start_date IS NULL OR start_date <= ?', Date.current)
      .where('end_date IS NULL OR end_date >= ?', Date.current)
  }
  scope :by_team, ->(team_id) { where(team_id: team_id) }
  scope :for_customer, ->(customer_id) { where(profile_customer_id: customer_id) }
  scope :by_representor, ->(representor_id) { where(representor_id: representor_id) }

  # Callbacks
  before_validation :set_defaults
  after_create :notify_compliance_if_needed
  after_update :notify_compliance_on_changes

  private

  def set_defaults
    self.start_date ||= Date.current
  end

  def validate_representor_capacity
    return unless representor

    return unless representor.capacity != 'able'

    errors.add(:representor_id, I18n.t('pundit.represent.representor_must_be_capable'))
  end

  def validate_dates
    return unless start_date.present? && end_date.present?

    return unless end_date < start_date

    errors.add(:end_date, I18n.t('pundit.represent.end_date_before_start_date'))
  end

  def prevent_self_representation
    return unless profile_customer_id == representor_id

    errors.add(:representor_id, I18n.t('pundit.represent.cannot_represent_self'))
  end

  def notify_compliance_if_needed
    NotificationService.notify_representation_change(
      represent: self,
      notification_type: 'new_representation'
    )
  end

  def notify_compliance_on_changes
    return unless saved_change_to_active? && !active

    NotificationService.notify_representation_change(
      represent: self,
      notification_type: 'representation_ended'
    )
  end
end
