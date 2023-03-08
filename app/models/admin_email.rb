# frozen_string_literal: true

class AdminEmail < ApplicationRecord
  belongs_to :email
  belongs_to :profile_admin
end
