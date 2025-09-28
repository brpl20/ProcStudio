# frozen_string_literal: true

module Drafts
  class AuthorizationService
    def self.authorized?(draft:, user:)
      return false unless user && draft

      draft.user == user || draft.team == user.team
    end
  end
end
