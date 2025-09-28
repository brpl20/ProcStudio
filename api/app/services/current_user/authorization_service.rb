# frozen_string_literal: true

module CurrentUser
  class AuthorizationService
    def self.can_view_user?(user:, current_user:)
      return true if user.id == current_user.id

      user.team_id == current_user.team_id
    end
  end
end
