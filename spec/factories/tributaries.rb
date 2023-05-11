# frozen_string_literal: true

FactoryBot.define do
  factory :tributary do
    compensation { 1 }
    craft { 1 }
    lawsuit { 1 }
    pojection { '2023-05-04' }
    work { nil }
  end
end
