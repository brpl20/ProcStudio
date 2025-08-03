# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    association :team
    association :subscription_plan
    start_date { Date.current }
    status { 'trial' }
    trial_end_date { Date.current + 14.days }
    
    trait :active do
      status { 'active' }
      start_date { 1.month.ago }
      end_date { 1.year.from_now }
    end
    
    trait :inactive do
      status { 'inactive' }
    end
    
    trait :cancelled do
      status { 'cancelled' }
      end_date { Date.current.end_of_month }
    end
    
    trait :expired do
      status { 'expired' }
      end_date { 1.week.ago }
    end
    
    trait :suspended do
      status { 'suspended' }
    end
    
    trait :trial_expired do
      status { 'trial' }
      trial_end_date { 1.week.ago }
    end
    
    trait :with_payments do
      after(:create) do |subscription|
        create_list(:payment_transaction, 3, :completed, subscription: subscription)
      end
    end
  end
end