# frozen_string_literal: true

class Phone < ApplicationRecord
  has_many :admin_phones, dependent: :destroy
  has_many :profile_admins, through: :admin_phones
end
