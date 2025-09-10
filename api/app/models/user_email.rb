# frozen_string_literal: true

# == Schema Information
#
# Table name: user_emails
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  email_id        :bigint           not null
#  user_profile_id :bigint           not null
#
# Indexes
#
#  index_user_emails_on_deleted_at       (deleted_at)
#  index_user_emails_on_email_id         (email_id)
#  index_user_emails_on_user_profile_id  (user_profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_id => emails.id)
#  fk_rails_...  (user_profile_id => user_profiles.id)
#

class UserEmail < ApplicationRecord
  acts_as_paranoid

  belongs_to :email
  belongs_to :user_profile
end
