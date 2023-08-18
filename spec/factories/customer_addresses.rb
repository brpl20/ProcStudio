# frozen_string_literal: true

FactoryBot.define do
  factory :customer_address do
    profile_customer
    address
  end
end
