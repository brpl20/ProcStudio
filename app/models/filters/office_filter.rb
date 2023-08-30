# frozen_string_literal: true

class OfficeFilter
  class << self
    def retrieve_office(id)
      Office.find(id)
    end

    def retrieve_offices
      Office.includes(:office_phones, :office_emails, :office_bank_accounts, :office_type).all
    end

    def retrieve_offices_with_lawyers
      Office
        .includes(:profile_admins)
        .where(profile_admins: { role: 'lawyer' })
    end
  end
end
