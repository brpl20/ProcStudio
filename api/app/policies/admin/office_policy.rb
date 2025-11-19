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

  def restore?
    lawyer?
  end

  def destroy?
    lawyer?
  end

  def upload_logo?
    lawyer?
  end

  def upload_contracts?
    lawyer?
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
