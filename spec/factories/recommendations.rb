# frozen_string_literal: true

FactoryBot.define do
  factory :recommendation do
    percentage { '9.99' }
    commition { '9.99' }
    profile_customer { nil }
    work { nil }
  end
end
