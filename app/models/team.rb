# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id             :bigint(8)        not null, primary key
#  name           :string           not null
#  subdomain      :string           not null
#  main_admin_id  :bigint(8)        not null
#  owner_admin_id :bigint(8)        not null
#  status         :string           default("active")
#  settings       :json
#  deleted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Team < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :main_admin, class_name: 'Admin'
  belongs_to :owner_admin, class_name: 'Admin'
  
  has_many :team_memberships, dependent: :destroy
  has_many :admins, through: :team_memberships
  has_many :offices, dependent: :restrict_with_exception
  has_many :works, through: :offices
  has_many :subscriptions, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :email_logs, dependent: :destroy
  has_many :wiki_pages, dependent: :destroy
  has_many :wiki_categories, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: 'must contain only lowercase letters, numbers, and hyphens (no consecutive hyphens)' },
            length: { minimum: 3, maximum: 50 }
  validates :status, inclusion: { in: %w[active inactive suspended] }
  
  scope :active, -> { where(status: 'active') }
  scope :by_subdomain, ->(subdomain) { where(subdomain: subdomain) }
  
  before_validation :normalize_subdomain
  
  def active?
    status == 'active'
  end
  
  def inactive?
    status == 'inactive'
  end
  
  def suspended?
    status == 'suspended'
  end
  
  def subscription
    subscriptions.active.first
  end
  
  def current_subscription
    subscription
  end
  
  def can_add_users?
    return true unless current_subscription
    
    admins.count < current_subscription.subscription_plan.max_users
  end
  
  def can_add_offices?
    return true unless current_subscription
    
    offices.count < current_subscription.subscription_plan.max_offices
  end
  
  def admin_role(admin)
    team_memberships.find_by(admin: admin)&.role
  end
  
  def owner?(admin)
    owner_admin == admin
  end
  
  def main_admin?(admin)
    main_admin == admin
  end
  
  def admin?(admin)
    owner?(admin) || main_admin?(admin) || admin_role(admin) == 'admin'
  end
  
  def member?(admin)
    team_memberships.active.exists?(admin: admin)
  end
  
  private
  
  def normalize_subdomain
    return unless subdomain
    
    self.subdomain = subdomain.downcase.strip
  end
end
