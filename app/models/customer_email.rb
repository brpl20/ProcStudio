# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_emails
#
#  id                  :bigint(8)        not null, primary key
#  profile_customer_id :bigint(8)        not null
#  email_id            :bigint(8)        not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class CustomerEmail < ApplicationRecord
  belongs_to :email
  belongs_to :profile_customer
end
