# frozen_string_literal: true

# == Schema Information
#
# Table name: referral_invitations
#
#  id               :bigint           not null, primary key
#  accepted_at      :datetime
#  converted_at     :datetime
#  deleted_at       :datetime
#  email            :string           not null
#  expires_at       :datetime         not null
#  metadata         :jsonb
#  reward_earned    :boolean          default(FALSE)
#  status           :string           default("pending"), not null
#  token            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  referred_by_id   :bigint           not null
#  referred_user_id :bigint
#
# Indexes
#
#  index_referral_invitations_on_deleted_at        (deleted_at)
#  index_referral_invitations_on_email             (email)
#  index_referral_invitations_on_referred_by_id    (referred_by_id)
#  index_referral_invitations_on_referred_user_id  (referred_user_id)
#  index_referral_invitations_on_reward_earned     (reward_earned)
#  index_referral_invitations_on_status            (status)
#  index_referral_invitations_on_token             (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (referred_by_id => users.id)
#  fk_rails_...  (referred_user_id => users.id)
#
class ReferralInvitation < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Associations
  belongs_to :referred_by, class_name: 'User'
  belongs_to :referred_user, class_name: 'User', optional: true

  # Enums
  enum :status, {
    pending: 'pending',
    accepted: 'accepted',
    converted: 'converted', # They subscribed to Pro
    expired: 'expired'
  }

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create
  before_validation :normalize_email, on: :create

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :not_expired, -> { where('expires_at > ?', Time.current) }
  scope :valid_invitations, -> { pending.not_expired }
  scope :converted, -> { where(status: 'converted') }
  scope :with_reward, -> { where(reward_earned: true) }
  scope :for_email, ->(email) { where(email: email.downcase) }

  # Instance methods
  def expired?
    expires_at < Time.current
  end

  def valid_for_acceptance?
    pending? && !expired?
  end

  def mark_as_accepted!(user)
    update!(
      status: :accepted,
      accepted_at: Time.current,
      referred_user: user
    )
  end

  def mark_as_converted!
    return false unless accepted?
    return false if reward_earned? # Already rewarded

    transaction do
      update!(
        status: :converted,
        converted_at: Time.current,
        reward_earned: true
      )

      # Award free month to referrer
      award_free_month_to_referrer!
    end

    true
  end

  def mark_as_expired!
    update!(status: :expired)
  end

  def days_until_expiration
    return 0 if expired?

    ((expires_at - Time.current) / 1.day).ceil
  end

  private

  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.urlsafe_base64(32)
      break random_token unless ReferralInvitation.exists?(token: random_token)
    end
  end

  def set_expiration
    self.expires_at ||= 30.days.from_now # Longer expiration for referrals
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def award_free_month_to_referrer!
    referrer_team = referred_by.team
    subscription = referrer_team.subscription

    if subscription.present?
      subscription.add_free_month!
      Rails.logger.info("[Referral] Awarded 1 free month to user #{referred_by.id} for referral #{id}")
    else
      Rails.logger.warn("[Referral] No subscription found for referrer team #{referrer_team.id}")
    end
  end
end
