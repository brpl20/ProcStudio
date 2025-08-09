# frozen_string_literal: true

module JwtAuth
  def authenticate_admin
    # Try normal JWT authentication first
    if token.present?
      head :unauthorized and return unless payload.key?('admin_id')

      @current_admin ||= Admin.find(payload['admin_id'])
      head :unauthorized unless @current_admin&.jwt_token == token
      head :unauthorized unless valid_token?
    elsif Rails.env.development? && development_bypass_enabled?
      # Only use bypass if no token is provided
      @current_admin ||= Admin.first || create_dev_admin
      set_current_team_for_dev if @current_admin
      return
    else
      head :unauthorized and return
    end
    
    # Set current team from JWT payload or default to first active team
    set_current_team_from_payload
  rescue JWT::DecodeError
    head :unauthorized
  end

  def authenticate_customer
    # Skip authentication in development mode for localhost
    if Rails.env.development? && development_bypass_enabled?
      @current_customer ||= Customer.first || create_dev_customer
      return
    end

    head :unauthorized and return unless payload.key?('customer_id')

    @current_customer ||= Customer.find(payload['customer_id'])
    head :unauthorized unless @current_customer&.jwt_token == token
    head :unauthorized unless valid_token?
  rescue JWT::DecodeError
    head :unauthorized
  end

  private

  def token
    @token ||= request.headers['Authorization']&.split(' ')&.last
  end

  def decode_token
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')[0]
  end

  def payload
    @payload ||= decode_token
  end

  def valid_token?
    Time.now.to_i < payload['exp']
  rescue JWT::DecodeError
    false
  end

  def development_bypass_enabled?
    # Enable bypass for localhost requests or when DEV_AUTH_BYPASS env var is set
    request.host.in?(['localhost', '127.0.0.1']) || ENV['DEV_AUTH_BYPASS'] == 'true'
  end

  def create_dev_admin
    Admin.create!(
      email: 'dev@localhost.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  rescue ActiveRecord::RecordInvalid
    Admin.first
  end

  def create_dev_customer
    Customer.create!(
      email: 'customer@localhost.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  rescue ActiveRecord::RecordInvalid
    Customer.first
  end

  def set_current_team_from_payload
    return unless @current_admin

    if payload.key?('team_id')
      team = Team.find_by(id: payload['team_id'])
      if team && @current_admin.can_access_team?(team)
        @current_team = team
      else
        head :unauthorized
      end
    else
      @current_team = @current_admin.current_team
    end
  end

  def set_current_team_for_dev
    return unless @current_admin
    
    @current_team = @current_admin.current_team || create_dev_team
  end

  def create_dev_team
    return unless @current_admin
    
    team = Team.create!(
      name: 'Development Team',
      subdomain: 'dev',
      owner_admin: @current_admin,
      main_admin: @current_admin
    )
    
    TeamMembership.create!(
      team: team,
      admin: @current_admin,
      role: 'owner',
      status: 'active'
    )
    
    team
  rescue ActiveRecord::RecordInvalid
    Team.first
  end
  
  def current_team
    @current_team
  end
  
  def require_team!
    head :unauthorized unless @current_team
  end
end
