# frozen_string_literal: true

require 'docx'

module Works
  class DocumentWaiverService < ApplicationService
    include Works::Base

    def initialize(document_id)
      @document = Document.find(document_id)
      @customer = document.profile_customer
      @address  = customer.addresses.first
      @work     = document.work
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
      document.original.attach(blob)
      FileUtils.remove_file(filename, true)
    rescue StandardError => e
      Rails.logger.error("[Document Error]: #{e.message}")
      false
    end

    def doc
      @doc ||=
        if customer.able?
          Docx::Document.open('app/template_documents/renuncia.docx')
        elsif customer.unable?
          Docx::Document.open('app/template_documents/renuncia_incapaz.docx')
        else
          Docx::Document.open('app/template_documents/renuncia_parcialmente_incapaz.docx')
        end
    end

    def representor
      customer&.represent&.representor
    end

    def filename
      @filename ||= "tmp/renuncia_#{work.id}_#{customer.id}.docx"
    end

    def blob
      @blob ||=
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(filename),
          filename: "renuncia_#{work.id}_#{customer.id}.docx",
          service_name: service_name
        )
    end

    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      substitute_client_info(text)

      text.substitute('_proc_today_', "#{address.city&.strip}, #{address.state&.strip}, #{proc_date}")
      text.substitute('_proc_full_name_', customer.full_name.upcase)
      text.substitute('_proc_represent_full_name_', representor&.full_name&.upcase) if representor&.present?
    end
  end
end
