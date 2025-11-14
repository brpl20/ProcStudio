# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                      :bigint           not null, primary key
#  canceled_at             :datetime
#  current_period_end      :datetime
#  current_period_start    :datetime
#  deleted_at              :datetime
#  extra_users_count       :integer          default(0)
#  free_months_remaining   :integer          default(0)
#  metadata                :jsonb
#  plan_type               :string           default("basic"), not null
#  status                  :string           default("active"), not null
#  stripe_customer_id      :string
#  stripe_subscription_id  :string
#  trial_end               :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  team_id                 :bigint           not null
#
# Indexes
#
#  index_subscriptions_on_deleted_at              (deleted_at)
#  index_subscriptions_on_plan_type               (plan_type)
#  index_subscriptions_on_status                  (status)
#  index_subscriptions_on_stripe_customer_id      (stripe_customer_id)
#  index_subscriptions_on_stripe_subscription_id  (stripe_subscription_id) UNIQUE
#  index_subscriptions_on_team_id                 (team_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class Subscription < ApplicationRecord
  include DeletedFilterConcern

  acts_as_paranoid

  # Associations
  belongs_to :team

  # Enums
  enum :plan_type, {
    basic: 'basic',
    pro: 'pro'
  }

  enum :status, {
    active: 'active',
    past_due: 'past_due',
    canceled: 'canceled',
    incomplete: 'incomplete',
    incomplete_expired: 'incomplete_expired',
    trialing: 'trialing',
    unpaid: 'unpaid'
  }

  # Validations
  validates :team_id, presence: true, uniqueness: true
  validates :plan_type, presence: true
  validates :status, presence: true
  validates :extra_users_count, numericality: { greater_than_or_equal_to: 0 }
  validates :free_months_remaining, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :active_subscriptions, -> { where(status: :active) }
  scope :pro_plans, -> { where(plan_type: :pro) }
  scope :basic_plans, -> { where(plan_type: :basic) }
  scope :with_free_months, -> { where('free_months_remaining > 0') }

  # Callbacks
  after_create :initialize_usage_limits

  # Class methods
  def self.plan_limits(plan_type)
    case plan_type.to_s
    when 'basic'
      {
        customers: 100,
        jobs: 150,
        works: 100,
        documents_total: 100,
        documents_monthly: nil, # No monthly limit, only total
        lawyers: 1,
        offices: 0
      }
    when 'pro'
      {
        customers: nil, # Unlimited
        jobs: nil, # Unlimited
        works: nil, # Unlimited
        documents_total: nil, # No total limit
        documents_monthly: 100,
        lawyers: 2,
        offices: 1
      }
    else
      {}
    end
  end

  # Instance methods
  def plan_limits
    self.class.plan_limits(plan_type)
  end

  def monthly_cost
    base_cost = case plan_type
                when 'basic' then 0.0
                when 'pro' then 70.0
                else 0.0
                end

    extra_user_cost = extra_users_count * 15.0

    base_cost + extra_user_cost
  end

  def within_limits?(resource_type)
    limits = plan_limits
    usage = team.usage_limit || team.create_usage_limit

    case resource_type.to_sym
    when :customers
      return true if limits[:customers].nil? # Unlimited
      usage.customers_count < limits[:customers]
    when :jobs
      return true if limits[:jobs].nil?
      usage.jobs_count < limits[:jobs]
    when :works
      return true if limits[:works].nil?
      usage.works_count < limits[:works]
    when :documents_total
      return true if limits[:documents_total].nil?
      usage.documents_generated_total < limits[:documents_total]
    when :documents_monthly
      return true if limits[:documents_monthly].nil?
      usage.documents_generated_month < limits[:documents_monthly]
    else
      true
    end
  end

  def add_free_month!
    increment!(:free_months_remaining)
    Rails.logger.info("[Subscription] Added free month to subscription #{id}. Total: #{free_months_remaining}")
  end

  def use_free_month!
    return false if free_months_remaining <= 0

    decrement!(:free_months_remaining)
    Rails.logger.info("[Subscription] Used free month for subscription #{id}. Remaining: #{free_months_remaining}")
    true
  end

  def has_free_months?
    free_months_remaining > 0
  end

  def cancel!
    update!(
      status: :canceled,
      canceled_at: Time.current
    )
  end

  def reactivate!
    update!(
      status: :active,
      canceled_at: nil
    )
  end

  private

  def initialize_usage_limits
    team.create_usage_limit! unless team.usage_limit.present?
  end
end
