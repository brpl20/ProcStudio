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
#
class Customer < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_one :profile_customer, dependent: :destroy

  delegate :full_name, to: :profile_customer, prefix: true, allow_nil: true

  before_validation :setup_password, if: :new_record?

  # Setup a random password for the customer if such is not present. This is
  # necessary because we want to not override Devise's defaults, also, customers will
  # configure their passwords as part of our 'first access' workflow.
  #
  # @return [void]
  def setup_password
    return if password.present?

    self.password = Devise.friendly_token.first(24)
  end
end
