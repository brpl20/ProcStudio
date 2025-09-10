# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id           :bigint           not null, primary key
#  account      :string
#  agency       :string
#  bank_name    :string
#  operation    :string
#  pix          :string
#  type_account :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :bank_account do
    bank_name { Faker::Bank.name }
    type_account { 'corrente' }
    agency { Faker::Bank.account_number }
    account { Faker::Bank.routing_number }
    operation { Faker::Number.number(digits: 3) }
    pix { Faker::Number.number(digits: 11) }
  end
end
