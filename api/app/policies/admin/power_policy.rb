# frozen_string_literal: true

class Admin::PowerPolicy < Admin::BasePolicy
  def index?
    # Qualquer usuário autenticado pode ver poderes
    true
  end

  def show?
    # Qualquer usuário autenticado pode ver um poder específico
    true
  end

  def create?
    # Apenas lawyers e super_admins podem criar novos poderes
    super_admin? || lawyer?
  end

  def update?
    # Apenas lawyers e super_admins podem editar poderes
    # E só podem editar poderes customizados do próprio team ou poderes do sistema se for super_admin
    return true if super_admin?
    return false unless lawyer?

    # Se é um poder customizado, deve ser do mesmo team
    if record.custom_power?
      record.created_by_team == user.team
    else
      # Poderes do sistema só super_admin pode editar
      false
    end
  end

  def destroy?
    # Mesma lógica do update
    return true if super_admin?
    return false unless lawyer?

    # Só pode deletar poderes customizados do próprio team
    record.custom_power? && record.created_by_team == user.team
  end
end
