# frozen_string_literal: true

class Offices
  class << self
    def create_office(params)
      Rails.logger.debug params
    end
  end
end
