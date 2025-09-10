# frozen_string_literal: true

class Admin::LawAreaPolicy < Admin::BasePolicy
  def index?
    # Qualquer usuário autenticado pode ver áreas do direito
    true
  end

  def show?
    # Qualquer usuário autenticado pode ver uma área específica
    true
  end

  def create?
    # Apenas lawyers e super_admins podem criar novas áreas
    super_admin? || lawyer?
  end

  def update?
    # Apenas lawyers e super_admins podem editar áreas
    # E só podem editar áreas customizadas do próprio team ou áreas do sistema se for super_admin
    return true if super_admin?
    return false unless lawyer?

    # Se é uma área customizada, deve ser do mesmo team
    if record.custom_area?
      record.created_by_team == user.team
    else
      # Áreas do sistema só super_admin pode editar
      false
    end
  end

  def destroy?
    # Mesma lógica do update
    return true if super_admin?
    return false unless lawyer?

    # Só pode deletar áreas customizadas do próprio team
    record.custom_area? && record.created_by_team == user.team
  end
end
