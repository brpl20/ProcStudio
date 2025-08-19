# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id         :bigint           not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :email do
    email { Faker::Internet.email }
  end
end
