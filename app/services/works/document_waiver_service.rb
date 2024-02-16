# frozen_string_literal: true

require 'docx'

module Works
  class DocumentWaiverService < ApplicationService
    def initialize(document_id)
      @document = Document.find(document_id)
      @work = @document.work
      @customer = @work.profile_customers.first
      @address = @customer.addresses.first
    end

    def call
      doc = Docx::Document.open('app/template_documents/renuncia.docx')
      doc.paragraphs.each do |paragraph|
        paragraph.each_text_run do |text|
          substitute_word(text)
        end
      end
      doc.save("tmp/renuncia_#{@work.id}.docx")

      @document.document_docx.attach(ActiveStorage::Blob.create_and_upload!(io: File.open("tmp/renuncia_#{@work.id}.docx"), filename: "renuncia_#{@work.id}.docx", service_name: service_name))
      FileUtils.remove_file("tmp/renuncia_#{@work.id}.docx", true)
    end

    private

    def service_name
      return :local if Rails.env.development?
      return :test  if Rails.env.test?

      :amazon
    end

    def substitute_client_info(text)
      translated_text = [
        @customer.full_name.downcase.titleize,
        word_for_gender(@customer.nationality, @customer.gender),
        word_for_gender(@customer.civil_status, @customer.gender),
        ProfileCustomer.human_enum_name(:capacity, @customer.capacity).downcase,
        @customer.profession.downcase,
        "#{word_for_gender('owner', @customer.gender)} do RG n° #{@customer.rg} e #{word_for_gender('subscribe', @customer.gender)} no CPF sob o n° #{@customer.cpf}",
        @customer.last_email, "residente e #{word_for_gender('live', @customer.gender)}: #{@address.street.to_s.downcase.titleize}, n° #{@address.number}",
        @address.description.to_s.downcase.titleize, "#{@address.city} - #{@address.state}, CEP #{@address.zip_code} #{responsable}"
      ].join(', ')

      text.substitute('_renuncia_qualify_', translated_text)
    end

    def word_for_gender(text, gender)
      I18n.t("gender.#{text}.#{gender}")
    end

    def responsable
      return nil unless @customer.unable? && @customer&.represent&.representor&.present?

      represent = @customer.represent.profile_admin
      represent_address = represent.addresses.first
      [
        ", #{word_for_gender('represent', represent.gender)} #{represent.full_name.downcase.titleize}",
        word_for_gender(represent.civil_status, represent.gender),
        "#{word_for_gender('owner', represent.gender)} do RG n° #{represent.rg} e #{word_for_gender('subscribe', represent.gender)} no CPF sob o n° #{represent.cpf}",
        represent.last_email,
        "residente e #{word_for_gender('live', represent.gender)}: #{represent_address.street.to_s.downcase.titleize}, n° #{represent_address.number}",
        represent_address.description.to_s.downcase.titleize,
        "#{represent_address.city} - #{represent_address.state}, CEP #{represent_address.zip_code}"
      ].join(', ')
    end

    # main function
    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      substitute_client_info(text)

      text.substitute('_renuncia_today_', "#{@address.city}, #{@address.state}, #{proc_date}")
      text.substitute('_renuncia_full_name_', @customer.full_name.downcase.titleize)
    end
  end
end
