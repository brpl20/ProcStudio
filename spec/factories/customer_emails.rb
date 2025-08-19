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
FactoryBot.define do
  factory :customer_email do
    profile_customer { nil }
    emails { nil }
  end
end
