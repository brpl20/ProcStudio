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
#  status                 :string           default("active"), not null
#
class Admin < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum status: {
    active: 'active',
    inactive: 'inactive'
  }

  alias_attribute :access_email, :email

  has_one :profile_admin, dependent: :destroy
  
  # Team relationships
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships
  has_many :owned_teams, class_name: 'Team', foreign_key: 'owner_admin_id'
  has_many :main_teams, class_name: 'Team', foreign_key: 'main_admin_id'
  
  # Contact info through polymorphic relationship
  has_many :contact_infos, as: :contactable, dependent: :destroy
  has_many :addresses, -> { where(contact_type: 'address') }, 
           class_name: 'ContactInfo', as: :contactable
  has_many :emails, -> { where(contact_type: 'email') }, 
           class_name: 'ContactInfo', as: :contactable
  has_many :phones, -> { where(contact_type: 'phone') }, 
           class_name: 'ContactInfo', as: :contactable
  has_many :bank_accounts, -> { where(contact_type: 'bank_account') }, 
           class_name: 'ContactInfo', as: :contactable
  
  # Wiki relationships
  has_many :created_wiki_pages, class_name: 'WikiPage', foreign_key: 'created_by_id'
  has_many :updated_wiki_pages, class_name: 'WikiPage', foreign_key: 'updated_by_id'
  has_many :wiki_revisions, class_name: 'WikiPageRevision', foreign_key: 'created_by_id'

  validates :email, presence: true
  validates :status, inclusion: { in: %w[active inactive suspended] }
  accepts_nested_attributes_for :profile_admin, reject_if: :all_blank

  delegate :role, to: :profile_admin, allow_nil: true

  before_destroy :update_created_by_records

  def current_team
    team_memberships.active.first&.team
  end
  
  def team_role(team)
    team_memberships.find_by(team: team)&.role
  end
  
  def can_access_team?(team)
    team_memberships.active.exists?(team: team)
  end
  
  def primary_email
    emails.primary.first&.display_value || email
  end
  
  def primary_phone
    phones.primary.first&.display_value
  end
  
  def primary_address
    addresses.primary.first&.display_value
  end

  private

  def update_created_by_records
    Work.where(created_by_id: id).update_all(created_by_id: nil)
    Customer.where(created_by_id: id).update_all(created_by_id: nil)
    Job.where(created_by_id: id).update_all(created_by_id: nil)
    ProfileCustomer.where(created_by_id: id).update_all(created_by_id: nil)
  end
end
