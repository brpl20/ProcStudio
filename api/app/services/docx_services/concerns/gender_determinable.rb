# frozen_string_literal: true

module DocxServices
  module Concerns
    module GenderDeterminable
      extend ActiveSupport::Concern

      private

      def determine_gender(entity, provided_gender = nil)
        return provided_gender.to_sym if provided_gender.present?

        if entity.respond_to?(:gender) && entity.gender.present?
          entity.gender.to_sym
        elsif entity.is_a?(Hash) && entity[:gender].present?
          entity[:gender].to_sym
        else
          :male # Default
        end
      end
    end
  end
end