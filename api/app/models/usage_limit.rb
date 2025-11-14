# frozen_string_literal: true

# == Schema Information
#
# Table name: usage_limits
#
#  id                         :bigint           not null, primary key
#  customers_count            :integer          default(0)
#  documents_generated_month  :integer          default(0)
#  documents_generated_total  :integer          default(0)
#  jobs_count                 :integer          default(0)
#  period_end                 :datetime
#  period_start               :datetime
#  works_count                :integer          default(0)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  team_id                    :bigint           not null
#
# Indexes
#
#  index_usage_limits_on_team_id  (team_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class UsageLimit < ApplicationRecord
  belongs_to :team

  # Validations
  validates :team_id, presence: true, uniqueness: true
  validates :customers_count, numericality: { greater_than_or_equal_to: 0 }
  validates :jobs_count, numericality: { greater_than_or_equal_to: 0 }
  validates :works_count, numericality: { greater_than_or_equal_to: 0 }
  validates :documents_generated_total, numericality: { greater_than_or_equal_to: 0 }
  validates :documents_generated_month, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_create :initialize_period

  # Instance methods
  def increment_customers!
    increment!(:customers_count)
  end

  def decrement_customers!
    decrement!(:customers_count) if customers_count > 0
  end

  def increment_jobs!
    increment!(:jobs_count)
  end

  def decrement_jobs!
    decrement!(:jobs_count) if jobs_count > 0
  end

  def increment_works!
    increment!(:works_count)
  end

  def decrement_works!
    decrement!(:works_count) if works_count > 0
  end

  def increment_documents!
    increment!(:documents_generated_total)
    increment!(:documents_generated_month)
  end

  def reset_monthly_usage!
    update!(
      documents_generated_month: 0,
      period_start: Time.current,
      period_end: 1.month.from_now
    )
    Rails.logger.info("[UsageLimit] Reset monthly usage for team #{team_id}")
  end

  def should_reset_monthly?
    return false if period_end.nil?

    Time.current >= period_end
  end

  def check_and_reset_monthly!
    reset_monthly_usage! if should_reset_monthly?
  end

  def usage_percentage(resource_type)
    limits = team.subscription&.plan_limits || {}
    limit = limits[resource_type]

    return 0 if limit.nil? # Unlimited

    current_usage = case resource_type
                    when :customers then customers_count
                    when :jobs then jobs_count
                    when :works then works_count
                    when :documents_total then documents_generated_total
                    when :documents_monthly then documents_generated_month
                    else 0
                    end

    ((current_usage.to_f / limit) * 100).round(2)
  end

  def at_limit?(resource_type)
    subscription = team.subscription
    return false unless subscription

    !subscription.within_limits?(resource_type)
  end

  def usage_summary
    subscription = team.subscription
    limits = subscription&.plan_limits || {}

    {
      customers: {
        current: customers_count,
        limit: limits[:customers],
        percentage: usage_percentage(:customers),
        at_limit: at_limit?(:customers)
      },
      jobs: {
        current: jobs_count,
        limit: limits[:jobs],
        percentage: usage_percentage(:jobs),
        at_limit: at_limit?(:jobs)
      },
      works: {
        current: works_count,
        limit: limits[:works],
        percentage: usage_percentage(:works),
        at_limit: at_limit?(:works)
      },
      documents_total: {
        current: documents_generated_total,
        limit: limits[:documents_total],
        percentage: usage_percentage(:documents_total),
        at_limit: at_limit?(:documents_total)
      },
      documents_monthly: {
        current: documents_generated_month,
        limit: limits[:documents_monthly],
        percentage: usage_percentage(:documents_monthly),
        at_limit: at_limit?(:documents_monthly),
        period_end: period_end
      }
    }
  end

  private

  def initialize_period
    self.period_start ||= Time.current
    self.period_end ||= 1.month.from_now
  end
end
