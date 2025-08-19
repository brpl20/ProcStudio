# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id         :bigint           not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Email < ApplicationRecord
  has_many :admin_emails, dependent: :destroy
  has_many :profile_admins, through: :admin_emails

  has_many :office_emails, dependent: :destroy
  has_many :offices, through: :office_emails

  has_many :customer_emails, dependent: :destroy
  has_many :profile_customers, through: :customer_emails
end
