# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  jwt_token              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  status                 :string           default("active"), not null
#  unconfirmed_email      :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  created_by_id          :bigint
#
# Indexes
#
#  index_customers_on_confirmation_token       (confirmation_token) UNIQUE
#  index_customers_on_created_by_id            (created_by_id)
#  index_customers_on_deleted_at               (deleted_at)
#  index_customers_on_email_where_not_deleted  (email) UNIQUE WHERE (deleted_at IS NULL)
#  index_customers_on_reset_password_token     (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
class Customer < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable

  alias_attribute :access_email, :email

  has_one :profile_customer, dependent: :destroy
  has_many :team_customers, dependent: :destroy
  has_many :teams, through: :team_customers

  delegate :full_name, to: :profile_customer, prefix: true, allow_nil: true

  before_validation :setup_password, if: :new_record?

  validates :email, uniqueness: {
    conditions: -> { where(deleted_at: nil) },
    unless: :unable_person?
  }

  # From Devise module Validatable
  validates :email, presence: { if: :email_required? }
  validates :email, format: { with: Devise.email_regexp, allow_blank: true, if: :email_changed? }
  validates :password, presence: { if: :password_required? }
  validates :password, confirmation: { if: :password_required? }
  validates       :password, length: { minimum: proc { Devise.password_length.min }, maximum: proc {
    Devise.password_length.max
  }, allow_blank: true }

  enum :status, {
    active: 'active',
    inactive: 'inactive'
  }

  # Setup a random password for the customer if such is not present. This is
  # necessary because we want to not override Devise's defaults, also, customers will
  # configure their passwords as part of our 'first access' workflow.
  #
  # @return [void]
  def setup_password
    return if password.present?

    self.password = Devise.friendly_token.first(24)
  end

  # From Devise module Validatable

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end

  # Check if this customer is an unable person (minor or incapacitated)
  # Used to allow email sharing with their guardian
  def unable_person?
    profile_customer&.unable?
  end
end
