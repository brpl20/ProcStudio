# frozen_string_literal: true

class Admin::OfficePolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal? || trainee? || secretary? || counter? || excounter?
  end

  def show?
    lawyer? || paralegal? || trainee? || secretary? || counter? || excounter?
  end

  def create?
    lawyer?
  end

  def update?
    lawyer?
  end

  def destroy?
    lawyer?
  end
end
