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
    curatorship: 'curatorship', # Court-appointed curator
    tutorship: 'tutorship' # Court-appointed tutor
  }

  # Validations
  validates :relationship_type, presence: true
  validates :representor_id, uniqueness: {
    scope: [:profile_customer_id, :active],
    conditions: -> { where(active: true) },
    message: 'já está representando este cliente'
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
    self.team_id ||= profile_customer&.customer&.teams&.first&.id
  end

  def validate_representor_capacity
    return unless representor

    return unless representor.capacity != 'able'

    errors.add(:representor_id, 'deve ser legalmente capaz (maior de 18 anos)')
  end

  def validate_dates
    return unless start_date.present? && end_date.present?

    return unless end_date < start_date

    errors.add(:end_date, 'não pode ser anterior à data de início')
  end

  def prevent_self_representation
    return unless profile_customer_id == representor_id

    errors.add(:representor_id, 'não pode representar a si mesmo')
  end

  def notify_compliance_if_needed
    # Notify compliance team when a new representation is created
    return unless ['unable', 'relatively'].include?(profile_customer.capacity)

    create_compliance_notification('new_representation')
  end

  def notify_compliance_on_changes
    # Notify compliance team when representation is deactivated
    return unless saved_change_to_active? && !active

    create_compliance_notification('representation_ended')
  end

  def create_compliance_notification(compliance_type)
    return unless team

    title = notification_title(compliance_type)
    description = notification_description(compliance_type)
    
    # Notify team admins about representation changes
    team.users.joins(:user_profile).where(user_profiles: { role: ['lawyer', 'super_admin'] }).each do |user|
      next unless user.user_profile
      
      Notification.create!(
        user_profile: user.user_profile,
        notification_type: 'compliance',
        title: title,
        body: description,
        priority: '1', # Normal priority for representation changes
        sender_type: 'Represent',
        sender_id: id,
        action_url: "/customers/#{profile_customer_id}/represents",
        data: {
          compliance_type: compliance_type,
          profile_customer_id: profile_customer_id,
          profile_customer_name: profile_customer&.name,
          representor_id: representor_id,
          representor_name: representor&.name,
          relationship_type: relationship_type,
          active: active
        }
      )
    end
  rescue StandardError => e
    Rails.logger.error "Failed to create compliance notification: #{e.message}"
  end

  def notification_title(type)
    case type
    when 'new_representation'
      "New #{relationship_type} established"
    when 'representation_ended'
      "#{relationship_type.capitalize} terminated"
    else
      'Representation status changed'
    end
  end

  def notification_description(type)
    customer_name = profile_customer&.full_name
    representor_name = representor&.full_name

    case type
    when 'new_representation'
      "#{representor_name} is now the #{relationship_type} for #{customer_name}"
    when 'representation_ended'
      "#{representor_name} is no longer the #{relationship_type} for #{customer_name}"
    else
      'Representation relationship updated'
    end
  end
end
