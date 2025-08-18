# frozen_string_literal: true

class BackofficeController < ApplicationController
  include JwtAuth
  include Pundit::Authorization
  include TeamScoped

  before_action :authenticate_admin
  before_action :set_current_team

  rescue_from Pundit::NotAuthorizedError, with: :unauthorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Pundit usa current_user por padrão, mas podemos sobrescrever com pundit_user
  def pundit_user
    @current_admin
  end

  def unauthorized(exception)
    render json: {
      error: I18n.t("admin.#{exception.query}", scope: 'pundit', default: :default)
    }, status: :unauthorized
  end

  def filter_by_deleted_params
    params.permit(:deleted)
  end

  def destroy_fully?
    truthy_param?(:destroy_fully)
  end

  def secret_key_access
    secret_key = request.headers['HTTP_AUTHORIZATION']
    # TODO: Remover
    # credential = Rails.application.credentials[:webhook_secret_key]
    credential = CredentialsHelper.get(:zapsign, :webhook_secret_key)

    return unless secret_key.blank? || credential.blank? || secret_key != credential

    render json: { error: 'Acesso não autorizado' }, status: :unauthorized
  end

  def record_not_found(exception)
    # Quando é um Admin não encontrado por scoping de team,
    # é na verdade um problema de autorização, não de recurso inexistente
    if exception.model == 'Admin'
      render json: { error: I18n.t('errors.messages.general.unauthorized_access') }, status: :forbidden
    else
      model_name = exception.model || 'Registro'
      render json: { error: "#{model_name} não encontrado" }, status: :not_found
    end
  end
end
