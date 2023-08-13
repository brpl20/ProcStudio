# frozen_string_literal: true

FactoryBot.define do
  factory :customer_phone do
    profile_customer
    phone
  end
end
