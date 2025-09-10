# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_phones
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  phone_id            :bigint           not null
#  profile_customer_id :bigint           not null
#
# Indexes
#
#  index_customer_phones_on_deleted_at           (deleted_at)
#  index_customer_phones_on_phone_id             (phone_id)
#  index_customer_phones_on_profile_customer_id  (profile_customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (phone_id => phones.id)
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#
FactoryBot.define do
  factory :customer_phone do
    profile_customer
    phone
  end
end
