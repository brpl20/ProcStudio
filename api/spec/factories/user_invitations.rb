# frozen_string_literal: true

FactoryBot.define do
  factory :user_invitation do
    sequence(:email) { |n| "invitee#{n}@example.com" }
    status { 'pending' }
    expires_at { 7.days.from_now }
    metadata { { suggested_role: 'lawyer' } }

    association :invited_by, factory: :user
    association :team

    trait :accepted do
      status { 'accepted' }
      accepted_at { Time.current }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.day.ago }
    end

    trait :pending do
      status { 'pending' }
      expires_at { 7.days.from_now }
    end

    trait :expiring_soon do
      expires_at { 1.day.from_now }
    end
  end
end
