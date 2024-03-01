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

  def update?
    lawyer? || paralegal? || (trainee? && owner?) || (secretary? && owner?)
  end

  def destroy?
    lawyer? || paralegal? || secretary?
  end

  def owner?
    record.created_by_id == user.id
  end
end
