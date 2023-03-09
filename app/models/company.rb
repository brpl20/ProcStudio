# frozen_string_literal: true

class Company < ProfileCustomer
  validates :cnpj, presence: true
  validates :company, presence: true
end
