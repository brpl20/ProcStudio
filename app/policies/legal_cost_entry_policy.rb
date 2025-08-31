# frozen_string_literal: true

class LegalCostEntryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end

  def mark_as_paid?
    true
  end

  def mark_as_unpaid?
    true
  end

  def batch_create?
    true
  end

  def by_type?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
