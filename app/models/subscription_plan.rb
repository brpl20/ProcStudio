# frozen_string_literal: true

# == Schema Information
#
# Table name: subscription_plans
#
#  id               :bigint(8)        not null, primary key
#  name             :string           not null
#  description      :text
#  price            :decimal(10, 2)
#  currency         :string           default("BRL")
#  billing_interval :string
#  max_users        :integer
#  max_offices      :integer
#  max_cases        :integer
#  features         :json
#  is_active        :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_exception
  
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, inclusion: { in: %w[BRL USD EUR] }
  validates :billing_interval, inclusion: { in: %w[monthly yearly] }
  validates :max_users, presence: true, numericality: { greater_than: 0 }
  validates :max_offices, presence: true, numericality: { greater_than: 0 }
  validates :max_cases, presence: true, numericality: { greater_than: 0 }
  
  scope :active, -> { where(is_active: true) }
  scope :monthly, -> { where(billing_interval: 'monthly') }
  scope :yearly, -> { where(billing_interval: 'yearly') }
  
  def monthly?
    billing_interval == 'monthly'
  end
  
  def yearly?
    billing_interval == 'yearly'
  end
  
  def feature_enabled?(feature_key)
    features[feature_key.to_s] == true
  end
  
  def display_price
    case currency
    when 'BRL'
      "R$ #{format('%.2f', price)}"
    when 'USD'
      "$ #{format('%.2f', price)}"
    when 'EUR'
      "€ #{format('%.2f', price)}"
    else
      "#{currency} #{format('%.2f', price)}"
    end
  end
  
  def yearly_price
    return price if yearly?
    
    price * 12 * 0.9 # 10% discount for yearly
  end
  
  def trial_days
    features['trial_days']&.to_i || 14
  end
end
