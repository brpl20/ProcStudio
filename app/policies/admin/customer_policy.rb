# frozen_string_literal: true

class Admin::CustomerPolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal? || trainee? || secretary? || counter? || excounter?
  end

  def show?
    lawyer? || paralegal? || trainee? || secretary? || counter? || excounter?
  end

  def create?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def update?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def destroy?
    lawyer?
  end
end
