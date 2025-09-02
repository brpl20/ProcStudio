# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # ErrorHandler is not included here to avoid conflicts with BackofficeController
  # Include it directly in controllers that need it and don't inherit from BackofficeController

  helper_method :current_user, :logged_in?

  protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end

  def logged_in?
    !!current_user
  end

  def require_login
    return if logged_in?

    flash[:alert] = 'Você precisa fazer login para acessar esta página'
    redirect_to login_path
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end

  def load_active_storage_url_options
    ActiveStorage::Current.url_options = { host: request.base_url }
  end
end
