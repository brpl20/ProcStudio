# frozen_string_literal: true

# == Schema Information
#
# Table name: recommendations
#
#  id                  :bigint(8)        not null, primary key
#  percentage          :decimal(, )
#  commission          :decimal(, )
#  profile_customer_id :bigint(8)        not null
#  work_id             :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Recommendation < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :work
end
