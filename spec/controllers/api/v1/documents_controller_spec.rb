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
      context 'when the file is a DOCX' do
        let(:file) { fixture_file_upload('test_document.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

        it 'purges the old document and attaches the new one' do
          expect(document.original).to receive(:purge)
          expect(document.original).to receive(:attach).with(hash_including(:io, :filename, :content_type))

          put "/api/v1/works/#{work.id}/documents/#{document.id}",
              params: {
                file: file
              },
              headers: {
                Authorization: "Bearer #{admin.jwt_token}",
                Accept: 'application/json'
              }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['message']).to eq('Documento atualizado com sucesso!')
        end
      end

      context 'when the file is a PDF and is_signed_pdf is true' do
        let(:file) { fixture_file_upload('test_document.pdf', 'application/pdf') }

        it 'attaches the new one, and updates status' do
          expect(document.signed).to receive(:attach).with(hash_including(:io, :filename, :content_type))

          put "/api/v1/works/#{work.id}/documents/#{document.id}",
              params: {
                file: file,
                is_signed_pdf: 'true'
              },
              headers: {
                Authorization: "Bearer #{admin.jwt_token}",
                Accept: 'application/json'
              }

          expect(response).to have_http_status(:ok)
          expect(document.reload.status).to eq('signed')
          expect(document.reload.sign_source).to eq('manual_signature')
          expect(response.parsed_body['message']).to eq('Documento assinado atualizado com sucesso!')
        end
      end

      context 'when the file is not a DOCX' do
        let(:file) { fixture_file_upload('test_document.pdf', 'application/pdf') }

        it 'returns an unprocessable entity status with error message' do
          put "/api/v1/works/#{work.id}/documents/#{document.id}",
              params: {
                file: file
              },
              headers: {
                Authorization: "Bearer #{admin.jwt_token}",
                Accept: 'application/json'
              }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['error']).to eq('O arquivo deve ser um DOCX')
        end
      end

      context 'when the file is not a PDF and is_signed_pdf is true' do
        let(:file) { fixture_file_upload('test_document.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

        it 'returns an unprocessable entity status with error message' do
          put "/api/v1/works/#{work.id}/documents/#{document.id}",
              params: {
                file: file,
                is_signed_pdf: 'true'
              },
              headers: {
                Authorization: "Bearer #{admin.jwt_token}",
                Accept: 'application/json'
              }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body['error']).to eq('O arquivo deve ser um PDF')
        end
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
        expect(response.parsed_body['error']).to eq('Arquivo não fornecido')
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
        expect(response.parsed_body['error']).to eq('Documento não encontrado')
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
