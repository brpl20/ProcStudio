# frozen_string_literal: true

class Job < ApplicationRecord
  belongs_to :work, optional: true
  belongs_to :customer
  belongs_to :profile_admin
end
