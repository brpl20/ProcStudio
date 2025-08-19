# frozen_string_literal: true

module TeamScoped
  extend ActiveSupport::Concern

  included do
    # Removido para controle manual no BackofficeController
  end

  private

  def set_current_team
    @current_team = detect_team_from_request
  end

  def current_team
    @current_team
  end

  def detect_team_from_request
    # Priority order: header, subdomain, user's team
    team_from_header || team_from_subdomain || current_user_team
  end

  def team_from_header
    team_id = request.headers['X-Team-Id']
    return nil if team_id.blank?

    # SEGURANÇA: Validar se o usuário tem acesso ao team solicitado
    requested_team = Team.find_by(id: team_id)
    return nil unless requested_team

    # Permitir apenas se for o team do usuário atual
    if @current_user.present? && @current_user.respond_to?(:team) && (requested_team == @current_user.team)
      return requested_team
    end

    nil
  end

  def team_from_subdomain
    subdomain = request.subdomain
    return nil if subdomain.blank?

    # SEGURANÇA: Validar se o usuário tem acesso ao team do subdomain
    requested_team = Team.find_by(subdomain: subdomain)
    return nil unless requested_team

    # Permitir apenas se for o team do usuário atual
    if @current_user.present? && @current_user.respond_to?(:team) && (requested_team == @current_user.team)
      return requested_team
    end

    nil
  end

  def current_user_team
    return if @current_user.blank?
    return unless @current_user.respond_to?(:team)

    @current_user.team
  end

  def ensure_team_access
    return if current_team.present?

    render json: { error: 'Team not found or access denied' }, status: :forbidden
  end

  def team_scoped(model)
    # Super admin tem acesso total ao sistema, sem limitação de team
    return model if super_admin_access?

    if model.reflect_on_association(:team)
      model.where(team: current_team)
    else
      model
    end
  end

  def ensure_belongs_to_current_team(record)
    return unless record.respond_to?(:team)

    # Super admin pode acessar qualquer resource
    return true if super_admin_access?

    unless record.team == current_team
      render json: { error: 'Resource not found' }, status: :not_found
      return false
    end

    true
  end

  def super_admin_access?
    # Verifica se o usuário atual tem role de super_admin
    @current_user.present? &&
      @current_user.respond_to?(:user_profile) &&
      @current_user.user_profile&.role == 'super_admin'
  end
end
