# frozen_string_literal: true

class CustomerEmail < ApplicationRecord
  belongs_to :email
  belongs_to :profile_customer
end
