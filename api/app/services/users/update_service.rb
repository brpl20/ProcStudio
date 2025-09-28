# frozen_string_literal: true

module Users
  class UpdateService
    def self.update_user(user:, params:)
      if user.update(params)
        CreationService::Result.success(user)
      else
        CreationService::Result.failure(user.errors.full_messages)
      end
    end
  end
end
