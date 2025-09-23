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
      
      # Generate S3 key for PDF
      s3_key = @document.build_work_document_s3_key(@document.document_type, 'pdf')
      
      # Upload to S3
      if S3Service.upload(pdf_file, s3_key, { content_type: 'application/pdf' })
        Rails.logger.info "PDF uploaded to S3: #{s3_key}"
        @document.update_column(:original_s3_key, s3_key) if @document.respond_to?(:original_s3_key)
      else
        Rails.logger.error "Failed to upload PDF to S3"
      end

      pdf_file.close
    end

    def cleanup_temp_files(*paths)
      paths.each { |path| File.delete(path) if path && File.exist?(path) }
    end
  end
end
