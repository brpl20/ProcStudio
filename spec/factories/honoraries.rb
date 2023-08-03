# frozen_string_literal: true

FactoryBot.define do
  factory :honorary do
    fixed_honorary_value { '100' }
    parcelling_value { '2' }
    honorary_type { 'both' }
    percent_honorary_value { '10%' }
    parcelling { true }
    work
  end
end
