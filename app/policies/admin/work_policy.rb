# frozen_string_literal: true

class Admin::WorkPolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal?
  end

  def show?
    lawyer? || paralegal?
  end

  def create?
    lawyer? || paralegal?
  end

  def update?
    lawyer? || paralegal?
  end

  def destroy?
    lawyer? || paralegal?
  end
end
