# frozen_string_literal: true

class OfficeFilter
  class << self
    def retrieve_office(id, team)
      team.offices.find(id)
    end

    def retrieve_offices(team)
      team.offices.includes(:phones, :addresses, :office_emails, :office_bank_accounts)
    end

    def retrieve_offices_with_lawyers(team)
      # Get all offices that have users with OAB (lawyers) for current team
      team.offices
        .joins(:users)
        .includes(:users, :user_offices)
        .where.not(users: { oab: [nil, ''] })
        .distinct
    end
  end
end
