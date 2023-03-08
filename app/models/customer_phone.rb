class CustomerPhone < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :phones
end
