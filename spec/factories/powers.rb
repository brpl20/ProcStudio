# frozen_string_literal: true

# == Schema Information
#
# Table name: powers
#
#  id          :bigint           not null, primary key
#  category    :integer          not null
#  description :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :power do
    description { "Criminal" }
    category { 1 }
  end
end
