# frozen_string_literal: true

class Admin::WorkPolicy < Admin::BasePolicy
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
    lawyer? || paralegal?
  end
end
