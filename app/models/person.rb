# frozen_string_literal: true

class Person < ProfileCustomer
  validates :cpf, presence: true
  validates :rg, presence: true
end
