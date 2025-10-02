# frozen_string_literal: true

require 'extensobr'

class MonetaryValidator
  class << self
    def format(value)
      return nil if value.blank?
      
      number = value.to_f
      formatted = sprintf('%.2f', number)
                  .gsub('.', ',')
                  .gsub(/(\d)(?=(\d{3})+,)/, '\1.')
      "R$ #{formatted}"
    end

    def por_extenso(value)
      return nil if value.blank?
      
      Extenso.moeda(value.to_f)
    end

    def real_formatado(value)
      return nil if value.blank?
      
      Extenso.real_formatado(value.to_f)
    end
  end
end