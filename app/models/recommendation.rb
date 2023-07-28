# frozen_string_literal: true

class Recommendation < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :work
end
