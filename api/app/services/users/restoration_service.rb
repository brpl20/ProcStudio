# frozen_string_literal: true

module Users
  class RestorationService
    def self.restore_user(user_id:)
      user = User.with_deleted.find(user_id)

      if user.recover
        CreationService::Result.success(user)
      else
        CreationService::Result.failure(user.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotFound
      CreationService::Result.failure(['Usuário não encontrado'])
    end
  end
end
