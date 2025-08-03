# frozen_string_literal: true

FactoryBot.define do
  factory :team_membership do
    association :team
    association :admin
    role { 'member' }
    status { 'active' }
    
    trait :owner do
      role { 'owner' }
    end
    
    trait :admin_role do
      role { 'admin' }
    end
    
    trait :inactive do
      status { 'inactive' }
    end
    
    trait :pending do
      status { 'pending' }
    end
  end
end