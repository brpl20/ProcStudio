# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    email { Faker::Internet.email }
    password { '123456' }
    password_confirmation { '123456' }

    after(:create) do |customer|
      token = JWT.encode(
        { customer_id: customer.id, exp: Time.now.advance(hours: 24).to_i },
        Rails.application.secret_key_base
      )
      customer.update(jwt_token: token)
    end
  end
end
