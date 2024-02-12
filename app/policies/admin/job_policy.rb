# frozen_string_literal: true

class Admin::JobPolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end
end
