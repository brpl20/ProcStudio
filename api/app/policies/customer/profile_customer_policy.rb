# frozen_string_literal: true

class Customer::ProfileCustomerPolicy < ApplicationPolicy
  def show?
    user.confirmed? && user == record.customer
  end

  def update?
    show?
  end
end
