# frozen_string_literal: true

require 'extensobr'

class NumberValidator
  class << self
    def format(value)
      return nil if value.blank?
      
      value.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1.')
    end

    def por_extenso(value, genero = 0)
      return nil if value.blank?
      
      # Handle decimal numbers
      if value.to_s.include?('.') || value.to_s.include?(',')
        number_str = value.to_s.gsub(',', '.')
        parts = number_str.split('.')
        integer_part = parts[0].to_i
        decimal_part = parts[1] if parts[1]
        
        if decimal_part && decimal_part.to_i > 0
          integer_extenso = Extenso.numero(integer_part, genero)
          decimal_extenso = Extenso.numero(decimal_part.to_i, genero)
          "#{integer_extenso} vírgula #{decimal_extenso}"
        else
          Extenso.numero(integer_part, genero)
        end
      else
        Extenso.numero(value.to_i, genero)
      end
    end
  end
end