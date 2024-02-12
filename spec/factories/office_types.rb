# frozen_string_literal: true

FactoryBot.define do
  factory :office_type do
    description { Faker::Company.name }
  end
end
