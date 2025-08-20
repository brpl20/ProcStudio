# frozen_string_literal: true

# == Schema Information
#
# Table name: phones
#
#  id           :bigint           not null, primary key
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :phone do
    phone_number { Faker::PhoneNumber.cell_phone }
  end
end
