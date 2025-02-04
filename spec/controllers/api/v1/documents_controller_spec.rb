# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DocumentsController, type: :controller do
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
        expect(document.document_docx).to receive(:purge_later)
        expect(document.document_docx).to receive(:attach).with(file)

        put :update, params: { work_id: work.id, id: document.id, file: file }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Documento atualizado com sucesso!')
      end
    end

    context 'when the file is not provided' do
      it 'returns an unprocessable entity status with error message' do
        put :update, params: { work_id: work.id, id: document.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Arquivo não fornecido')
      end
    end

    context 'when the document is not found' do
      before do
        allow(work.documents).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'returns a not found status' do
        put :update, params: { work_id: work.id, id: 999, file: fixture_file_upload('test_document.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Documento não encontrado')
      end
    end
  end
end
