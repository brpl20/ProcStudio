# frozen_string_literal: true

class LegalData::LegalDataService
  include HTTParty

  def base_uri
    base_uri ENV.fetch('LEGAL_DATA_ENDPOINT') do
      raise 'LEGAL_DATA_ENDPOINT environment variable is not set'
    end
  end

  # Configuração para lidar com certificados SSL
  default_options.update(verify: false) if Rails.env.development?

  def initialize
    @api_key = ENV.fetch('LEGAL_DATA_API_KEY') do
      raise 'LEGAL_DATA_API_KEY environment variable is not set'
    end
  end

  def find_lawyer(oab_number)
    return nil if oab_number.blank?

    response = make_api_request(oab_number)
    process_api_response(response)
  rescue StandardError => e
    Rails.logger.error "OAB API Service Error: #{e.message}"
    nil
  end

  private

  def make_api_request(oab_number)
    self.class.get("/#{oab_number}",
                   headers: api_headers,
                   timeout: 10)
  end

  def api_headers
    {
      'X-Api-Key' => @api_key,
      'Content-Type' => 'application/json'
    }
  end

  def process_api_response(response)
    if response.success?
      parse_lawyer_data(response.parsed_response)
    else
      log_api_error(response)
      nil
    end
  end

  def log_api_error(response)
    Rails.logger.error "OAB API Error: #{response.code} - #{response.message}"
    Rails.logger.error "Response body: #{response.body}" if Rails.env.development?
  end

  def parse_lawyer_data(data)
    return nil unless data&.dig('principal')

    principal = data['principal']
    build_lawyer_hash(principal)
  end

  def build_lawyer_hash(principal)
    {
      **extract_name_data(principal['full_name']),
      **extract_professional_data(principal),
      **extract_contact_data(principal)
    }
  end

  def extract_name_data(full_name)
    {
      full_name: capitalize_name(full_name),
      name: capitalize_name(extract_first_name(full_name)),
      last_name: capitalize_name(extract_last_name(full_name))
    }
  end

  def extract_professional_data(principal)
    {
      oab: principal['oab_id'], # Usar oab_id que retorna formato PR_54159
      profession: principal['profession'],
      gender: gender_check(principal['profession']),
      situation: principal['situation'],
      profile_picture_url: principal['profile_picture']
    }
  end

  def extract_contact_data(principal)
    {
      city: principal['city'],
      state: principal['state'],
      address: principal['address'],
      zip_code: clean_zip_code(principal['zip_code']),
      phone: clean_phone(principal['phone_number_1'])
    }
  end

  def extract_first_name(full_name)
    return nil if full_name.blank?

    full_name.split.first
  end

  def extract_last_name(full_name)
    return nil if full_name.blank?

    parts = full_name.split
    return nil if parts.length <= 1

    parts[1..].join(' ')
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

  def gender_check(profession)
    case profession
    when 'ADVOGADO' then 'male'
    when 'ADVOGADA' then 'female'
    end
  end

  def capitalize_name(name)
    return nil if name.blank?

    # Capitaliza cada palavra corretamente
    name.split.map(&:capitalize).join(' ')
  end
end
