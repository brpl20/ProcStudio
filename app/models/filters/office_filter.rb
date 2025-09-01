# frozen_string_literal: true

class OfficeFilter
  class << self
    def retrieve_office(id)
      Office.find(id)
    end

    def retrieve_offices
      Office.includes(:phones, :addresses, :office_emails, :office_bank_accounts).all
    end

    def retrieve_offices_with_lawyers
      # Get all offices that have users with OAB (lawyers)
      Office
        .joins(:users)
        .includes(:users, :user_offices)
        .where.not(users: { oab: [nil, ''] })
        .distinct
    end
  end
end
