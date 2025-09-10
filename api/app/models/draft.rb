# frozen_string_literal: true

# == Schema Information
#
# Table name: drafts
#
#  id             :bigint           not null, primary key
#  data           :json             not null
#  draftable_type :string           not null
#  expires_at     :datetime
#  form_type      :string           not null
#  status         :string           default("draft")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  customer_id    :bigint
#  draftable_id   :bigint           not null
#  team_id        :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_drafts_on_customer_id         (customer_id)
#  index_drafts_on_draftable           (draftable_type,draftable_id)
#  index_drafts_on_expires_at          (expires_at)
#  index_drafts_on_status              (status)
#  index_drafts_on_team_id             (team_id)
#  index_drafts_on_user_id             (user_id)
#  index_drafts_unique_form_with_team  (team_id,draftable_type,draftable_id,form_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
class Draft < ApplicationRecord
  belongs_to :draftable, polymorphic: true
  belongs_to :user, optional: true
  belongs_to :customer, optional: true
  belongs_to :team, optional: true

  enum :status, {
    draft: 'draft',
    recovered: 'recovered',
    expired: 'expired'
  }

  validates :form_type, presence: true
  validates :data, presence: true

  scope :active, -> { where(status: 'draft').where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where(expires_at: ...Time.current) }

  before_validation :set_default_expiration

  def self.save_draft(draftable:, form_type:, data:, user: nil, customer: nil, team: nil)
    # Determine team from user or customer if not provided
    team ||= determine_team(user, customer)

    draft = find_or_initialize_by(
      draftable: draftable,
      form_type: form_type,
      team: team
    )

    draft.update!(
      data: data,
      user: user,
      customer: customer,
      status: 'draft',
      expires_at: 30.days.from_now
    )

    draft
  end

  def self.determine_team(user, customer)
    if user.respond_to?(:team)
      user.team
    elsif customer
      # Get team from customer's team_customer association
      TeamCustomer.find_by(customer: customer)&.team
    else
      Team.find_by(name: 'Default') # Fallback to default team if exists
    end
  end

  def recover!
    update!(status: 'recovered')
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def mark_expired!
    update!(status: 'expired')
  end

  private

  def set_default_expiration
    self.expires_at ||= 30.days.from_now
  end
end
