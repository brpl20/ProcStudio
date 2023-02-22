class AdminAddress < ApplicationRecord
  belongs_to :address
  belongs_to :profile_admin
end
