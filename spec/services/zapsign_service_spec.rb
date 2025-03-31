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
      id: 1,
      profile_customer: profile_customer,
      original: double('ActiveStorage::Attached::One', url: 'https://example.com/contract.pdf'),
      signed: double('ActiveStorage::Attached::One', attach: true),
      update!: true
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
        stub_request(:post, 'https://sandbox.api.zapsign.com.br/api/v1/docs/')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer fake-api-token',
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
                  require_selfie_photo: false,
                  require_document_photo: false,
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

  describe '#receive_signed_doc' do
    context 'quando o documento está assinado' do
      let(:signed_payload) do
        {
          status: 'signed',
          signed_file: 'https://zapsign.s3.amazonaws.com/sandbox/dev/2025/3/pdf/b406bdb0-e01e-4582-910c-b07462a822f3/16111735-da4d-4b5e-a082-5ac370a8df3d.pdf?AWSAccessKeyId=AKIASUFZJ7JCTI2ZRGWX&Signature=ZEpHcHqIEGPZgIQPcF64KJa7cBE%3D&Expires=1741787529'
        }
      end

      before do
        allow(zapsign_service).to receive(:save_signed_file).and_return(true)
        allow(zapsign_service).to receive(:update_document_to_signed).and_return(true)
      end

      it 'atualiza o documento para assinado e salva o arquivo assinado' do
        result = zapsign_service.receive_signed_doc(document, signed_payload)
        expect(result).to eq({ message: 'Documento atualizado para signed.' })
        expect(zapsign_service).to have_received(:update_document_to_signed).with(document)
        expect(zapsign_service).to have_received(:save_signed_file).with(document, signed_payload[:signed_file])
      end
    end

    context 'quando o documento não está assinado' do
      let(:unsigned_payload) do
        {
          status: 'pending',
          signed_file: nil
        }
      end

      it 'retorna uma mensagem indicando que o documento não está assinado' do
        result = zapsign_service.receive_signed_doc(document, unsigned_payload)
        expect(result).to eq({ message: 'Documento não está assinado.' })
      end
    end
  end

  describe '#save_signed_file' do
    let(:s3_document) do
      'https://zapsign.s3.amazonaws.com/sandbox/dev/2025/3/pdf/b406bdb0-e01e-4582-910c-b07462a822f3/16111735-da4d-4b5e-a082-5ac370a8df3d.pdf?AWSAccessKeyId=AKIASUFZJ7JCTI2ZRGWX&Signature=ZEpHcHqIEGPZgIQPcF64KJa7cBE%3D&Expires=1741787529'
    end

    before do
      allow(Down).to receive(:download).with(s3_document).and_return(StringIO.new('fake-pdf-content'))
    end

    it 'anexa o arquivo assinado ao documento' do
      expect(document.signed).to receive(:attach).with(
        io: an_instance_of(StringIO),
        filename: 'test/16111735-da4d-4b5e-a082-5ac370a8df3d.pdf',
        content_type: 'application/pdf'
      )
      zapsign_service.send(:save_signed_file, document, s3_document)
    end
  end

  describe '#update_document_to_signed' do
    it 'atualiza o status do documento para assinado' do
      expect(document).to receive(:update!).with(status: :signed, sign_source: :zapsign)
      zapsign_service.send(:update_document_to_signed, document)
    end
  end
end
