# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id           :bigint           not null, primary key
#  city         :string
#  description  :string
#  neighborhood :string
#  number       :integer
#  state        :string
#  street       :string
#  zip_code     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :address do
    description { Faker::Address.community }
    zip_code { Faker::Address.zip_code }
    street { Faker::Address.street_name }
    number { Faker::Number.number(digits: 5) }
    neighborhood { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
  end
end
