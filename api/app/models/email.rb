# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id             :bigint           not null, primary key
#  deleted_at     :datetime
#  email          :string
#  email_type     :string           default("main")
#  emailable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  emailable_id   :bigint
#
# Indexes
#
#  index_emails_on_deleted_at  (deleted_at)
#  index_emails_on_emailable   (emailable_type,emailable_id)
#

class Email < ApplicationRecord
  # Soft delete support (if you're using paranoia gem)
  acts_as_paranoid if defined?(Paranoia)

  # Polymorphic association
  belongs_to :emailable, polymorphic: true

  # Explicitly declare string attribute for enum (Rails 7.2+ requirement)
  attribute :email_type, :string, default: 'main'

  # Enums for email types
  enum :email_type, {
    main: 'main',
    secondary: 'secondary',
    work: 'work',
    personal: 'personal'
  }, default: 'main'

  # Validations
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { scope: [:emailable_type, :emailable_id] }

  # Normalize email before saving
  before_save :normalize_email

  # Scopes for querying
  scope :for_offices, -> { where(emailable_type: 'Office') }
  scope :for_customers, -> { where(emailable_type: 'ProfileCustomer') }
  scope :for_users, -> { where(emailable_type: 'UserProfile') }
  scope :main_emails, -> { where(email_type: 'main') }
  scope :work_emails, -> { where(email_type: 'work') }

  # Instance methods
  def domain
    email.split('@').last if email.present?
  end

  def username
    email.split('@').first if email.present?
  end

  def obfuscated
    return nil if email.blank?

    parts = email.split('@')
    username = parts[0]
    domain = parts[1]

    if username.length > 3
      "#{username[0..2]}***@#{domain}"
    else
      "***@#{domain}"
    end
  end

  def mailto_link(subject: nil, body: nil)
    params = {}
    params[:subject] = subject if subject.present?
    params[:body] = body if body.present?

    if params.any?
      query = URI.encode_www_form(params)
      "mailto:#{email}?#{query}"
    else
      "mailto:#{email}"
    end
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
