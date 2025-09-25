# frozen_string_literal: true

module DocxServices
  class FormatterOffices
    attr_reader :office, :lawyers

    def initialize(office, lawyers = nil)
      @office = office
      @lawyers = lawyers || office.users_profiles
    end

    class << self
      def for_office(office, lawyers = nil)
        new(office, lawyers)
      end
    end

    def partner_subscription_text
      if lawyers.size == 1
        lawyer = lawyers.first
        quotes = format_number(lawyer_quotes(lawyer))
        value = quote_value.to_i
        total = format_currency(lawyer_capital_value(lawyer))

        "O Sócio #{lawyer_full_name(lawyer)}, subscreve e integraliza neste ato #{quotes} quotas " \
          "no valor de R$ #{value},00 cada uma, perfazendo o total de R$ #{total},00"
      else
        lines = []
        lawyers.each do |lawyer|
          quotes = format_number(lawyer_quotes(lawyer))
          value = quote_value.to_i
          total = format_currency(lawyer_capital_value(lawyer))

          line = "O Sócio #{lawyer_full_name(lawyer)}, subscreve e integraliza neste ato #{quotes} quotas " \
                 "no valor de R$ #{value},00 cada uma, perfazendo o total de R$ #{total},00;"
          lines << line
        end
        lines.join("\n\n")
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
        '100%'
      else
        admin_lawyer = find_administrator_lawyer || lawyers.first
        "#{lawyer_percentage(admin_lawyer)}%"
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
      Formatter.build(lawyer).full_name
    end

    def lawyer_association(lawyer)
      user_office = find_user_office(lawyer)

      # Check if specified in user_office
      return user_office.role if user_office.respond_to?(:role) && user_office.role.present?

      # Check if administrator
      return 'Sócio Administrador' if is_administrator?(lawyer)

      'Sócio'
    end

    def find_administrator_lawyer
      # Look for administrator in user_offices
      if office.respond_to?(:user_offices)
        admin_office = office.user_offices.find_by(role: 'administrator') ||
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
      return true if user_office.respond_to?(:role) && user_office.role == 'administrator'

      # Check if lawyer is the default administrator
      find_administrator_lawyer == lawyer
    end

    def pro_labore_enabled?
      # Check if pro labore is enabled in office
      return office.pro_labore_enabled if office.respond_to?(:pro_labore_enabled)

      true # Default to enabled
    end

    def pro_labore_text
      # Check for custom text in office
      return office.pro_labore_text if office.respond_to?(:pro_labore_text) && office.pro_labore_text.present?

      'Pelo exercício da administração terão os sócios administradores direito a uma retirada mensal ' \
        'a título de "pró-labore", cujo valor será fixado em comum acordo entre os sócios e levado à ' \
        'conta de Despesas Gerais da Sociedade.'
    end

    def dividends_enabled?
      # Check if dividends clause is enabled in office
      return office.dividends_enabled if office.respond_to?(:dividends_enabled)

      true # Default to enabled
    end

    def dividends_text
      # Check for custom text in office
      return office.dividends_text if office.respond_to?(:dividends_text) && office.dividends_text.present?

      'Os sócios receberão dividendos proporcionais às suas respectivas participações no capital social.'
    end

    def office_name
      office&.name
    end

    def office_city
      office&.city || office_address&.city
    end

    def office_state
      office&.state || office_address&.state
    end

    def office_street
      street = office&.street || office_address&.street
      street&.to_s&.downcase&.titleize || ''
    end

    def office_zip_code
      office&.zip || office&.zip_code || office_address&.zip_code || ''
    end

    def office_address
      # Get address from office association if available
      return office.address if office.respond_to?(:address) && office.address
      return office.addresses.first if office.respond_to?(:addresses) && office.addresses.any?

      nil
    end

    private

    def find_user_office(lawyer)
      return nil unless office.respond_to?(:user_offices)

      # Find UserOffice record for this lawyer and office
      office.user_offices.find_by(users_profile: lawyer)
    end

    def calculate_total_quotes
      if office.respond_to?(:user_offices) && office.user_offices.any?
        office.user_offices.sum(:quotes) || 10_000
      else
        10_000 # Default value
      end
    end

    def calculate_total_capital_value
      if office.respond_to?(:user_offices) && office.user_offices.any?
        office.user_offices.sum(:capital_value) || 10_000
      else
        10_000 # Default value
      end
    end

    def format_currency(value)
      "#{value.to_i.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, '.')},00"
    end

    def format_number(value)
      value.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, '.')
    end
  end
end
