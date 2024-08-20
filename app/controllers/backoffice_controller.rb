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
end
