# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Works::DocxToPdfConverterService, type: :service do
  let(:document) { create(:document) }
  let(:service) { described_class.new(document) }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test_document.docx') }
  let(:pdf_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'test_document.pdf') }

  describe '#call' do
    context 'when the document has a file attached' do
      before do
        allow(document.file).to receive(:attached?).and_return(true)
        allow(document.file).to receive(:download).and_return(file_path)
        allow(document).to receive(:file).and_return(document.file)
      end

      it 'downloads the file successfully' do
        allow(service).to receive(:download_file).and_return(file_path.to_s)

        expect(service).to receive(:download_file)

        service.call
      end

      it 'converts the docx file to pdf' do
        allow(service).to receive(:download_file).and_return(file_path.to_s)
        allow(service).to receive(:convert_to_pdf).and_return('/tmp/file.pdf')

        doc_mock = double('Docx::Document')
        allow(Docx::Document).to receive(:open).with(file_path.to_s).and_return(doc_mock)

        allow(doc_mock).to receive(:close)

        expect(service).to receive(:convert_to_pdf).with(file_path.to_s)

        service.call
      end

      it 'attaches the converted pdf to the document' do
        allow(service).to receive(:download_file).and_return(file_path.to_s)
        allow(service).to receive(:convert_to_pdf).and_return('/tmp/file.pdf')
        allow(service).to receive(:attach_pdf)

        doc_mock = double('Docx::Document')
        allow(Docx::Document).to receive(:open).with(file_path.to_s).and_return(doc_mock)

        allow(doc_mock).to receive(:close)

        expect(service).to receive(:attach_pdf).with('/tmp/file.pdf')

        service.call
      end

      it 'marks the document as PDF and finished' do
        allow(service).to receive(:download_file).and_return(file_path.to_s)
        allow(service).to receive(:convert_to_pdf).and_return('/tmp/file.pdf')
        allow(service).to receive(:attach_pdf)

        doc_mock = double('Docx::Document')
        allow(Docx::Document).to receive(:open).with(file_path.to_s).and_return(doc_mock)

        allow(doc_mock).to receive(:close)

        expect(document).to receive(:mark_as_pdf_and_finished)

        service.call
      end

      it 'does not clean up temporary files (prevents deletion of files)' do
        allow(service).to receive(:download_file).and_return(file_path.to_s)
        allow(service).to receive(:convert_to_pdf).and_return('/tmp/file.pdf')
        allow(service).to receive(:attach_pdf)

        doc_mock = double('Docx::Document')
        allow(Docx::Document).to receive(:open).with(file_path.to_s).and_return(doc_mock)

        allow(doc_mock).to receive(:close)

        allow(service).to receive(:cleanup_temp_files)

        service.call

        expect(File.exist?(file_path)).to be true
      end
    end

    context 'when the document does not have a file attached' do
      before do
        allow(document.file).to receive(:attached?).and_return(false)
      end

      it 'does not perform any actions' do
        expect(service).not_to receive(:download_file)
        expect(service).not_to receive(:convert_to_pdf)
        expect(service).not_to receive(:attach_pdf)
        expect(service).not_to receive(:cleanup_temp_files)

        service.call
      end
    end

    context 'when the file is not a .docx file' do
      before do
        allow(document.file.blob).to receive(:content_type).and_return('application/pdf')
        allow(document.file).to receive(:attached?).and_return(true)
      end

      it 'does not convert the file' do
        expect(service).not_to receive(:download_file)
        expect(service).not_to receive(:convert_to_pdf)
        expect(service).not_to receive(:attach_pdf)
        expect(service).not_to receive(:cleanup_temp_files)

        service.call
      end
    end
  end

  after do
    File.delete(pdf_file_path) if File.exist?(pdf_file_path)
  end
end
