# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                   :bigint(8)        not null, primary key
#  team_id              :bigint(8)        not null
#  subscription_plan_id :bigint(8)        not null
#  start_date           :date             not null
#  end_date             :date
#  status               :string           default("trial")
#  trial_end_date       :date
#  monthly_amount       :decimal(10, 2)
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Subscription < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  belongs_to :team
  belongs_to :subscription_plan
  has_many :payment_transactions, dependent: :destroy
  
  validates :start_date, presence: true
  validates :status, inclusion: { 
    in: %w[trial active inactive cancelled expired suspended] 
  }
  
  scope :active, -> { where(status: 'active') }
  scope :trial, -> { where(status: 'trial') }
  scope :expired, -> { where(status: 'expired') }
  scope :cancelled, -> { where(status: 'cancelled') }
  
  before_save :set_trial_end_date, if: :trial?
  before_save :calculate_monthly_amount
  
  def trial?
    status == 'trial'
  end
  
  def active?
    status == 'active'
  end
  
  def inactive?
    status == 'inactive'
  end
  
  def cancelled?
    status == 'cancelled'
  end
  
  def expired?
    status == 'expired'
  end
  
  def suspended?
    status == 'suspended'
  end
  
  def trial_expired?
    trial? && trial_end_date && Date.current > trial_end_date
  end
  
  def subscription_expired?
    end_date && Date.current > end_date
  end
  
  def days_until_expiry
    return nil unless end_date
    
    (end_date - Date.current).to_i
  end
  
  def trial_days_remaining
    return 0 unless trial? && trial_end_date
    
    remaining = (trial_end_date - Date.current).to_i
    [remaining, 0].max
  end
  
  def can_access_feature?(feature_key)
    return false unless active? || trial?
    
    subscription_plan.feature_enabled?(feature_key)
  end
  
  def usage_percentage(resource_type)
    case resource_type.to_s
    when 'users'
      return 0 if subscription_plan.max_users.zero?
      
      (team.admins.count.to_f / subscription_plan.max_users * 100).round(1)
    when 'offices'
      return 0 if subscription_plan.max_offices.zero?
      
      (team.offices.count.to_f / subscription_plan.max_offices * 100).round(1)
    when 'cases'
      return 0 if subscription_plan.max_cases.zero?
      
      # Assuming we'll add works count later
      0
    else
      0
    end
  end
  
  def next_billing_date
    return nil unless active? && start_date
    
    case subscription_plan.billing_interval
    when 'monthly'
      start_date + 1.month
    when 'yearly'
      start_date + 1.year
    else
      nil
    end
  end
  
  private
  
  def set_trial_end_date
    return unless trial? && start_date
    
    self.trial_end_date = start_date + subscription_plan.trial_days.days
  end
  
  def calculate_monthly_amount
    return unless subscription_plan
    
    self.monthly_amount = case subscription_plan.billing_interval
                         when 'monthly'
                           subscription_plan.price
                         when 'yearly'
                           subscription_plan.price / 12
                         else
                           subscription_plan.price
                         end
  end
end
