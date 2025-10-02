# frozen_string_literal: true

# FormatterOffices methods são para extrair informações de uma office e as suas relações com os advogados
# NÃO é para extrair a qualificação, nome e outros atributos que estão concentrados no formatter_qualification

require_relative 'formatter_constants_offices'

module DocxServices
  class FormatterOffices
    include FormatterConstantsOffices

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
    def partnership_type(lawyer_number = nil)
      raise ArgumentError, "Você deve especificar o número do advogado (1, 2, 3...)" if lawyer_number.nil?

      lawyer_info = @lawyers_society_info[lawyer_number - 1]
      return nil unless lawyer_info&.partnership_type

      PARTNERSHIP_TYPE[lawyer_info.partnership_type.to_sym] || lawyer_info.partnership_type
    end

    def partnership_percentage(lawyer_number = nil)
      raise ArgumentError, "Você deve especificar o número do advogado (1, 2, 3...)" if lawyer_number.nil?

      lawyer_info = @lawyers_society_info[lawyer_number - 1]
      return nil unless lawyer_info&.partnership_percentage

      "#{lawyer_info.partnership_percentage.to_i}%"
    end

    def is_administrator(lawyer_number = nil)
      raise ArgumentError, "Você deve especificar o número do advogado (1, 2, 3...)" if lawyer_number.nil?

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
        {
          number: lawyer_num,
          partnership_type: PARTNERSHIP_TYPE[lawyer_info.partnership_type.to_sym] || lawyer_info.partnership_type,
          partnership_percentage: "#{lawyer_info.partnership_percentage.to_i}%",
          is_administrator: lawyer_info.is_administrator
        }
      end
    end

    def entry_date
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
  end
end
