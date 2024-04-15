# frozen_string_literal: true

require 'docx'

module Works
  class DocumentProcurationService < ApplicationService
    include Works::Base

    def initialize(document_id)
      @document = Document.find(document_id)
      @work     = document.work
      @office   = work.offices.first
      @lawyers  = work.profile_admins.lawyer
      @customer = document.profile_customer
      @address  = customer.addresses.first
      @lawyer_address = lawyers.first.addresses.first
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

    attr_reader :document, :work, :office, :lawyers, :lawyer_address, :customer, :address

    def save
      document.document_docx.attach(blob)
      FileUtils.remove_file(filename, true)
    rescue StandardError => e
      Rails.logger.error("[Document Error]: #{e.message}")
      false
    end

    def doc
      @doc ||= Docx::Document.open('app/template_documents/procuracao.docx')
    end

    def filename
      @filename ||= "tmp/procuracao_#{work.id}_#{customer.id}.docx"
    end

    def blob
      @blob ||=
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(filename),
          filename: "procuracao_#{work.id}_#{customer.id}.docx",
          service_name: service_name
        )
    end

    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      substitute_client_info(text)
      substitute_justice_agents(text)
      substitute_job(text)

      text.substitute('_proc_today_', "#{address.city&.strip}, #{address.state&.strip}, #{proc_date}")
      text.substitute('_proc_date_', proc_date)
      text.substitute('_proc_full_name_', customer.full_name.downcase.titleize&.strip)
    end
  end
end
