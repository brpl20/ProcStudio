# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZapsignService, type: :service do
  let(:profile_customer) do
    double(
      'ProfileCustomer',
      full_name: 'Fulano Silva',
      last_email: 'fulano@example.com',
      last_phone: '11999999999',
      cpf: '123.456.789-00',
      id: 1
    )
  end

  let(:document) do
    double(
      'Document',
      document_name: 'Contrato de Honorário',
      file: double('File', url: 'https://example.com/contract.pdf'),
      id: 1,
      profile_customer: profile_customer
    )
  end

  let(:zapsign_service) { described_class.new }

  before do
    allow(Rails.application.credentials).to receive(:zapsign).and_return(
      base_url: 'https://sandbox.api.zapsign.com.br',
      api_token: 'fake-api-token'
    )
  end

  describe '#create_document' do
    context 'quando a requisição é bem-sucedida' do
      let(:success_response) do
        {
          id: 'doc_123',
          name: 'Contrato de Honorário',
          status: 'pending'
        }.to_json
      end

      before do
        # Mock da requisição POST para a API do Zapsign
        stub_request(:post, 'https://sandbox.api.zapsign.com.br/api/v1/docs/')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer fake-api-token', # Ensure this matches the actual request
              'Content-Type' => 'application/json'
            },
            body: {
              name: 'Contrato de Honorário',
              url_pdf: 'https://example.com/contract.pdf',
              external_id: 1,
              signers: [
                {
                  name: 'Fulano Silva',
                  email: 'fulano@example.com',
                  auth_mode: 'assinaturaTela',
                  send_automatic_email: true,
                  phone_country: '55',
                  phone_number: '11999999999',
                  lock_email: false,
                  blank_email: false,
                  hide_email: false,
                  lock_phone: false,
                  blank_phone: false,
                  hide_phone: false,
                  lock_name: false,
                  require_cpf: false,
                  cpf: '123.456.789-00',
                  require_selfie_photo: true,
                  require_document_photo: true,
                  selfie_validation_type: 'liveness-document-match',
                  selfie_photo_url: nil,
                  document_photo_url: nil,
                  document_verse_photo_url: nil,
                  qualification: nil,
                  external_id: 1,
                  redirect_link: nil
                }
              ],
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
            }.to_json
          )
          .to_return(status: 200, body: success_response, headers: {})
      end

      it 'cria um documento no Zapsign e retorna a resposta' do
        response = zapsign_service.create_document(document)
        expect(response).to eq(success_response)
      end
    end

    context 'quando a requisição falha' do
      before do
        # Mock de uma requisição falha
        stub_request(:post, 'https://sandbox.api.zapsign.com.br/api/v1/docs/')
          .to_return(status: 500, body: 'Internal Server Error', headers: {})
      end

      it 'lança uma exceção com o erro' do
        expect { zapsign_service.create_document(document) }.to raise_error(
          'Erro na requisição: 500 - Internal Server Error'
        )
      end
    end
  end
end
