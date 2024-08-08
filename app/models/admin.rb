# frozen_string_literal: true

# == Schema Information
#
# Table name: admins
#
#  id                     :bigint(8)        not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  jwt_token              :string
#
class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile_admin, dependent: :destroy

  validates :email, presence: true
  accepts_nested_attributes_for :profile_admin, reject_if: :all_blank

  delegate :role, to: :profile_admin, allow_nil: true

  before_destroy :update_created_by_records

  private

  def update_created_by_records
    Work.where(created_by_id: id).update_all(created_by_id: nil)
    Customer.where(created_by_id: id).update_all(created_by_id: nil)
    Job.where(created_by_id: id).update_all(created_by_id: nil)
    ProfileCustomer.where(created_by_id: id).update_all(created_by_id: nil)
  end
end
