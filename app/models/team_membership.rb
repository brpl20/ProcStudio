# frozen_string_literal: true

# == Schema Information
#
# Table name: team_memberships
#
#  id         :bigint(8)        not null, primary key
#  team_id    :bigint(8)        not null
#  admin_id   :bigint(8)        not null
#  role       :string           default("member"), not null
#  status     :string           default("active")
#  joined_at  :datetime
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TeamMembership < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team
  belongs_to :admin
  
  validates :role, presence: true, 
            inclusion: { in: %w[owner admin manager member] }
  validates :status, inclusion: { in: %w[active inactive pending] }
  validates :admin_id, uniqueness: { scope: :team_id }
  
  scope :active, -> { where(status: 'active') }
  scope :pending, -> { where(status: 'pending') }
  scope :by_role, ->(role) { where(role: role) }
  scope :owners, -> { where(role: 'owner') }
  scope :admins, -> { where(role: 'admin') }
  scope :managers, -> { where(role: 'manager') }
  scope :members, -> { where(role: 'member') }
  
  before_save :set_joined_at
  
  def active?
    status == 'active'
  end
  
  def pending?
    status == 'pending'
  end
  
  def inactive?
    status == 'inactive'
  end
  
  def owner?
    role == 'owner'
  end
  
  def admin?
    role == 'admin'
  end
  
  def manager?
    role == 'manager'
  end
  
  def member?
    role == 'member'
  end
  
  def can_manage_team?
    owner? || admin?
  end
  
  def can_invite_users?
    owner? || admin? || manager?
  end
  
  def can_manage_works?
    owner? || admin? || manager?
  end
  
  private
  
  def set_joined_at
    self.joined_at ||= Time.current if status_changed? && active?
  end
end
