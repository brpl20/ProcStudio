# frozen_string_literal: true

# == Schema Information
#
# Table name: compliance_notifications
#
#  id                :bigint           not null, primary key
#  description       :text             not null
#  ignored_at        :datetime
#  metadata          :json
#  notification_type :string           not null
#  resolved_at       :datetime
#  resource_type     :string
#  status            :string           default("pending"), not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  resource_id       :bigint
#  team_id           :bigint           not null
#  user_id           :bigint
#
# Indexes
#
#  idx_on_resource_type_resource_id_a14cb9f6d9          (resource_type,resource_id)
#  index_compliance_notifications_on_notification_type  (notification_type)
#  index_compliance_notifications_on_status             (status)
#  index_compliance_notifications_on_team_id            (team_id)
#  index_compliance_notifications_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
class ComplianceNotification < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :team

  # Polymorphic association to track any resource
  belongs_to :resource, polymorphic: true, optional: true

  enum :status, {
    pending: 'pending',
    resolved: 'resolved',
    ignored: 'ignored'
  }

  enum :notification_type, {
    capacity_change: 'capacity_change',
    age_transition: 'age_transition',
    manual_capacity_update: 'manual_capacity_update',
    lawyer_removal: 'lawyer_removal',
    lawyer_retirement: 'lawyer_retirement',
    trainee_promotion: 'trainee_promotion',
    company_manager_change: 'company_manager_change',
    contract_cancellation: 'contract_cancellation',
    new_representation: 'new_representation',
    representation_ended: 'representation_ended'
  }

  validates :title, presence: true
  validates :description, presence: true
  validates :notification_type, presence: true
  validates :status, presence: true

  scope :active, -> { where(status: 'pending') }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_team, ->(team) { where(team: team) }
  scope :recent, -> { order(created_at: :desc) }

  # Mark as resolved
  def resolve!
    update!(status: 'resolved', resolved_at: Time.current)
  end

  # Mark as ignored
  def ignore!
    update!(status: 'ignored', ignored_at: Time.current)
  end

  # Check if actionable
  def actionable?
    status == 'pending'
  end

  # Get associated profile customer if applicable
  def profile_customer
    return nil unless resource_type == 'ProfileCustomer'

    resource
  end
end
