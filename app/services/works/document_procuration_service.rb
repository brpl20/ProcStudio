# frozen_string_literal: true

require 'docx'

module Works
  class DocumentProcurationService < ApplicationService
    def initialize(document_id)
      @document = Document.find(document_id)
      @work = @document.work
      @customer = @work.profile_customers.first
      @address = @customer.addresses.first
      @customer_email = @customer.emails.first
      @office = @work.offices.first
      @gender = @customer.gender
    end

    def call
      doc = Docx::Document.open('app/template_documents/procuracao.docx')
      doc.paragraphs.each do |paragraph|
        paragraph.each_text_run do |text|
          substitute_word(text)
        end
      end
      doc.save("tmp/procuracao_#{@work.id}.docx")
      @document.document_docx.attach(io: File.open("tmp/procuracao_#{@work.id}.docx"), filename: "procuracao_#{@work.id}.docx")
      # FileUtils.remove_file("tmp/procuracao_#{@work.id}.docx", true)
    end

    private

    def substitute_address(text)
      return if @address.nil?

      text.substitute('_proc_street_', @address.street.to_s.downcase.titleize)
      text.substitute('_proc_number_', @address.number.to_s)
      text.substitute('_proc_description_', @address.description.to_s.downcase.titleize)
      text.substitute('_proc_city_', @address.city)
      text.substitute('_proc_state_', @address.state)
    end

    def substitute_office(text)
      return if @office.nil?

      text.substitute('_proc_office_street_', @office.street.to_s.downcase.titleize)
      text.substitute('_proc_office_number_', @office.number.to_s)
      text.substitute('_proc_office_neighborhood_', @office.neighborhood.downcase.titleize)
      text.substitute('_proc_office_state_', "#{@office.city}-#{@office.state}")
      text.substitute('_proc_oab_', @office.oab)
      text.substitute('_proc_office_site_', @office.site.downcase)
    end

    def substitute_outorgante(text)
      translated_text = [@customer.full_name.downcase.titleize, word_for_gender(@customer.nationality, @customer.gender),
                         word_for_gender(@customer.civil_status, @customer.gender), ProfileCustomer.human_enum_name(:capacity, @customer.capacity).downcase,
                         @customer.profession.downcase,
                         "#{word_for_gender('owner', @customer.gender)} do RG n° #{@customer.rg} e #{word_for_gender('subscribe', @customer.gender)} no CPF sob o n° #{@customer.cpf}",
                         @customer.last_email, "residente e #{word_for_gender('live', @customer.gender)}: #{@address.street.to_s.downcase.titleize}, n° #{@address.number}",
                         @address.description.to_s.downcase.titleize, "#{@address.city} - #{@address.state}, CEP #{@address.zip_code} #{responsable}"].join(', ')

      text.substitute('_proc_outorgante_', translated_text)
    end

    # translate word using gender
    def word_for_gender(text, gender)
      I18n.t("gender.#{text}.#{gender}")
    end

    def responsable
      return nil unless @customer.unable? && @customer.represent.present?

      represent = ProfileCustomer.find(@customer.represent.represented_id)
      represent_address = represent.addresses.first
      [",#{word_for_gender('represent', represent.gender)} #{represent.full_name.downcase.titleize}", word_for_gender(represent.civil_status, represent.gender),
       "#{word_for_gender('owner', represent.gender)} do RG n° #{represent.rg} e #{word_for_gender('subscribe', represent.gender)} no CPF sob o n° #{represent.cpf}",
       represent.last_email, "residente e #{word_for_gender('live', represent.gender)}: #{represent_address.street.to_s.downcase.titleize}, n° #{represent_address.number}",
       represent_address.description.to_s.downcase.titleize,
       "#{represent_address.city} - #{represent_address.state}, CEP #{represent_address.zip_code}"].join(', ')
    end

    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      substitute_outorgante(text)
      substitute_address(text)
      substitute_office(text)

      text.substitute('_proc_today_', "#{@address.city}, #{@address.state}, #{proc_date}")
      text.substitute('_proc_date_', proc_date)
      text.substitute('_proc_full_name_', @customer.full_name.downcase.titleize)
    end
  end
end
