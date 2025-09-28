# frozen_string_literal: true

module Users
  class DeletionService
    def self.delete_user(user_id:, destroy_fully: false)
      user = find_user(user_id, destroy_fully)

      if destroy_fully
        user.destroy_fully!
        message = 'Usuário removido permanentemente'
      else
        user.destroy
        message = 'Usuário removido com sucesso'
      end

      CreationService::Result.success({ id: user_id, message: message })
    rescue ActiveRecord::RecordNotFound
      CreationService::Result.failure(['Usuário não encontrado'])
    end

    def self.find_user(user_id, with_deleted: false)
      if with_deleted
        User.with_deleted.find(user_id)
      else
        User.find(user_id)
      end
    end
  end
end
