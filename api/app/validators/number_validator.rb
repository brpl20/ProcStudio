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
      
      Extenso.numero(value.to_i, genero)
    end
  end
end