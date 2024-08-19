# frozen_string_literal: true

# == Schema Information
#
# Table name: office_emails
#
#  id         :bigint(8)        not null, primary key
#  office_id  :bigint(8)        not null
#  email_id   :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#
class OfficeEmail < ApplicationRecord
  acts_as_paranoid

  belongs_to :office
  belongs_to :email
end
