# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id                     :bigint(8)        not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  jwt_token              :string
#  created_by_id          :bigint(8)
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :datetime
#  status                 :string           default("active"), not null
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

  delegate :full_name, to: :profile_customer, prefix: true, allow_nil: true

  before_validation :setup_password, if: :new_record?

  validates_uniqueness_of :email, conditions: -> { where(deleted_at: nil) }

  # From Devise module Validatable
  validates_presence_of     :email, if: :email_required?
  validates_format_of       :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?
  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, minimum: proc { Devise.password_length.min }, maximum: proc { Devise.password_length.max }, allow_blank: true

  enum status: {
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
end
