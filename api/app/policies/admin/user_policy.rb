# frozen_string_literal: true

class Admin::UserPolicy < Admin::BasePolicy
  def index?
    lawyer? || secretary?
  end

  def show?
    lawyer? || secretary?
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

  def restore?
    lawyer?
  end
end
