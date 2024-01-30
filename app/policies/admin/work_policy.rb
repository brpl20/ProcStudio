# frozen_string_literal: true

class Admin::WorkPolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal? || trainee? || secretary? || excounter?
  end

  def show?
    lawyer? || paralegal? || trainee? || secretary? || excounter?
  end

  def create?
    lawyer? || paralegal? || trainee? || secretary?
  end

  def update?
    lawyer? || paralegal? || trainee? || secretary?
  end

  def destroy?
    lawyer? || paralegal?
  end
end
