# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ErrorHandler

  protected

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end

  def load_active_storage_url_options
    ActiveStorage::Current.url_options = { host: request.base_url }
  end
end
