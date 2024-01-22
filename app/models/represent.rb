# frozen_string_literal: true

# == Schema Information
#
# Table name: represents
#
#  id                  :bigint(8)        not null, primary key
#  profile_customer_id :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  representor_id      :bigint(8)
#
class Represent < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :representor, class_name: 'ProfileCustomer', optional: true, foreign_key: 'representor_id'
end
