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

  def restore?
    update?
  end

  def destroy?
    lawyer? || paralegal? || secretary?
  end

  def upload_attachment?
    lawyer? || paralegal? || trainee? || secretary?
  end

  def remove_attachment?
    lawyer? || paralegal? || trainee? || secretary?
  end

  def transfer_attachment?
    lawyer? || paralegal?
  end
end
