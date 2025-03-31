# frozen_string_literal: true

require 'docx'
require 'libreconv'

module Works
  class DocxToPdfConverterService < ApplicationService
    def initialize(document)
      @document = document
    end

    def call
      return unless @document.original.attached? && docx_file?

      file_path = download_file
      pdf_path = convert_to_pdf(file_path)

      attach_pdf(pdf_path)
    ensure
      @document.mark_as_pdf_and_approved

      cleanup_temp_files(file_path, pdf_path) unless Rails.env.test?
    end

    private

    def docx_file?
      @document.original.blob.content_type == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    end

    def download_file
      file_path = Rails.root.join('tmp', @document.original.filename.to_s) # Define o caminho onde o arquivo será salvo

      file_content = @document.original.download
      File.binwrite(file_path, file_content)

      file_path
    end

    def convert_to_pdf(file_path)
      output_path = file_path.to_s.gsub('.docx', '.pdf')
      Libreconv.convert(file_path, output_path)

      output_path
    end

    def attach_pdf(pdf_path)
      pdf_file = File.open(pdf_path)
      file_name = @document.document_name_parsed
      S3UploadManager.upload_file(pdf_file, @document, :original, file_name, 'application/pdf')

      pdf_file.close
    end

    def cleanup_temp_files(*paths)
      paths.each { |path| File.delete(path) if path && File.exist?(path) }
    end
  end
end
