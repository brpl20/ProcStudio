    def find_administrator_lawyer
      # Look for administrator in user_offices
      if office.respond_to?(:user_offices)
        admin_office = office.user_offices.find_by(role: ROLE_IDENTIFIERS[:administrator]) ||
                       office.user_offices.find_by(is_admin: true)
        return admin_office.users_profile if admin_office
      end

      # Default to first lawyer as administrator
      lawyers.first
    end

    def is_administrator?(lawyer)
      user_office = find_user_office(lawyer)

      # Check user_office association for admin status
      return true if user_office.respond_to?(:is_admin) && user_office.is_admin
      return true if user_office.respond_to?(:role) && user_office.role == ROLE_IDENTIFIERS[:administrator]

      # Check if lawyer is the default administrator
      find_administrator_lawyer == lawyer
    end

    def pro_labore_enabled?
      # Check if pro labore is enabled in office
      return office.pro_labore_enabled if office.respond_to?(:pro_labore_enabled)

      PRO_LABORE[:enabled_by_default]
    end

    def pro_labore_text
      # Check for custom text in office
      return office.pro_labore_text if office.respond_to?(:pro_labore_text) && office.pro_labore_text.present?

      PRO_LABORE[:default_text]
    end

    def dividends_enabled?
      # Check if dividends clause is enabled in office
      return office.dividends_enabled if office.respond_to?(:dividends_enabled)

      DIVIDENDS[:enabled_by_default]
    end

    def dividends_text
      # Check for custom text in office
      return office.dividends_text if office.respond_to?(:dividends_text) && office.dividends_text.present?

      DIVIDENDS[:default_text]
    end


    private

    def find_user_office(lawyer)
      return nil unless office.respond_to?(:user_offices)

      # Find UserOffice record for this lawyer and office
      office.user_offices.find_by(users_profile: lawyer)
    end

    def calculate_total_quotes
      if office.respond_to?(:user_offices) && office.user_offices.any?
        office.user_offices.sum(:quotes) || OFFICE_DEFAULTS[:total_quotes]
      else
        OFFICE_DEFAULTS[:total_quotes]
      end
    end

    def calculate_total_capital_value
      if office.respond_to?(:user_offices) && office.user_offices.any?
        office.user_offices.sum(:capital_value) || OFFICE_DEFAULTS[:total_capital_value]
      else
        OFFICE_DEFAULTS[:total_capital_value]
      end
    end

    def format_currency(value)
      formatted = value.to_i.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, FORMATTING[:currency_separator])
      "#{formatted}#{FORMATTING[:currency_decimal]}"
    end

    def format_number(value)
      value.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, FORMATTING[:thousands_separator])
    end
  end
end
