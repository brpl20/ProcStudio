# frozen_string_literal: true

class Admin::JobPolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def show?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def create?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def update?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def destroy?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end
end
