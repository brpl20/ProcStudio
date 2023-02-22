# frozen_string_literal: true

class Email < ApplicationRecord
  has_many :admin_emails, dependent: :destroy
  has_many :profile_admins, through: :admin_emails
end
