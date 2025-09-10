# frozen_string_literal: true

class UserProfilePolicy < ApplicationPolicy
  def complete?
    # Permite que usuários autenticados completem seu próprio perfil
    user.present?
  end

  def show?
    # Permite que usuários vejam seu próprio perfil
    user.present?
  end

  def update?
    # Permite que usuários atualizem seu próprio perfil
    user.present?
  end
end
