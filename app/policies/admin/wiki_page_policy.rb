# frozen_string_literal: true

class Admin::WikiPagePolicy < Admin::BasePolicy
  def index?
    user_has_team_access?
  end

  def show?
    user_has_team_access? && (record.is_published? || can_edit?)
  end

  def create?
    user_has_team_access?
  end

  def update?
    can_edit?
  end

  def destroy?
    can_edit? && user_is_team_admin?
  end

  def publish?
    can_edit? && user_is_team_admin?
  end

  def unpublish?
    can_edit? && user_is_team_admin?
  end

  def lock?
    user_is_team_admin?
  end

  def unlock?
    user_is_team_admin?
  end

  def revert?
    can_edit?
  end

  def revisions?
    show?
  end

  private

  def can_edit?
    return false unless user_has_team_access?
    return true if user_is_team_admin?
    return false if record.is_locked?

    true
  end

  def user_has_team_access?
    team = record.team
    team.member?(user)
  end

  def user_is_team_admin?
    team = record.team
    team.admin?(user) || team.owner?(user)
  end
end
