class CustomerBankAccount < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :bank_accounts
end
