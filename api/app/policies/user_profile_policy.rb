# frozen_string_literal: true

class UserProfilePolicy < ApplicationPolicy
  def index?
    # Permite que usuários autenticados vejam perfis do seu team
    user.present?
  end

  def show?
    # Permite que usuários vejam perfis do seu team
    user.present?
  end

  def create?
    # Permite que usuários autenticados criem perfis
    user.present?
  end

  def update?
    # Permite que usuários atualizem seu próprio perfil ou se tiverem permissão
    user.present?
  end

  def destroy?
    # Permite que usuários com permissão deletem perfis
    user.present?
  end

  def restore?
    # Permite que usuários com permissão restaurem perfis
    user.present?
  end

  def complete?
    # Permite que usuários autenticados completem seu próprio perfil
    user.present?
  end
end
