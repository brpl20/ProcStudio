

    def partner_subscription_text
      if lawyers.size == 1
        lawyer = lawyers.first
        quotes = format_number(lawyer_quotes(lawyer))
        value = quote_value.to_i
        total = format_currency(lawyer_capital_value(lawyer))

        format(SUBSCRIPTION_TEXT[:single],
               name: lawyer_full_name(lawyer),
               quotes: quotes,
               value: value,
               total: total)
      else
        lines = []
        lawyers.each do |lawyer|
          quotes = format_number(lawyer_quotes(lawyer))
          value = quote_value.to_i
          total = format_currency(lawyer_capital_value(lawyer))

          line = format(SUBSCRIPTION_TEXT[:multiple],
                        name: lawyer_full_name(lawyer),
                        quotes: quotes,
                        value: value,
                        total: total)
          lines << line
        end
        lines.join(SEPARATORS[:partner_lines])
      end
    end

    def partner_total_quotes_text
      if lawyers.size == 1
        format_number(lawyer_quotes(lawyers.first))
      else
        admin_lawyer = find_administrator_lawyer || lawyers.first
        format_number(lawyer_quotes(admin_lawyer))
      end
    end

    def partner_sum_text
      if lawyers.size == 1
        format_currency(lawyer_capital_value(lawyers.first))
      else
        admin_lawyer = find_administrator_lawyer || lawyers.first
        format_currency(lawyer_capital_value(admin_lawyer))
      end
    end

    def percentage_text
      if lawyers.size == 1
        OFFICE_DEFAULTS[:full_percentage]
      else
        admin_lawyer = find_administrator_lawyer || lawyers.first
        format(OFFICE_DEFAULTS[:percentage_format], value: lawyer_percentage(admin_lawyer))
      end
    end

    def total_quotes
      # Get from office or user_offices association
      if office.respond_to?(:total_quotes)
        office.total_quotes
      else
        # Default value or calculate from user_offices
        calculate_total_quotes
      end
    end

    def quote_value
      # Calculate quote value
      total_capital_value.to_f / total_quotes
    end

    def total_capital_value
      # Get from office or user_offices association
      if office.respond_to?(:capital_value)
        office.capital_value
      else
        # Default value or calculate from user_offices
        calculate_total_capital_value
      end
    end

    def lawyer_quotes(lawyer)
      # Check if there's a user_office association
      user_office = find_user_office(lawyer)
      return user_office.quotes if user_office.respond_to?(:quotes)

      # Otherwise, divide equally among lawyers
      total_quotes / lawyers.size
    end

    def lawyer_capital_value(lawyer)
      # Check if there's a user_office association
      user_office = find_user_office(lawyer)
      return user_office.capital_value if user_office.respond_to?(:capital_value)

      # Calculate based on percentage or equal division
      total_capital_value / lawyers.size
    end

    def lawyer_percentage(lawyer)
      # Check if there's a user_office association
      user_office = find_user_office(lawyer)
      return user_office.percentage if user_office.respond_to?(:percentage)

      # Calculate percentage
      (100.0 / lawyers.size).round(2)
    end

    def lawyer_full_name(lawyer)
      FormatterQualification.for(lawyer).full_name(upcase: true)
    end

    def lawyer_association(lawyer)
      user_office = find_user_office(lawyer)

      # Check if specified in user_office
      return user_office.role if user_office.respond_to?(:role) && user_office.role.present?

      # Check if administrator
      return PARTNER_ROLES[:administrator] if is_administrator?(lawyer)

      PARTNER_ROLES[:partner]
    end

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
