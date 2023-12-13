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
#
class OfficeEmail < ApplicationRecord
  belongs_to :office
  belongs_to :email
end
