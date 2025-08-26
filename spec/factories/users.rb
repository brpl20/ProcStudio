# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    oab { Faker::Number.number(digits: 6).to_s }
    status { 'active' }
    team

    after(:create) do |user|
      token = JWT.encode(
        { user_id: user.id, exp: Time.now.advance(hours: 24).to_i },
        Rails.application.secret_key_base
      )
      user.update(jwt_token: token)
    end

    trait :with_profile do
      after(:create) do |user|
        create(:user_profile, user: user)
      end
    end

    trait :inactive do
      status { 'inactive' }
    end

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
