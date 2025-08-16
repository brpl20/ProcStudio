# frozen_string_literal: true

class OabApiService
  include HTTParty
  
  base_uri ENV['LEGAL_DATA_ENDPOINT']
  
  def initialize
    @api_key = ENV['LEGAL_DATA_API_KEY']
  end
  
  def find_lawyer(oab_number)
    return nil if oab_number.blank?
    
    response = self.class.get("/#{oab_number}", {
      headers: {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json'
      },
      timeout: 10
    })
    
    if response.success?
      parse_lawyer_data(response.parsed_response)
    else
      Rails.logger.error "OAB API Error: #{response.code} - #{response.message}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "OAB API Service Error: #{e.message}"
    nil
  end
  
  private
  
  def parse_lawyer_data(data)
    return nil unless data&.dig('principal')
    
    principal = data['principal']
    
    {
      full_name: principal['full_name'],
      name: extract_first_name(principal['full_name']),
      last_name: extract_last_name(principal['full_name']),
      oab: principal['oab_number'],
      city: principal['city'],
      state: principal['state'],
      address: principal['address'],
      zip_code: clean_zip_code(principal['zip_code']),
      phone: clean_phone(principal['phone_number_1']),
      profile_picture_url: principal['profile_picture'],
      situation: principal['situation']
    }
  end
  
  def extract_first_name(full_name)
    return nil if full_name.blank?
    full_name.split(' ').first
  end
  
  def extract_last_name(full_name)
    return nil if full_name.blank?
    parts = full_name.split(' ')
    return nil if parts.length <= 1
    parts[1..-1].join(' ')
  end
  
  def clean_zip_code(zip_code)
    return nil if zip_code.blank?
    # Remove caracteres não numéricos e formata como XXXXX-XXX
    cleaned = zip_code.gsub(/\D/, '')
    return nil if cleaned.length != 8
    "#{cleaned[0..4]}-#{cleaned[5..7]}"
  end
  
  def clean_phone(phone)
    return nil if phone.blank?
    # Remove parênteses, espaços e hífens
    phone.gsub(/[\(\)\s\-]/, '')
  end
end