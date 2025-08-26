# frozen_string_literal: true

class ApplicationController < ActionController::API
  # ErrorHandler is not included here to avoid conflicts with BackofficeController
  # Include it directly in controllers that need it and don't inherit from BackofficeController

  protected

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end

  def load_active_storage_url_options
    ActiveStorage::Current.url_options = { host: request.base_url }
  end
end
