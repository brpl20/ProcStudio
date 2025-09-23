# frozen_string_literal: true

require 'docx'

module Works
  class DocumentDeficiencyStatementService < ApplicationService
    include Works::Base

    def initialize(document_id)
      @document = Document.find(document_id)
      @work     = document.work
      @customer = document.profile_customer
      @address  = customer.addresses.first
    end

    def call
      doc.paragraphs.each do |paragraph|
        paragraph.each_text_run do |text|
          substitute_word(text)
        end
      end
      doc.save(file_path)

      save
    end

    private

    attr_reader :document, :work, :customer, :address

    def save
      content_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      
      # Generate S3 key following the pattern
      s3_key = document.build_work_document_s3_key(document.document_type, 'docx')
      
      # Upload to S3
      file = File.open(file_path)
      begin
        if S3Service.upload(file, s3_key, { content_type: content_type })
          Rails.logger.info "Document uploaded to S3: #{s3_key}"
          # Update the document record with S3 key if needed
          document.update_column(:original_s3_key, s3_key) if document.respond_to?(:original_s3_key)
          true
        else
          Rails.logger.error "Failed to upload document to S3"
          false
        end
      rescue StandardError => e
        Rails.logger.error("[Document Error]: #{e.message}")
        false
      ensure
        file.close if file && !file.closed?
        FileUtils.remove_file(file_path, true)
      end
    end

    def doc
      @doc ||= Docx::Document.open('app/template_documents/carencia.docx')
    end

    def file_path
      @file_path ||= "tmp/#{file_name}"
    end

    def file_name
      @file_name ||= "carencia_#{work.id}_#{customer.id}.docx"
    end

    def substitute_word(text)
      proc_date = I18n.l(Time.zone.now, format: '%d de %B de %Y')
      substitute_client_info(text)

      text.substitute('_proc_today_', "#{address.city&.strip}, #{address.state&.strip}, #{proc_date}")
      text.substitute('_proc_full_name_', customer.full_name.upcase)
    end
  end
end
