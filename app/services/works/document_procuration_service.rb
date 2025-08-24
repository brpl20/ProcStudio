# frozen_string_literal: true

require 'docx'

module Works
  class DocumentProcurationService < ApplicationService
    include Works::Base

    def initialize(document_id)
      @document = Document.find(document_id)
      @work = document.work
      @office = work.offices&.first
      @lawyers = work.profile_admins&.lawyer
      @customer = document.profile_customer
      @address = customer&.addresses&.first
      lawyer = lawyers&.first
      @lawyer_address = lawyer&.addresses&.first
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

    attr_reader :document, :work, :office, :lawyers, :lawyer_address, :customer, :address

    def save
      file = File.open(file_path)
      content_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'

      S3UploadManager.upload_file(file, document, :original, file_name, content_type)
      FileUtils.remove_file(file_path, true)
    rescue StandardError => e
      Rails.logger.error("[Document Error]: #{e.message}")
      false
    end

    def representor
      customer&.represent&.representor
    end

    def doc
      @doc ||=
        if customer.able?
          Docx::Document.open('app/template_documents/procuracao.docx')
        elsif customer.unable?
          Docx::Document.open('app/template_documents/procuracao_incapaz.docx')
        else
          Docx::Document.open('app/template_documents/procuracao_parcialmente_incapaz.docx')
        end
    end

    def file_path
      @file_path ||= "tmp/#{file_name}"
    end

    def file_name
      @file_name ||= "procuracao_#{work.id}_#{customer.id}.docx"
    end

    def substitute_powers(text)
      text.substitute('_proc_powers_', work.powers.map { _1.description.downcase }.join(', '))
    end

    def substitute_word(text)
      proc_date = I18n.l(Time.zone.now, format: '%d de %B de %Y')
      substitute_client_info(text)
      substitute_justice_agents(text)
      substitute_job(text)
      substitute_powers(text)

      text.substitute('_proc_today_', "#{address.city&.strip}, #{address.state&.strip}, #{proc_date}")
      text.substitute('_proc_date_', proc_date)
      text.substitute('_proc_full_name_', customer.full_name.upcase)
      text.substitute('_proc_represent_full_name_', representor&.full_name&.upcase) if representor.present?
    end
  end
end
