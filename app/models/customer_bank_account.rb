# frozen_string_literal: true

class CustomerBankAccount < ApplicationRecord
  belongs_to :profile_customer
  belongs_to :bank_account
end
