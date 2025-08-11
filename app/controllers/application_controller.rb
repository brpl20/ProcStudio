# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    head :not_found
  end

  def require_super_admin!
    unless current_admin&.super_admin?
      render json: { error: 'Super admin access required' }, status: :forbidden
    end
  end

  protected

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end

  def load_active_storage_url_options
    ActiveStorage::Current.url_options = { host: request.base_url }
  end
end
