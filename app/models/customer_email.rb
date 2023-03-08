class CustomerEmail < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :emails
end
