require 'httparty'

class ZapsignService
  include HTTParty

  base_uri 'https://sandbox.api.zapsign.com.br'
  headers 'Content-Type' => 'application/json'
  headers 'Accept' => 'application/json'

  def initialize(api_token)
    @api_token = api_token
  end

  def create_document(document_data)
    unless document_data[:signers]&.any?
      raise ArgumentError, "Pelo menos um signatário é necessário."
    end

    self.class.headers 'Authorization' => "Bearer #{@api_token}"

    response = self.class.post('/api/v1/docs/', body: document_data.to_json)

    handle_response(response)
  end

  private

  def handle_response(response)
    case response.code
    when 200..299
      response.parsed_response
    else
      raise "Erro na requisição: #{response.code} - #{response.body}"
    end
  end
end
