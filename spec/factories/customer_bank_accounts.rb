# frozen_string_literal: true

FactoryBot.define do
  factory :customer_bank_account do
    profile_customer { nil }
    bank_accounts { nil }
  end
end
