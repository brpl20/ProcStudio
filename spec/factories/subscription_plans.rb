# frozen_string_literal: true

FactoryBot.define do
  factory :subscription_plan do
    sequence(:name) { |n| "Plan #{n}" }
    description { 'A great subscription plan' }
    price { 99.99 }
    currency { 'BRL' }
    billing_interval { 'monthly' }
    max_users { 5 }
    max_offices { 3 }
    max_cases { 100 }
    features do
      {
        'reports' => true,
        'api_access' => true,
        'advanced_analytics' => false,
        'trial_days' => 14
      }
    end
    is_active { true }
    
    trait :yearly do
      billing_interval { 'yearly' }
      price { 999.99 }
    end
    
    trait :free do
      name { 'Free Plan' }
      price { 0.0 }
      max_users { 1 }
      max_offices { 1 }
      max_cases { 10 }
      features do
        {
          'reports' => false,
          'api_access' => false,
          'advanced_analytics' => false,
          'trial_days' => 7
        }
      end
    end
    
    trait :premium do
      name { 'Premium Plan' }
      price { 199.99 }
      max_users { 25 }
      max_offices { 10 }
      max_cases { 1000 }
      features do
        {
          'reports' => true,
          'api_access' => true,
          'advanced_analytics' => true,
          'trial_days' => 30
        }
      end
    end
    
    trait :inactive do
      is_active { false }
    end
  end
end