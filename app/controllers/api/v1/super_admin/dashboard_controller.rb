class Api::V1::SuperAdmin::DashboardController < BackofficeController
  before_action :require_super_admin!

  def index
    stats = {
      system_overview: {
        total_admins: Admin.count,
        total_teams: Team.count,
        total_customers: Customer.count,
        total_works: Work.count,
        active_subscriptions: Subscription.active.count
      },
      recent_activity: {
        new_users_this_month: Admin.where(created_at: 1.month.ago..Time.current).count,
        new_works_this_week: Work.where(created_at: 1.week.ago..Time.current).count,
        active_teams: Team.joins(:team_memberships).where(team_memberships: { status: 'active' }).distinct.count
      },
      system_settings: {
        current_minimum_wage: SystemSetting.current_minimum_wage,
        current_inss_ceiling: SystemSetting.current_inss_ceiling,
        settings_year: Date.current.year
      }
    }

    render json: stats, status: :ok
  end
end
