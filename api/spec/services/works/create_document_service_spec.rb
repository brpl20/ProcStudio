# frozen_string_literal: true

describe Works::CreateDocumentService do
  describe '.call' do
    let!(:work_one) { create(:work) }
    let!(:work_two) { create(:work) }
    let!(:document) { create(:document, work: work_one, document_type: 'procuration') }

    before do
      allow(Works::DocumentProcurationService).to receive(:call)
    end

    context 'when work have documents' do
      it 'call create a document service' do
        described_class.call(work_one)
        expect(Works::DocumentProcurationService).to have_received(:call).with(document.id)
      end
    end

    context 'when work do not have documents' do
      it 'do not calls create a document service' do
        described_class.call(work_two)
        expect(Works::DocumentProcurationService).not_to have_received(:call).with(document.id)
      end
    end
  end
end
