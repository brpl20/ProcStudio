# frozen_string_literal: true

class NotificationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner?
  end

  def create?
    # Allow authenticated users with profiles to create notifications
    # Additional checks for recipient are done in the controller
    user.present? && user.user_profile.present?
  end

  def update?
    owner?
  end

  def destroy?
    owner? || user.user_profile&.lawyer?
  end

  def mark_as_read?
    owner?
  end

  def mark_as_unread?
    owner?
  end

  def mark_all_as_read?
    user.present?
  end

  def unread_count?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user_profile: user.user_profile)
    end
  end

  private

  def owner?
    record.user_profile_id == user.user_profile&.id
  end
end
