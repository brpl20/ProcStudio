# frozen_string_literal: true

require 'httparty'
require 'down'

class ZapsignService
  include HTTParty
  base_uri CredentialsHelper.get(:zapsign, :base_url, 'ZAPSIGN_BASE_URL')
  # TODO: Remover
  # base_uri Rails.application.credentials.dig(Rails.env.to_sym, :zapsign, :base_url) || 'https://sandbox.api.zapsign.com.br/api'
  headers 'Content-Type' => 'application/json'
  headers 'Accept' => 'application/json'

  def initialize
    # TODO: Remover
    # @api_token = Rails.application.credentials.dig(:zapsign, :api_token)
    @api_token = CredentialsHelper.get(:zapsign, :api_token, 'ZAPSIGN_API_TOKEN')

    # TODO: Remover
    # @api_token = 'fake-api-token' if Rails.env.test?
  end

  def create_document(document)
    payload = build_payload(document)
    self.class.headers 'Authorization' => "Bearer #{@api_token}"

    response = self.class.post('/v1/docs/', body: payload.to_json)

    handle_response(response)
  end

  def receive_signed_doc(document, payload)
    return { message: 'Documento não está assinado.' } unless payload[:status] == 'signed'

    update_document_to_signed(document)
    save_signed_file(document, payload[:signed_file])

    { message: 'Documento atualizado para signed.' }
  end

  private

  def build_payload(document)
    {
      name: document.document_name,
      url_pdf: document.original.url,
      external_id: document.id,
      signers: signer(document.profile_customer),
      lang: 'pt-br',
      disable_signer_emails: false,
      brand_name: '',
      folder_path: '/',
      created_by: '',
      date_limit_to_sign: nil,
      signature_order_active: false,
      observers: [],
      reminder_every_n_days: 0,
      allow_refuse_signature: false,
      disable_signers_get_original_file: false
    }
  end

  def handle_response(response)
    case response.code
    when 200..299
      response.parsed_response
    else
      raise "Erro na requisição: #{response.code} - #{response.body}"
    end
  end

  def signer(profile_customer)
    [
      {
        name: profile_customer.full_name,
        email: profile_customer.last_email,
        auth_mode: 'assinaturaTela',
        send_automatic_email: true,
        phone_country: '55',
        phone_number: profile_customer.last_phone,
        lock_email: false,
        blank_email: false,
        hide_email: false,
        lock_phone: false,
        blank_phone: false,
        hide_phone: false,
        lock_name: false,
        require_cpf: false,
        cpf: profile_customer.cpf,
        require_selfie_photo: false,
        require_document_photo: false,
        selfie_photo_url: nil,
        document_photo_url: nil,
        document_verse_photo_url: nil,
        qualification: nil,
        external_id: profile_customer.id,
        redirect_link: nil
      }
    ]
  end

  def save_signed_file(document, s3_document)
    downloaded_file = Down.download(s3_document)
    filename = File.basename(URI.parse(s3_document).path)

    S3UploadManager.upload_file(downloaded_file, document, :signed, filename, 'application/pdf')
  ensure
    downloaded_file&.close
  end

  def update_document_to_signed(document)
    document.update!(status: :signed, sign_source: :zapsign)
  end
end
