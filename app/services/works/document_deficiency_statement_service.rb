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
      doc.save(filename)

      save
    end

    private

    attr_reader :document, :work, :customer, :address

    def save
      document.document_docx.attach(blob)
      FileUtils.remove_file(filename, true)
    rescue StandardError => e
      Rails.logger.error("[Document Error]: #{e.message}")
      false
    end

    def doc
      @doc ||= Docx::Document.open('app/template_documents/carencia.docx')
    end

    def filename
      @filename ||= "tmp/carencia_#{work.id}_#{customer.id}.docx"
    end

    def blob
      @blob ||=
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(filename),
          filename: "carencia_#{work.id}_#{customer.id}.docx",
          service_name: service_name
        )
    end

    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      substitute_client_info(text)

      text.substitute('_proc_today_', "#{address.city&.strip}, #{address.state&.strip}, #{proc_date}")
      text.substitute('_proc_full_name_', customer.full_name.upcase)
    end
  end
end
