# frozen_string_literal: true

# == Schema Information
#
# Table name: represents
#
#  id                  :bigint(8)        not null, primary key
#  profile_customer_id :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_admin_id    :bigint(8)        not null
#
class Represent < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :profile_admin
end
