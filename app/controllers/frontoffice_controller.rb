# frozen_string_literal: true

class FrontofficeController < ApplicationController
  include JwtAuth
  include Pundit::Authorization

  before_action :authenticate_customer

  rescue_from Pundit::NotAuthorizedError, with: :unauthorized

  # Pundit usa current_user por padrão, então mantemos o método mas com nome mais claro
  def current_user
    @current_customer
  end

  def unauthorized(exception)
    error = I18n.t("customer.#{exception.query}", scope: 'pundit', default: :default)
    if @current_customer.present? && !@current_customer.confirmed?
      error = 'Você precisa confirmar o seu e-mail antes de continuar.'
    end

    render json: { error: error }, status: :unauthorized
  end
end
