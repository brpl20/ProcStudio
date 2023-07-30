# frozen_string_literal: true

class ProfileAdminWork < ApplicationRecord
  belongs_to :profile_admin
  belongs_to :work
end
