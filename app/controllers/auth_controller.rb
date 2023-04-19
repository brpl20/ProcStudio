# frozen_string_literal: true

class AuthController < ApplicationController
  def authenticate
    admin = Admin.find_for_authentication(email: params[:email])
    if admin&.valid_password?(params[:password])
      token = JWT.encode({ admin_id: admin.id }, Rails.application.secret_key_base)
      render json: { token: token }
    else
      head :unauthorized
    end
  end
end
