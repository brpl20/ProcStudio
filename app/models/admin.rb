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
#  deleted_at             :datetime
#  role                   :string           default("admin")
#
class Admin < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    admin: 'admin',
    super_admin: 'super_admin'
  }

  alias_attribute :access_email, :email

  has_one :profile_admin, dependent: :destroy

  # Team relationships
  has_one :team, through: :team_memberships
  has_one :team_membership, dependent: :destroy

  # Wiki relationships
  # has_many :created_wiki_pages, class_name: 'WikiPage', foreign_key: 'created_by_id'
  # has_many :updated_wiki_pages, class_name: 'WikiPage', foreign_key: 'updated_by_id'
  # has_many :wiki_revisions, class_name: 'WikiPageRevision', foreign_key: 'created_by_id'

  validates :email, presence: true
  accepts_nested_attributes_for :profile_admin, reject_if: :all_blank

  before_destroy :update_created_by_records

  def current_team
    team_membership.active.first&.team
  end

  def can_access_team?(team)
    team_memberships.active.exists?(team: team)
  end

  private

  def update_created_by_records
    Work.where(created_by_id: id).update_all(created_by_id: nil)
    Customer.where(created_by_id: id).update_all(created_by_id: nil)
    Job.where(created_by_id: id).update_all(created_by_id: nil)
    ProfileCustomer.where(created_by_id: id).update_all(created_by_id: nil)
  end
end
