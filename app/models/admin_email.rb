# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_emails
#
#  id               :bigint(8)        not null, primary key
#  email_id         :bigint(8)        not null
#  profile_admin_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#
class AdminEmail < ApplicationRecord
  acts_as_paranoid

  belongs_to :email
  belongs_to :profile_admin
end
