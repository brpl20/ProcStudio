# frozen_string_literal: true

class AdminPhone < ApplicationRecord
  belongs_to :phone
  belongs_to :profile_admin
end
