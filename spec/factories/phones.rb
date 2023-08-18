# frozen_string_literal: true

FactoryBot.define do
  factory :phone do
    phone_number { Faker::PhoneNumber.cell_phone }
  end
end
