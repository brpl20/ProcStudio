# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DocumentsController, type: :request do
  let!(:admin) { create(:profile_admin).admin }
  let(:work) { create(:work) }
  let(:document) { create(:document, work: work) }

  describe 'PUT #update' do
    before do
      allow(Work).to receive(:find).and_return(work)
      allow(work.documents).to receive(:find).and_return(document)
    end

    context 'when the file is provided' do
      let(:file) { fixture_file_upload('test_document.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

      it 'purges the old document and attaches the new one' do
        expect(document.file).to receive(:purge_later)
        expect(document.file).to receive(:attach).with(hash_including(:io, :filename, :content_type))

        put "/api/v1/works/#{work.id}/documents/#{document.id}",
            params: {
              file: file
            },
            headers: {
              Authorization: "Bearer #{admin.jwt_token}",
              Accept: 'application/json'
            }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Documento atualizado com sucesso!')
      end
    end

    context 'when the file is not provided' do
      it 'returns an unprocessable entity status with error message' do
        put "/api/v1/works/#{work.id}/documents/#{document.id}",
            params: {},
            headers: {
              Authorization: "Bearer #{admin.jwt_token}",
              Accept: 'application/json'
            }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Arquivo não fornecido')
      end
    end

    context 'when the document is not found' do
      before do
        allow(work.documents).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'returns a not found status' do
        put "/api/v1/works/#{work.id}/documents/999",
            params: {
              file: fixture_file_upload('test_document.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
            },
            headers: {
              Authorization: "Bearer #{admin.jwt_token}",
              Accept: 'application/json'
            }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Documento não encontrado')
      end
    end

    context 'when request is made without token' do
      it 'returns :unauthorized' do
        put "/api/v1/works/#{work.id}/documents/#{document.id}", params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
