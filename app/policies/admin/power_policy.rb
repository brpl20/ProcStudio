# frozen_string_literal: true

class Admin::PowerPolicy < Admin::BasePolicy
  def index?
    lawyer?
  end

  def show?
    lawyer?
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
