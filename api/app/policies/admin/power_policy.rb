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
    # Apenas lawyers podem criar novos poderes
    lawyer?
  end

  def update?
    # Apenas lawyers podem editar poderes customizados do próprio team
    return false unless lawyer?

    # Se é um poder customizado, deve ser do mesmo team
    if record.custom_power?
      record.created_by_team == user.team
    else
      # Poderes do sistema não podem ser editados
      false
    end
  end

  def destroy?
    # Apenas lawyers podem deletar poderes customizados do próprio team
    return false unless lawyer?

    # Só pode deletar poderes customizados do próprio team
    record.custom_power? && record.created_by_team == user.team
  end
end
