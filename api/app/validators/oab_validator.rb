# frozen_string_literal: true

class OabValidator
  class << self
    def format_oab(oab_id)
      return nil if oab_id.blank?
      
      match = oab_id.to_s.match(/([A-Z]{2})[_]?(\d+)/)
      return oab_id unless match
      
      state, number = match.captures
      formatted_number = number.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1.')
      "OAB/#{state} #{formatted_number}"
    end
  end
end