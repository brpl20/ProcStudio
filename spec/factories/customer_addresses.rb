# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_addresses
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :bigint           not null
#  profile_customer_id :bigint           not null
#
# Indexes
#
#  index_customer_addresses_on_address_id           (address_id)
#  index_customer_addresses_on_deleted_at           (deleted_at)
#  index_customer_addresses_on_profile_customer_id  (profile_customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (address_id => addresses.id)
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#
FactoryBot.define do
  factory :customer_address do
    profile_customer
    address
  end
end
