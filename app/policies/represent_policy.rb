# frozen_string_literal: true

class RepresentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Users can only see represents within their team
      scope.by_team(user.current_team_id)
    end
  end

  def index?
    # Any authenticated user can list represents in their team
    user.present?
  end

  def show?
    # User can view if the represent belongs to their team
    record_in_team?
  end

  def create?
    # User can create represents if they have permission
    user_can_manage_customers?
  end

  def update?
    # User can update if they have permission and represent is in their team
    user_can_manage_customers? && record_in_team?
  end

  def destroy?
    # User can destroy if they have permission and represent is in their team
    user_can_manage_customers? && record_in_team?
  end

  def deactivate?
    # Same as update
    update?
  end

  def reactivate?
    # Same as update
    update?
  end

  def by_representor?
    # Any authenticated user can search by representor in their team
    user.present?
  end

  private

  def record_in_team?
    return false unless record && user

    record.team_id == user.current_team_id
  end

  def user_can_manage_customers?
    return false unless user

    # Check if user has appropriate role/permission
    # This depends on your authorization system
    # For now, we'll allow any authenticated user
    # You may want to check specific roles like:
    # user.has_role?(:admin) || user.has_role?(:manager)
    true
  end
end
