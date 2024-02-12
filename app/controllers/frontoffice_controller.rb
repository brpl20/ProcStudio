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
    render json: {
      error: I18n.t("customer.#{exception.query}", scope: 'pundit', default: :default)
    }, status: :unauthorized
  end
end
