# frozen_string_literal: true

FactoryBot.define do
  factory :draft do
    association :draftable, factory: :work
    form_type { 'work_form' }
    data { { field1: 'value1', field2: 'value2', timestamp: Time.current.to_s } }
    status { 'draft' }
    expires_at { 30.days.from_now }
    user { nil }
    customer { nil }
    team { nil }

    trait :with_user do
      user
      team { user.team }
    end

    trait :with_customer do
      customer
      team { customer.teams.first || create(:team) }
    end

    trait :with_team do
      team
    end

    trait :recovered do
      status { 'recovered' }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.day.ago }
    end

    trait :no_expiration do
      expires_at { nil }
    end

    trait :complex_data do
      data do
        {
          personal_info: {
            name: Faker::Name.name,
            email: Faker::Internet.email,
            phone: Faker::PhoneNumber.phone_number
          },
          preferences: {
            notifications: true,
            theme: 'dark'
          },
          metadata: {
            created_at: Time.current.to_s,
            version: '1.0'
          }
        }
      end
    end
  end
end
