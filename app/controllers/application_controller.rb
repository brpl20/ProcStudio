# frozen_string_literal: true

# controladora geral
class ApplicationController < ActionController::Base
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
