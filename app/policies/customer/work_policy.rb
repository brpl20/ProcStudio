class Customer::WorkPolicy < ApplicationPolicy
  def index?
    user&.profile_customer
  end

  def show?
    index? && user.profile_customer_id.in?(record.profile_customer_ids)
  end
end
