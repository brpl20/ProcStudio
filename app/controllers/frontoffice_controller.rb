# frozen_string_literal: true

class FrontofficeController < ApplicationController
  include JwtAuth
  include Pundit::Authorization

  before_action :authenticate_customer

  rescue_from Pundit::NotAuthorizedError, with: :unauthorized

  def current_user
    @current_user ||= @current_customer
  end

  def unauthorized(exception)
    error = I18n.t("customer.#{exception.query}", scope: 'pundit', default: :default)
    error = 'Você precisa confirmar o seu e-mail antes de continuar.' if current_user.present? && !current_user.confirmed?

    render json: { error: error }, status: :unauthorized
  end
end
