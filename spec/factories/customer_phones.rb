# frozen_string_literal: true

FactoryBot.define do
  factory :customer_phone do
    profile_customer { nil }
    phones { nil }
  end
end
