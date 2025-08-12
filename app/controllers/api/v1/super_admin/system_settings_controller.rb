class Api::V1::SuperAdmin::SystemSettingsController < BackofficeController
  before_action :require_super_admin!
  before_action :set_system_setting, only: [:update]

  def index
    settings = SystemSetting.active.order(:year, :key)

    render json: {
      settings: settings.map do |setting|
        {
          id: setting.id,
          key: setting.key,
          value: setting.value,
          year: setting.year,
          description: setting.description,
          active: setting.active
        }
      end,
      current_year: Date.current.year,
      available_keys: [
        SystemSetting::MINIMUM_WAGE,
        SystemSetting::INSS_CEILING
      ]
    }, status: :ok
  end

  def update
    if @setting.update(system_setting_params)
      render json: {
        id: @setting.id,
        key: @setting.key,
        value: @setting.value,
        year: @setting.year,
        description: @setting.description,
        active: @setting.active
      }, status: :ok
    else
      render json: {
        errors: @setting.errors.full_messages
      }, status: :bad_request
    end
  end

  private

  def set_system_setting
    @setting = SystemSetting.find(params[:id])
  end

  def system_setting_params
    params.require(:system_setting).permit(:value, :description, :active)
  end
end
