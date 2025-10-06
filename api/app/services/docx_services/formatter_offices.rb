# frozen_string_literal: true

# FormatterOffices methods são para extrair informações de uma office e as suas relações com os advogados
# NÃO é para extrair a qualificação, nome e outros atributos que estão concentrados no formatter_qualification

require_relative 'formatter_constants_offices'
require_relative 'concerns/gender_determinable'

module DocxServices
  class FormatterOffices
    include FormatterConstantsOffices
    include Concerns::GenderDeterminable

    attr_reader :data, :office, :lawyers, :lawyers_society_info

    def initialize(office, _lawyers = nil)
      @office = office
      @lawyers = office.user_profiles
      @lawyers_society_info = office.user_offices
      @data = extract_data(office)
    end

    class << self
      def for(entity, **)
        new(entity, **)
      end
    end

    def society
      return nil unless data[:society]

      SOCIETY[data[:society].to_sym] || data[:society]
    end

    def accounting_type
      return nil unless data[:accounting_type]

      ACCOUNTING_TYPE[data[:accounting_type].to_sym] || data[:accounting_type]
    end

    def oab_status
      return nil unless data[:oab_status]

      OAB_STATUS[data[:oab_status].to_sym] || data[:oab_status]
    end

    def oab_id
      return nil unless data[:oab_id]

      OabValidator.format_oab(data[:oab_id])
    end

    def oab_inscricao
      data[:oab_inscricao]
    end

    def quote_value(extenso: false)
      return nil unless data[:quote_value]

      formatted = MonetaryValidator.format(data[:quote_value])
      if extenso && formatted
        por_extenso = MonetaryValidator.por_extenso(data[:quote_value])
        "#{formatted} (#{por_extenso})"
      else
        formatted
      end
    end

    def number_of_quotes(extenso: false)
      return nil unless data[:number_of_quotes]

      formatted = NumberValidator.format(data[:number_of_quotes])
      if extenso && formatted
        por_extenso = NumberValidator.por_extenso(data[:number_of_quotes])
        "#{formatted} (#{por_extenso})"
      else
        formatted
      end
    end

    # Relacionamento do Office com os Advogados (users)
    def partnership_type(lawyer_number:)
      lawyer_info = @lawyers_society_info[lawyer_number - 1]
      return nil unless lawyer_info&.partnership_type

      PARTNERSHIP_TYPE[lawyer_info.partnership_type.to_sym] || lawyer_info.partnership_type
    end

    def partnership_percentage(lawyer_number:)
      lawyer_info = @lawyers_society_info[lawyer_number - 1]
      return nil unless lawyer_info&.partnership_percentage

      "#{lawyer_info.partnership_percentage.to_i}%"
    end

    def is_administrator(lawyer_number:)
      lawyer_info = @lawyers_society_info[lawyer_number - 1]
      return nil unless lawyer_info

      lawyer_info.is_administrator
    end

    def partners_count
      @lawyers_society_info.length
    end

    def partners_info
      @lawyers_society_info.map.with_index do |lawyer_info, index|
        lawyer_num = index + 1
        percentage = lawyer_info.partnership_percentage.to_f

        {
          number: lawyer_num,
          partnership_type: PARTNERSHIP_TYPE[lawyer_info.partnership_type.to_sym] || lawyer_info.partnership_type,
          partnership_percentage: "#{lawyer_info.partnership_percentage.to_i}%",
          is_administrator: lawyer_info.is_administrator,
          partner_quote_value: calculate_partner_quote_value(percentage),
          partner_quote_value_formatted: format_partner_quote_value(percentage),
          partner_number_of_quotes: calculate_partner_number_of_quotes(percentage),
          partner_number_of_quotes_formatted: format_partner_number_of_quotes(percentage)
        }
      end
    end

    def entry_date; end

    def partner_subscription(lawyer_number:)
      lawyer_info = @lawyers_society_info[lawyer_number - 1]
      return nil unless lawyer_info

      lawyer = @lawyers[lawyer_number - 1]
      return nil unless lawyer

      lawyer_formatter = FormatterQualification.new(lawyer)
      percentage = lawyer_info.partnership_percentage.to_f

      partner_quotes = calculate_partner_number_of_quotes(percentage)
      partner_quote_value = calculate_partner_quote_value(percentage)
      individual_quote_value = data[:quote_value] ? (data[:quote_value] / data[:number_of_quotes].to_f) : 0

      return nil unless partner_quotes && partner_quote_value

      # Get gender from lawyer
      gender = determine_lawyer_gender(lawyer)
      partnership_type_key = lawyer_info.partnership_type&.to_sym || :socio

      # Get the appropriate prefix based on gender and partnership type
      prefix = PARTNERSHIP_SUBSCRIPTION_PREFIXES.dig(gender, partnership_type_key) || 'O sócio'

      # Format numbers with Brazilian formatting and lowercase extenso
      partner_quotes_formatted = format_brazilian_number(partner_quotes)
      partner_quotes_extenso = NumberValidator.por_extenso(partner_quotes).downcase
      individual_quote_extenso = MonetaryValidator.por_extenso(individual_quote_value).downcase
      total_value_extenso = MonetaryValidator.por_extenso(partner_quote_value).downcase

      "#{prefix} #{lawyer_formatter.full_name(upcase: true)}, #{SUBSCRIPTION_TEMPLATE} #{partner_quotes_formatted} (#{partner_quotes_extenso}) #{QUOTES_TEXT} #{MonetaryValidator.format(individual_quote_value)} (#{individual_quote_extenso}) #{EACH_ONE_TEXT} #{MonetaryValidator.format(partner_quote_value)} (#{total_value_extenso})"
    end

    def all_partners_subscription
      @lawyers_society_info.map.with_index do |_, index|
        partner_subscription(lawyer_number: index + 1)
      end.compact.join('; ')
    end

    private

    def extract_data(entity)
      return entity if entity.is_a?(Hash)

      # Extract data from ActiveRecord model
      extracted = {}

      # Office info
      extracted[:society] = entity.society if entity.respond_to?(:society)
      extracted[:accounting_type] = entity.accounting_type if entity.respond_to?(:accounting_type)
      extracted[:oab_status] = entity.oab_status if entity.respond_to?(:oab_status)
      extracted[:oab_id] = entity.oab_id if entity.respond_to?(:oab_id)
      extracted[:oab_inscricao] = entity.oab_inscricao if entity.respond_to?(:oab_inscricao)
      extracted[:quote_value] = entity.quote_value if entity.respond_to?(:quote_value)
      extracted[:number_of_quotes] = entity.number_of_quotes if entity.respond_to?(:number_of_quotes)

      extracted.with_indifferent_access
    end

    def calculate_partner_quote_value(percentage)
      return nil unless data[:quote_value] && percentage.positive?

      total_value = data[:quote_value].to_f
      (total_value * percentage / 100).round(2)
    end

    def format_partner_quote_value(percentage)
      partner_value = calculate_partner_quote_value(percentage)
      return nil unless partner_value

      MonetaryValidator.format(partner_value)
    end

    def calculate_partner_number_of_quotes(percentage)
      return nil unless data[:number_of_quotes] && percentage.positive?

      total_quotes = data[:number_of_quotes].to_f
      (total_quotes * percentage / 100).round(2)
    end

    def format_partner_number_of_quotes(percentage)
      partner_quotes = calculate_partner_number_of_quotes(percentage)
      return nil unless partner_quotes

      NumberValidator.format(partner_quotes)
    end

    def determine_lawyer_gender(lawyer)
      determine_gender(lawyer)
    end

    def format_brazilian_number(number)
      return nil unless number
      # Use existing NumberValidator to format with thousand separators
      # and handle decimals properly
      NumberValidator.format(number)
    end
  end
end
