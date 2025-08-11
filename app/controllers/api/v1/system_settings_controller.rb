class Api::V1::SystemSettingsController < ApplicationController
  def index
    settings = SystemSetting.active.current_year
    
    render json: {
      minimum_wage: SystemSetting.current_minimum_wage,
      inss_ceiling: SystemSetting.current_inss_ceiling,
      settings: settings.map do |setting|
        {
          key: setting.key,
          value: setting.value,
          year: setting.year,
          description: setting.description
        }
      end
    }, status: :ok
  end

  def show
    key = params[:key]
    setting = SystemSetting.active.current_year.by_key(key).first
    
    if setting
      render json: {
        key: setting.key,
        value: setting.value,
        year: setting.year,
        description: setting.description
      }, status: :ok
    else
      render json: { error: "Setting not found for key: #{key}" }, status: :not_found
    end
  end
end
