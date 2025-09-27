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
#  draftable_id   :bigint
#  team_id        :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_drafts_new_records              (team_id,user_id,form_type,draftable_type) WHERE (draftable_id IS NULL)
#  index_drafts_on_customer_id           (customer_id)
#  index_drafts_on_draftable             (draftable_type,draftable_id)
#  index_drafts_on_expires_at            (expires_at)
#  index_drafts_on_status                (status)
#  index_drafts_on_team_id               (team_id)
#  index_drafts_on_user_id               (user_id)
#  index_drafts_unique_existing_records  (team_id,draftable_type,draftable_id,form_type) UNIQUE WHERE (draftable_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (team_id => teams.id)
#  fk_rails_...  (user_id => users.id)
#
class Draft < ApplicationRecord
  belongs_to :draftable, polymorphic: true, optional: true
  belongs_to :user, optional: true
  belongs_to :customer, optional: true
  belongs_to :team, optional: true

  enum :status, {
    draft: 'draft',
    recovered: 'recovered',
    expired: 'expired',
    fullfiled: 'fullfiled' # when user finish the operation sucessfully and does not need the draft anymor
  }

  validates :form_type, presence: true
  validates :data, presence: true
  validate :draftable_presence_for_existing_records

  scope :active, -> { where(status: 'draft').where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where(expires_at: ...Time.current) }
  scope :unfulfilled, -> { where.not(status: 'fullfiled') }
  scope :for_new_records, -> { where(draftable_id: nil) }
  scope :for_existing_records, -> { where.not(draftable_id: nil) }

  before_validation :set_default_expiration

  def self.save_draft(form_type:, data:, draftable: nil, user: nil, customer: nil, team: nil, session_id: nil)
    # Determine team from user or customer if not provided
    team ||= determine_team(user, customer)

    # For new records (no draftable), use session_id or generate one
    if draftable.nil?
      session_id ||= SecureRandom.uuid
      draft = find_or_initialize_by(
        draftable_type: form_type.to_s.split('_').first.camelize,
        draftable_id: nil,
        form_type: form_type,
        team: team,
        user: user
      )
      draft.data = draft.data.to_h.merge('session_id' => session_id)
    else
      # For existing records
      draft = find_or_initialize_by(
        draftable: draftable,
        form_type: form_type,
        team: team
      )
    end

    draft.update!(
      data: draft.data.to_h.merge(data.to_h),
      user: user,
      customer: customer,
      status: 'draft',
      expires_at: 30.days.from_now
    )

    draft
  end

  def self.find_draft_for_new_record(form_type:, user:, team: nil, session_id: nil)
    scope = where(form_type: form_type, draftable_id: nil, user: user, status: 'draft')
    scope = scope.where(team: team) if team

    if session_id
      scope.find { |draft| draft.data['session_id'] == session_id }
    else
      scope.first
    end
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

  def fulfill!(created_record = nil)
    transaction do
      if created_record && draftable_id.nil?
        # Update the draft to point to the newly created record
        update!(
          draftable: created_record,
          status: 'fullfiled'
        )
      else
        # Just mark as fulfilled
        update!(status: 'fullfiled')
      end
    end
  end

  def fulfilled?
    status == 'fullfiled'
  end

  def for_new_record?
    draftable_id.nil?
  end

  def session_id
    data['session_id'] if for_new_record?
  end

  private

  def set_default_expiration
    self.expires_at ||= 30.days.from_now
  end

  def draftable_presence_for_existing_records
    # Only validate draftable presence if draftable_id is present
    # This allows drafts for new records (draftable_id: nil)
    return unless draftable_id.present? && draftable.nil?

    errors.add(:draftable, 'must exist for drafts with draftable_id')
  end
end
