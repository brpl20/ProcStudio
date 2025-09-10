# frozen_string_literal: true

class Admin::JobCommentPolicy < Admin::BasePolicy
  def index?
    lawyer? || paralegal? || trainee? || secretary? || counter?
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def update?
    # Only the comment author can update their own comments
    return false unless record

    record.user_profile == user.user_profile
  end

  def destroy?
    # Only the comment author or super_admin can delete
    return false unless record

    record.user_profile == user.user_profile || super_admin?
  end
end
