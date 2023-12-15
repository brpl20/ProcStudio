# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_phones
#
#  id                  :bigint(8)        not null, primary key
#  profile_customer_id :bigint(8)        not null
#  phone_id            :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class CustomerPhone < ApplicationRecord
  belongs_to :phone
  belongs_to :profile_customer
end
