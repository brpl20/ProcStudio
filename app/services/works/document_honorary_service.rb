# frozen_string_literal: true

require 'docx'

module Works
  class DocumentHonoraryService < ApplicationService
    include ActionView::Helpers::NumberHelper

    def initialize(document_id)
      @document = Document.find(document_id)
      @work     = document.work
      @honorary = work.honorary
      @office   = work.offices.first
      @lawyers  = work.profile_admins.lawyer
      @customer = document.profile_customer
      @address  = customer.addresses.first
      @lawyer_address = lawyers.first.addresses.first
    end

    def call
      doc = Docx::Document.open('app/template_documents/honorario.docx')
      doc.paragraphs.each do |paragraph|
        paragraph.each_text_run do |text|
          substitute_word(text)
        end
      end
      filename = "tmp/honorario_#{work.id}_#{customer.id}.docx"
      doc.save(filename)
      document.document_docx.attach(
        ActiveStorage::Blob.create_and_upload!(io: File.open(filename), filename: "honorario_#{work.id}_#{customer.id}.docx", service_name: service_name)
      )
      FileUtils.remove_file(filename, true)
    end

    private

    attr_reader :document, :work, :honorary, :office, :lawyers, :lawyer_address, :customer, :address

    def service_name
      return :local if Rails.env.development?
      return :test  if Rails.env.test?

      :amazon
    end

    def substitute_client_info(text)
      translated_text = [
        customer.full_name.downcase.titleize,
        word_for_gender(customer.nationality, customer.gender),
        word_for_gender(customer.civil_status, customer.gender),
        ProfileCustomer.human_enum_name(:capacity, customer.capacity).downcase,
        customer.profession.downcase,
        "#{word_for_gender('owner', customer.gender)} do RG n° #{customer.rg} e #{word_for_gender('subscribe', customer.gender)} no CPF sob o n° #{customer.cpf}",
        "residente e #{word_for_gender('live', customer.gender)}: #{address.street.to_s.downcase.titleize}, n° #{address.number}",
        address.description.to_s.downcase.titleize, "#{address.city} - #{address.state}, CEP #{address.zip_code} #{responsable}",
        customer.mother_name,
        customer&.phones&.first&.phone_number,
        customer.last_email,
        bank_information(customer)
      ].join(', ')

      text.substitute('_proc_outorgante_', translated_text)
    end

    def bank_information(record)
      return 'Dados Bancários Não Informados' unless record.bank_accounts.present?

      bank = record.bank_accounts.first
      [
        "Banco: #{bank&.bank_name}",
        "Tipo de Conta: #{bank&.type_account}",
        "Agência: #{bank&.agency}",
        "Conta: #{bank&.account}",
        "Operação: #{bank&.operation}",
        "Pix: #{bank&.pix || 'Não informado'}"
      ].join(', ')
    end

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

    def substitute_job(text)
      translated_text =
        work.procedures.map do |procedure|
          Work.human_enum_name(:procedure, procedure.downcase).downcase.titleize
        end

      translated_text[0] = "#{'Procedimento'.pluralize(translated_text.size)} #{translated_text.first}"

      text.substitute('_proc_job_', translated_text.to_sentence)
    end

    def substitute_subject(text)
      text.substitute('_proc_subject_', Work.human_enum_name(:subject, work.subject).downcase.titleize)
    end

    def substitute_action(text)
      text.substitute('_proc_action_', work.number.to_s)
    end

    def substitute_rates(text)
      text.substitute('_proc_rates_', honorary.present? ? rate_text : '')
    end

    def substitute_office_bank(text)
      text.substitute('_proc_office_bank_', bank_information(office))
    end

    def rate_text
      case honorary.honorary_type
      when 'work'
        "o(a) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value)}"
      when 'success'
        "o(a) advogado(a) receberá o valor de #{number_to_percentage(honorary&.percent_honorary_value, precision: 2)} dos benefícios recebidos pelo cliente"
      when 'ambos'
        [
          'o(a) advogado(a) receberá uma parcela fixa de',
          "#{number_to_currency(honorary&.parcelling_value)} mais",
          number_to_percentage(honorary&.percent_honorary_value, precision: 2),
          'dos benefícios recebidos pelo cliente'
        ].join(' ')
      when 'bonus'
        'Nada a ser pago'
      end
    end

    def word_for_gender(text, gender)
      I18n.t("gender.#{text}.#{gender}")
    end

    def responsable
      return nil unless customer.unable? && customer&.represent&.representor&.present?

      represent = customer.represent.representor
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
      substitute_justice_agents(text)
      substitute_job(text)
      substitute_subject(text)
      substitute_action(text)
      substitute_rates(text)
      substitute_office_bank(text)

      text.substitute('_proc_today_', "#{address.city}, #{address.state}, #{proc_date}")
      text.substitute('_proc_full_name_', customer.full_name.downcase.titleize)
      text.substitute('_proc_lawyer_full_name_', lawyers.first.full_name.downcase.titleize)
    end
  end
end
