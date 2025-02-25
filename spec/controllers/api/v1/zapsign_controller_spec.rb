require 'rails_helper'

RSpec.describe Api::V1::ZapsignController, type: :request do
  let!(:admin) { create(:profile_admin).admin }
  let(:work) { create(:work) }
  let!(:valid_document) { create(:document, work: work, format: 'pdf', status: 'approved') }
  let!(:invalid_document) { create(:document, work: work, format: 'docx', status: 'pending_review') }
  let(:zapsign_service) { instance_double(ZapsignService) }

  before do
    allow(ZapsignService).to receive(:new).and_return(zapsign_service)
  end

  xdescribe 'POST #create' do
    context 'com documentos válidos' do
      before do
        allow(zapsign_service).to receive(:create_document).and_return({ id: 'doc_123', status: 'pending' })
      end

      it 'atualiza o sign_source e retorna sucesso' do
        post '/api/v1/zapsign', params: { work_id: work.id }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(json_response[:success].size).to eq(1)
        expect(json_response[:errors].size).to eq(1)
      end
    end

    context 'quando ocorre um erro no ZapsignService' do
      before do
        allow(zapsign_service).to receive(:create_document).and_raise(StandardError, 'Erro na API')
      end

      it 'retorna erro e não atualiza o documento' do
        post '/api/v1/zapsign', params: { work_id: work.id }, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(json_response[:errors].size).to eq(1)
        expect(json_response[:errors].first[:error]).to eq('Erro na API')
      end
    end
  end

  describe 'POST #webhook' do
    let(:document) { create(:document) }

    context 'quando o documento é encontrado e o status é signed' do
      let(:payload) do
        {
          external_id: document.id,
          status: 'signed'
        }
      end

      it 'atualiza o status do documento para signed' do
        post '/api/v1/zapsign/webhook', params: payload.to_json, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(document.reload.status).to eq('signed')
        expect(json_response[:message]).to eq('Documento atualizado para signed.')
      end
    end

    xcontext 'quando o documento é encontrado, mas o status não é signed' do
      let(:payload) do
        {
          external_id: document.id,
          status: 'pending'
        }
      end

      it 'não atualiza o status do documento' do
        post '/api/v1/zapsign/webhook', params: payload.to_json, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(document.reload.status).not_to eq('signed')
        expect(json_response[:message]).to eq('Documento não está assinado.')
      end
    end

    context 'quando o documento não é encontrado' do
      let(:payload) do
        {
          external_id: 999999, # ID inválido
          status: 'signed'
        }
      end

      it 'retorna erro de documento não encontrado' do
        post '/api/v1/zapsign/webhook', params: payload.to_json, headers: { Authorization: "Bearer #{admin.jwt_token}", Accept: 'application/json' }

        expect(response).to have_http_status(:not_found)
        expect(json_response[:error]).to eq('Documento não encontrado.')
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end
