# frozen_string_literal: true

class Api::V1::Customer::AuthController < ApplicationController
  include JwtAuth

  def authenticate
    if params[:provider] == 'google'
      authenticate_with_google
    else
      authenticate_with_email_and_password
    end
  end

  def destroy
    if request.headers['Authorization'].nil?
      render json: { success: false, message: 'Usuário não autorizado' }, status: :unauthorized
    else
      token = request.headers['Authorization'].split.last
      decoded_token = decode_jwt_token(token)

      if decoded_token.nil?
        render json: { success: false, message: 'Usuário não autorizado' }, status: :unauthorized
      else
        customer_id = decoded_token['customer_id']
        current_customer = Customer.find(customer_id)
        current_customer.update_attribute(:jwt_token, nil)
        render json: { success: true, message: 'Saiu com successo' }
      end
    end
  end

  # GET /api/v1/customer/confirm?confirmation_token=abcde
  def confirm
    customer = Customer.confirm_by_token(params[:confirmation_token])

    if customer.errors.empty?
      token = update_user_token(customer)
      render json: { token: token, full_name: customer.profile_customer_full_name }
    else
      render json: {
        success: false,
        message: customer.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/customer/reset_password
  def reset_password
    Customer.send_reset_password_instructions(reset_password_params)
    head :ok
  end

  # POST /api/v1/customer/update_password
  def update_password
    customer = Customer.reset_password_by_token(update_password_params)

    if customer.errors.empty?
      token = update_user_token(customer)
      render json: { token: token, full_name: customer.profile_customer_full_name }
    else
      render json: {
        success: false,
        message: customer.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_with_email_and_password
    customer = Customer.find_for_authentication(email: auth_params[:email])

    if customer&.valid_password?(auth_params[:password])
      token = update_user_token(customer)
      render json: { token: token, full_name: customer.profile_customer_full_name }
    else
      head :unauthorized
    end
  end

  def authenticate_with_google
    access_token = params[:accessToken]
    return head :unauthorized if access_token.blank?

    user_info = fetch_google_user_info(access_token)
    return head :unauthorized if user_info.nil?

    email = user_info['email']
    return head :unauthorized if email.blank?

    customer = Customer.find_for_authentication(email: email)

    if customer
      token = update_user_token(customer)
      render json: { token: token, full_name: customer.profile_customer_full_name }
    else
      head :not_found
    end
  end

  def fetch_google_user_info(access_token)
    uri = URI('https://www.googleapis.com/oauth2/v3/tokeninfo')
    params = { access_token: access_token }
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error("Error fetching Google user info: #{e.message}")
    nil
  end

  def update_user_token(customer)
    exp = 24.hours.from_now.to_i
    token = JWT.encode({ customer_id: customer.id, exp: exp }, Rails.application.secret_key_base)
    customer.update(jwt_token: token)
    token
  end

  def auth_params
    params.expect(auth: [:email, :password])
  end

  def decode_jwt_token(token)
    secret_key = Rails.application.secret_key_base
    decoded_token = JWT.decode(token, secret_key)[0]
    ActiveSupport::HashWithIndifferentAccess.new decoded_token
  rescue JWT::DecodeError
    # puts "Error decoding JWT token: #{e.message}"
    nil
  end

  def reset_password_params
    params.expect(customer: [:email])
  end

  def update_password_params
    params.expect(customer: [:password, :password_confirmation, :reset_password_token])
  end
end
