# frozen_string_literal: true

class Admin::UserPolicy < Admin::BasePolicy
  def index?
    super_admin? || lawyer? || secretary?
  end

  def show?
    super_admin? || lawyer? || secretary?
  end

  def create?
    super_admin? || lawyer?
  end

  def update?
    super_admin? || lawyer?
  end

  def destroy?
    super_admin? || lawyer?
  end

  def restore?
    super_admin? || lawyer?
  end
end
