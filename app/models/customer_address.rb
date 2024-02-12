# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_addresses
#
#  id                  :bigint(8)        not null, primary key
#  profile_customer_id :bigint(8)        not null
#  address_id          :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  deleted_at          :datetime
#
class CustomerAddress < ApplicationRecord
  acts_as_paranoid

  belongs_to :profile_customer
  belongs_to :address
end
