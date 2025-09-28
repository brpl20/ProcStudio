# frozen_string_literal: true

module Drafts
  class DraftableFinderService
    VALID_TYPES = ['ProfileCustomer', 'UserProfile', 'Work', 'Job'].freeze

    def self.find(type:, id:)
      return nil if id.blank? || id == '0'
      raise InvalidTypeError, invalid_type_message(type) unless valid_type?(type)

      type.constantize.find(id)
    end

    def self.valid_type?(type)
      VALID_TYPES.include?(type)
    end

    def self.invalid_type_message(type)
      valid_types_list = VALID_TYPES.join(', ')
      "Tipo '#{type}' não é suportado. Tipos válidos: #{valid_types_list}"
    end

    class InvalidTypeError < StandardError; end
  end
end
