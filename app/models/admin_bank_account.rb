class AdminBankAccount < ApplicationRecord
  belongs_to :bank_account
  belongs_to :profile_admin
end
