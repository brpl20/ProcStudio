# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  layout :layout_by_resource

  protected

  def layout_by_resource
    if devise_controller?
      'devise_admin_custom'
    else
      'backoffice'
    end
  end
end
