# frozen_string_literal: true

FactoryBot.define do
  factory :office_type do
    description { "#{Faker::Company.name}-#{SecureRandom.hex(4)}" }
  end
end
