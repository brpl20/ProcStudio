# frozen_string_literal: true

require 'docx'

module Works
  class DocumentProcurationService < ApplicationService
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
      doc = Docx::Document.open('app/template_documents/procuracao.docx')
      doc.paragraphs.each do |paragraph|
        paragraph.each_text_run do |text|
          substitute_word(text)
        end
      end
      filename = "tmp/procuracao_#{work.id}_#{customer.id}.docx"
      doc.save(filename)
      document.document_docx.attach(ActiveStorage::Blob.create_and_upload!(io: File.open(filename), filename: "procuracao_#{work.id}_#{customer.id}.docx", service_name: service_name))
      FileUtils.remove_file(filename, true)
    end

    private

    attr_reader :document, :work, :office, :lawyers, :lawyer_address, :customer, :address

    def service_name
      return :local if Rails.env.development?
      return :test  if Rails.env.test?

      :amazon
    end

    # outorgante paragraph
    def substitute_client_info(text)
      translated_text = [
        customer.full_name.downcase.titleize,
        word_for_gender(customer.nationality, customer.gender),
        word_for_gender(customer.civil_status, customer.gender),
        ProfileCustomer.human_enum_name(:capacity, customer.capacity).downcase,
        customer.profession.downcase,
        "#{word_for_gender('owner', customer.gender)} do RG n° #{customer.rg} e #{word_for_gender('subscribe', customer.gender)} no CPF sob o n° #{customer.cpf}",
        customer.last_email, "residente e #{word_for_gender('live', customer.gender)}: #{address.street.to_s.downcase.titleize}, n° #{address.number}",
        address.description.to_s.downcase.titleize, "#{address.city} - #{address.state}, CEP #{address.zip_code} #{responsable}"
      ].join(', ')

      text.substitute('_proc_outorgante_', translated_text)
    end

    # outorgados paragraph
    def substitute_justice_agents(text)
      translated_text = if office.present?
                          ["#{I18n.t('general.lawyers')}: #{lawyers_text}", "integrante da #{office.name} inscrita sob o cnpj #{office.cnpj}",
                           "com endereço profissional à Rua #{office.street.to_s.downcase.titleize}", office.number.to_s, office.neighborhood.downcase.titleize,
                           "#{office.city}-#{office.state}", "e endereço eletrônico #{office.site}"]
                            .join(', ')
                        else
                          ["#{I18n.t('general.lawyers')}: #{lawyers_text_without_office}"].join(', ')
                        end

      text.substitute('_proc_outorgado_', translated_text)
    end

    def substitute_job(text)
      translated_text =
        work.procedures.map do |procedure|
          Work.human_enum_name(:procedure, procedure.downcase).downcase.titleize
        end

      translated_text[0] = "#{'Procedimento'.pluralize(translated_text.size)} #{translated_text.first}"

      text.substitute('_proc_job_', translated_text.to_sentence)
    end

    # tranlate lawyers informations without office
    def lawyers_text_without_office
      text = []
      lawyers.each do |lawyer|
        address = lawyer.addresses.first
        text.push(lawyer.full_name)
        text.push(word_for_gender(lawyer.civil_status, lawyer.gender))
        text.push("OAB n° #{lawyer.oab}")
        text.push(word_for_gender(lawyer.nationality, lawyer.gender))
        text.push("com endereço: #{address.street.to_s.downcase.titleize}, n° #{address.number}")
        text.push(address.description.to_s.downcase.titleize)
        text.push("#{address.city} - #{address.state}, CEP #{address.zip_code}")
      end
      text.join(', ')
    end

    # tranlate lawyers informations with office
    def lawyers_text
      text = []
      lawyers.each do |lawyer|
        text.push(lawyer.full_name)
        text.push(word_for_gender(lawyer.civil_status, lawyer.gender))
        text.push("OAB n° #{lawyer.oab}")
        text.push(word_for_gender(lawyer.nationality, lawyer.gender))
      end
      text.join(', ')
    end

    # translate word using gender
    def word_for_gender(text, gender)
      I18n.t("gender.#{text}.#{gender}")
    end

    # when profile_custome is not able
    def responsable
      return nil unless customer.unable? && customer&.represent&.representor&.present?

      represent = customer.represent.representor
      represent_address = represent.addresses.first
      [
        ", #{word_for_gender('represent', represent.gender)} #{represent.full_name.downcase.titleize}",
        word_for_gender(represent.civil_status, represent.gender),
        "#{word_for_gender('owner', represent.gender)} do RG n° #{represent.rg} e #{word_for_gender('subscribe', represent.gender)} no CPF sob o n° #{represent.cpf}",
        represent.last_email, "residente e #{word_for_gender('live', represent.gender)}: #{represent_address.street.to_s.downcase.titleize}, n° #{represent_address.number}",
        represent_address.description.to_s.downcase.titleize,
        "#{represent_address.city} - #{represent_address.state}, CEP #{represent_address.zip_code}"
      ].join(', ')
    end

    # main function
    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      substitute_client_info(text)
      substitute_justice_agents(text)
      substitute_job(text)

      text.substitute('_proc_today_', "#{address.city}, #{address.state}, #{proc_date}")
      text.substitute('_proc_date_', proc_date)
      text.substitute('_proc_full_name_', customer.full_name.downcase.titleize)
    end
  end
end
