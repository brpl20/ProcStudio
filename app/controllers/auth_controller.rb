# frozen_string_literal: true

class AuthController < ApplicationController
  include JwtAuth
  skip_before_action :verify_authenticity_token

  def authenticate
    admin = Admin.find_for_authentication(email: params[:email])
    if admin&.valid_password?(params[:password])
      exp = Time.now.to_i + 24 * 3600
      token = JWT.encode({ admin_id: admin.id, exp: exp }, Rails.application.secret_key_base)
      admin.update(jwt_token: token)
      render json: { token: token }
    else
      head :unauthorized
    end
  end

  def destroy
    # Invalidar o token JWT do usuário atual
    admin_id = decode_jwt_token(request.headers['Authorization'].split(' ').last)['admin_id']
    current_admin = Admin.find(admin_id)
    current_admin.update_attribute(:jwt_token, nil)
    render json: { success: true, message: 'Saiu com successo' }
  end
end
