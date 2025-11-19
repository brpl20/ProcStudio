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

  def upload_avatar?
    lawyer? || secretary?
  end

  def upload_attachment?
    lawyer? || secretary?
  end

  def remove_attachment?
    lawyer? || secretary?
  end

  def transfer_attachment?
    lawyer?
  end
end
