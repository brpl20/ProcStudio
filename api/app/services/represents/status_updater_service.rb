# frozen_string_literal: true

module Represents
  class StatusUpdaterService
    def initialize(represent)
      @represent = represent
    end

    def deactivate
      @represent.update(active: false, end_date: Date.current)
    end

    def reactivate
      @represent.update(active: true, end_date: nil)
    end

    private

    attr_reader :represent
  end
end
