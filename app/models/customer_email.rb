# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_emails
#
#  id                  :bigint           not null, primary key
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_id            :bigint           not null
#  profile_customer_id :bigint           not null
#
# Indexes
#
#  index_customer_emails_on_deleted_at           (deleted_at)
#  index_customer_emails_on_email_id             (email_id)
#  index_customer_emails_on_profile_customer_id  (profile_customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_id => emails.id)
#  fk_rails_...  (profile_customer_id => profile_customers.id)
#

class CustomerEmail < ApplicationRecord
  acts_as_paranoid

  belongs_to :email
  belongs_to :profile_customer
end
