# frozen_string_literal: true

class Admin::CustomerPolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal? || trainee? || secretary? || counter? || excounter?
  end

  def show?
    index?
  end

  def create?
    lawyer? || paralegal? || trainee? || secretary?
  end

  def resend_confirmation?
    create?
  end

  def update?
    lawyer? || paralegal? || (trainee? && owner?) || (secretary? && owner?)
  end

  def destroy?
    lawyer? || paralegal? || secretary?
  end
end
