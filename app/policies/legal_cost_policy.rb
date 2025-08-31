# frozen_string_literal: true

class LegalCostPolicy < ApplicationPolicy
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

  def summary?
    show?
  end

  def overdue_entries?
    show?
  end

  def upcoming_entries?
    show?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
