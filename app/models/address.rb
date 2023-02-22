# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :admin_addresses, dependent: :destroy
  has_many :profile_admins, through: :admin_addresses
end
