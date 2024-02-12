# frozen_string_literal: true

class Customer::CustomerPolicy < ApplicationPolicy
  def show?
    user == record
  end

  def update?
    show?
  end
end
