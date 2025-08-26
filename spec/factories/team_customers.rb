# frozen_string_literal: true

FactoryBot.define do
  factory :team_customer do
    team
    customer

    trait :with_profile do
      after(:create) do |team_customer|
        create(:profile_customer, customer: team_customer.customer) unless team_customer.customer.profile_customer
      end
    end
  end
end
