# frozen_string_literal: true

class BackofficeController < ApplicationController
  include JwtAuth
  include Pundit::Authorization

  before_action :authenticate_admin

  rescue_from Pundit::NotAuthorizedError, with: :unauthorized

  def current_user
    @current_user ||= @current_admin
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
end
