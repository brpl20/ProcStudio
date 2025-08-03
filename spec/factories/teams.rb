# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    sequence(:subdomain) { |n| "team#{n}" }
    status { 'active' }
    
    association :main_admin, factory: :admin
    association :owner_admin, factory: :admin
    
    trait :inactive do
      status { 'inactive' }
    end
    
    trait :suspended do
      status { 'suspended' }
    end
    
    trait :with_subscription do
      after(:create) do |team|
        plan = create(:subscription_plan)
        create(:subscription, team: team, subscription_plan: plan)
      end
    end
    
    trait :with_members do
      after(:create) do |team|
        create_list(:team_membership, 2, team: team)
      end
    end
    
    trait :with_offices do
      after(:create) do |team|
        create_list(:office, 2, team: team)
      end
    end
  end
end