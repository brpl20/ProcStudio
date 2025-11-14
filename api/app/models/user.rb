# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  jwt_token              :string
#  oab                    :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  status                 :string           default("active"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  team_id                :bigint           not null
#
# Indexes
#
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_jwt_token             (jwt_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_team_id               (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class User < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :status, {
    active: 'active',
    inactive: 'inactive'
  }

  alias_attribute :access_email, :email

  belongs_to :team
  has_one :user_profile, dependent: :destroy, inverse_of: :user
  has_many :user_offices, dependent: :destroy
  has_many :offices, through: :user_offices

  # Referral system
  has_many :sent_referrals, class_name: 'ReferralInvitation', foreign_key: :referred_by_id, dependent: :destroy
  has_one :received_referral, class_name: 'ReferralInvitation', foreign_key: :referred_user_id, dependent: :nullify

  validates :email, presence: true
  accepts_nested_attributes_for :user_profile, reject_if: :all_blank

  delegate :role, to: :user_profile, allow_nil: true

  before_destroy :update_created_by_records

  private

  # rubocop:disable all
  # TODO: Fix soft delete and destroy methods here
  def update_created_by_records
    Work.where(created_by_id: id).update_all(created_by_id: nil)
    Customer.where(created_by_id: id).update_all(created_by_id: nil)
    Job.where(created_by_id: id).update_all(created_by_id: nil)
    ProfileCustomer.where(created_by_id: id).update_all(created_by_id: nil)
  end
end
