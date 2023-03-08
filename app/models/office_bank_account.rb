# frozen_string_literal: true

class OfficeBankAccount < ApplicationRecord
  belongs_to :bank_account
  belongs_to :office
end
