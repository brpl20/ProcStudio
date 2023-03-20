# frozen_string_literal: true

class Email < ApplicationRecord
  has_many :admin_emails, dependent: :destroy
  has_many :profile_admins, through: :admin_emails

  has_many :office_emails, dependent: :destroy
  has_many :offices, through: :office_emails

  has_many :customer_emails, dependent: :destroy
  has_many :profile_customers, through: :customer_emails
end
