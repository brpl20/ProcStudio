# frozen_string_literal: true

FactoryBot.define do
  factory :represent do
    represented_id { 1 }
    profile_customer { nil }
  end
end
