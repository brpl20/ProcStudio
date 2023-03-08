class ClientAddress < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :addresses
end
