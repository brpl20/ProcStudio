# frozen_string_literal: true

module Users
  class QueryService
    def self.build_query(params:, team_scoped_proc:, **_options)
      users = if development_bypass?(params)
                User.includes(:user_profile, :team)
              else
                team_scoped_proc.call(User).includes(:user_profile)
              end

      apply_filters(users, extract_filter_params(params))
    end

    def self.development_bypass?(params)
      Rails.env.development? && params[:all_teams] == 'true'
    end

    def self.extract_filter_params(params)
      # Only use :deleted as it's the only filter supported by filter_by_deleted_params
      params.slice(:deleted).compact_blank
    end

    def self.apply_filters(users, filter_params)
      filter_params.each do |key, value|
        users = users.public_send("filter_by_#{key}", value.strip)
      end
      users
    end
  end
end
