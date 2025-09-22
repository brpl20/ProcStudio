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
    # Apenas lawyers podem criar novas áreas
    lawyer?
  end

  def update?
    # Apenas lawyers podem editar áreas customizadas do próprio team
    return false unless lawyer?

    # Se é uma área customizada, deve ser do mesmo team
    if record.custom_area?
      record.created_by_team == user.team
    else
      # Áreas do sistema não podem ser editadas
      false
    end
  end

  def destroy?
    # Apenas lawyers podem deletar áreas customizadas do próprio team
    return false unless lawyer?

    # Só pode deletar áreas customizadas do próprio team
    record.custom_area? && record.created_by_team == user.team
  end
end