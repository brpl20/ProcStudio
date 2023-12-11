# frozen_string_literal: true

class Represent < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :profile_admin
end
