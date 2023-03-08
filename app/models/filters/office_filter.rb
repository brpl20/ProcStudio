# frozen_string_literal: true

class OfficeFilter
  class << self
    def retrieve_office(id)
      Office.find(id)
    end

    def retrieve_offices
      Office.all
    end
  end
end
