# frozen_string_literal: true

class Admin::WikiCategoryPolicy < Admin::BasePolicy
  def index?
    user_has_team_access?
  end

  def show?
    user_has_team_access?
  end

  def create?
    user_has_team_access? && user_is_team_admin?
  end

  def update?
    user_has_team_access? && user_is_team_admin?
  end

  def destroy?
    user_has_team_access? && user_is_team_admin?
  end

  private

  def user_has_team_access?
    team = record.team
    team.member?(user)
  end

  def user_is_team_admin?
    team = record.team
    team.admin?(user) || team.owner?(user)
  end
end
