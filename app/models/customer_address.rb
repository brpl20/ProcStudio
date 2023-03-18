# frozen_string_literal: true

class CustomerAddress < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :address
end
