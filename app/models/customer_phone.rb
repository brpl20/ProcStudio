# frozen_string_literal: true

class CustomerPhone < ApplicationRecord
  belongs_to :phone
  belongs_to :profile_customer
end
