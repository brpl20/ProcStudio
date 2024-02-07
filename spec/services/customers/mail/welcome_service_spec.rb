require 'rails_helper'

RSpec.describe Customers::Mail::WelcomeService do
  let(:customer) { double('Customer', profile_customer_full_name: 'Test User', email: 'customer@email.com') }
  let(:service) { described_class.new(customer) }
  let(:mailjet_service) { double('Mailjet::Send') }

  before do
    allow(service).to receive(:mailjet_service).and_return(mailjet_service)
    allow(service).to receive(:sandbox_mode?).and_return(true)
    allow(mailjet_service).to receive(:create)
  end

  describe '#call' do
    it 'sends a welcome email' do
      service.call
      expect(mailjet_service).to have_received(:create).with(
        messages: [
          {
            From: { Email: 'contato@brunopellizzetti.com.br', Name: 'Procstudio' },
            To: [{ Email: 'customer@email.com', Name: 'Test User' }],
            TemplateID: 5_667_725,
            TemplateLanguage: true,
            Subject: 'Boas-vindas ao Procstudio Test User - Seu Parceiro em Gestão de Processos',
            Variables: { customer_full_name: 'Test User' }
          }
        ],
        sandbox_mode: true
      )
    end

    context 'when an error occurs' do
      let(:response) { double('response', code: 400, body: 'Bad request') }

      before do
        allow(mailjet_service).to receive(:create).and_raise(RestClient::BadRequest.new(response))
      end

      it 'logs an error message' do
        expect(Rails.logger).to receive(:error).with('[Mailjet Delivery Error]: 400 Bad Request')
        service.call
      end
    end
  end
end
