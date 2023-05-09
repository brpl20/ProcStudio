# frozen_string_literal: true

class JobWork < ApplicationRecord
  belongs_to :job
  belongs_to :work
  belongs_to :profile_admin
  belongs_to :profile_customer
end
