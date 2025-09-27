# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_accounts
#
#  id            :bigint           not null, primary key
#  account       :string
#  account_type  :string           default("main")
#  agency        :string
#  bank_name     :string
#  bankable_type :string
#  deleted_at    :datetime
#  operation     :string
#  pix           :string
#  type_account  :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  bankable_id   :bigint
#
# Indexes
#
#  index_bank_accounts_on_bankable    (bankable_type,bankable_id)
#  index_bank_accounts_on_deleted_at  (deleted_at)
#
FactoryBot.define do
  factory :bank_account do
    bank_name { Faker::Bank.name }
    account_type { 'checking' }
    agency { Faker::Bank.account_number }
    account { Faker::Bank.routing_number }
    operation { Faker::Number.number(digits: 3) }
    pix { Faker::Number.number(digits: 11) }
  end
end
