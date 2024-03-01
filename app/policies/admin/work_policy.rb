# frozen_string_literal: true

class Admin::WorkPolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal? || trainee? || secretary? || counter? || excounter?
  end

  def show?
    index?
  end

  def create?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def update?
    lawyer? || paralegal? || counter? || (trainee? && owner?) || (secretary? && owner?)
  end

  def destroy?
    lawyer? || paralegal? || secretary?
  end
end
