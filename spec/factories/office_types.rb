# frozen_string_literal: true

# == Schema Information
#
# Table name: office_types
#
#  id          :bigint           not null, primary key
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :office_type do
    description { "#{Faker::Company.name}-#{SecureRandom.hex(4)}" }
  end
end
