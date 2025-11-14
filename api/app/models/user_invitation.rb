# frozen_string_literal: true

# == Schema Information
#
# Table name: user_invitations
#
#  id            :bigint           not null, primary key
#  accepted_at   :datetime
#  deleted_at    :datetime
#  email         :string           not null
#  expires_at    :datetime         not null
#  metadata      :jsonb
#  status        :string           default("pending"), not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :bigint           not null
#  team_id       :bigint           not null
#
# Indexes
#
#  index_user_invitations_on_deleted_at                    (deleted_at)
#  index_user_invitations_on_email                         (email)
#  index_user_invitations_on_email_and_team_id_and_status  (email,team_id,status)
#  index_user_invitations_on_invited_by_id                 (invited_by_id)
#  index_user_invitations_on_status                        (status)
#  index_user_invitations_on_team_id                       (team_id)
#  index_user_invitations_on_token                         (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
class UserInvitation < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Associations
  belongs_to :invited_by, class_name: 'User'
  belongs_to :team

  # Enums
  enum :status, {
    pending: 'pending',
    accepted: 'accepted',
    expired: 'expired'
  }

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :status, presence: true

  validate :email_not_already_registered, on: :create
  validate :no_pending_invitation_for_email, on: :create

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :not_expired, -> { where('expires_at > ?', Time.current) }
  scope :valid_invitations, -> { pending.not_expired }
  scope :for_email, ->(email) { where(email: email.downcase) }
  scope :for_team, ->(team_id) { where(team_id: team_id) }

  # Instance methods
  def expired?
    expires_at < Time.current
  end

  def valid_for_acceptance?
    pending? && !expired?
  end

  def mark_as_accepted!
    update!(status: :accepted, accepted_at: Time.current)
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
      break random_token unless UserInvitation.exists?(token: random_token)
    end
  end

  def set_expiration
    self.expires_at ||= 7.days.from_now
  end

  def email_not_already_registered
    return unless email.present?

    normalized_email = email.downcase.strip
    return unless User.exists?(email: normalized_email)

    errors.add(:email, 'já está cadastrado na plataforma')
  end

  def no_pending_invitation_for_email
    return unless email.present? && team_id.present?

    normalized_email = email.downcase.strip
    existing = UserInvitation.valid_invitations
                             .for_email(normalized_email)
                             .for_team(team_id)
                             .where.not(id: id)

    return unless existing.exists?

    errors.add(:email, 'já possui um convite pendente')
  end
end
