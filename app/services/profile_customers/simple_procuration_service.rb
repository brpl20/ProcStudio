# frozen_string_literal: true

require 'docx'

module ProfileCustomers
  class SimpleProcurationService < ApplicationService
    def initialize(document_id, admin_id)
      @document = CustomerFile.find(document_id)
      @customer = @document.profile_customer
      @address = @customer.addresses.first
      @customer_email = @customer.emails.first
      @current_user = ProfileAdmin.find(admin_id)
      @office = @current_user.office
      @lawyers = @office.profile_admins.lawyer
      @lawyer_address = @lawyers.first.addresses.first
      @represent = @customer&.represent
    end

    def call
      doc = if @customer.able?
              Docx::Document.open('app/template_documents/procuracao.docx')
            elsif @customer.unable?
              Docx::Document.open('app/template_documents/procuracao_incapaz.docx')
            else
              Docx::Document.open('app/template_documents/procuracao_parcialmente_incapaz.docx')
            end

      doc.paragraphs.each do |paragraph|
        paragraph.each_text_run do |text|
          substitute_word(text)
        end
      end
      doc.save("tmp/procuracao_simples_#{@document.id}.docx")

      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open("tmp/procuracao_simples_#{@document.id}.docx"),
        filename: "procuracao_simples_#{@document.id}.docx",
        service_name: service_name
      )
      @document.document_docx.attach(blob)
      FileUtils.remove_file("tmp/procuracao_simples_#{@document.id}.docx", true)
    end

    # main function
    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      substitute_client_info(text)
      substitute_justice_agents(text)
      substitute_job(text)

      text.substitute('_proc_powers_', '')
      text.substitute('_proc_today_', "#{@address.city&.strip} - #{@address.state&.strip}, #{proc_date}")
      text.substitute('_proc_date_', proc_date)
      text.substitute('_proc_full_name_', @customer.full_name.downcase.titleize&.strip) unless @customer.unable?
      text.substitute('_proc_represent_full_name_', @represent.representor.full_name&.strip) if @represent&.representor&.present?
    end

    # outorgante paragraph
    def substitute_client_info(text)
      translated_text = [
        @customer.full_name.downcase.titleize&.strip,
        word_for_gender(@customer.nationality, @customer.gender),
        word_for_gender(@customer.civil_status, @customer.gender),
        capacity,
        @customer.profession.downcase&.strip,
        "#{word_for_gender('owner', @customer.gender)} do RG n° #{@customer.rg&.strip} e #{word_for_gender('subscribe', @customer.gender)} no CPF sob o n° #{@customer.cpf&.strip}",
        @customer.last_email&.strip, "residente e #{word_for_gender('live', @customer.gender)} à #{@address.street.to_s.downcase.titleize&.strip}, n° #{@address.number}",
        @address.description.to_s.downcase.titleize&.strip, "#{@address.city&.strip} - #{@address.state}, CEP #{@address.zip_code&.strip}",
        responsable
      ].compact.join(', ')

      text.substitute('_proc_outorgante_', translated_text)
    end

    def capacity
      ProfileCustomer.human_enum_name(:capacity, @customer.capacity).downcase unless @customer.capacity == 'able'
    end

    # outorgados paragraph
    def substitute_justice_agents(text)
      translated_text = if @office.present?
                          ["#{I18n.t('general.lawyers')}: #{lawyers_text}", "integrante(s) da #{@office.name&.strip} inscrita sob o cnpj #{@office.cnpj}",
                           "com endereço profissional à Rua #{@office.street.to_s.downcase.titleize&.strip}", @office.number.to_s, @office.neighborhood.downcase.titleize&.strip,
                           "#{@office.city&.strip}-#{@office.state&.strip}", "e endereço eletrônico #{@office.site&.strip}"]
                            .join(', ')
                        else
                          ["#{I18n.t('general.lawyers')}: #{lawyers_text_without_office}"].join(', ')
                        end

      text.substitute('_proc_outorgado_', translated_text)
    end

    # servico paragraph
    def substitute_job(text)
      translated_text = 'Consulta, protocolo, carga, cópia e acesso à informação de benefícios previdenciários em geral'
      text.substitute('_proc_job_', translated_text)
    end

    def responsable
      return nil if @customer.able?
      return nil unless @represent&.representor&.present?

      representor = @customer.represent.representor
      representor_address = representor.addresses.first
      representor_text =
        if @customer.unable?
          "Neste ato #{word_for_gender('represent', representor.gender).downcase}"
        else
          "Neste ato #{word_for_gender('assisted', representor.gender).downcase}"
        end

      [
        "#{representor_text} #{representor.full_name.downcase.titleize&.strip}",
        word_for_gender(representor.civil_status, representor.gender),
        "#{word_for_gender('owner', representor.gender)} do RG n° #{representor.rg} e #{word_for_gender('subscribe', representor.gender)} no CPF sob o n° #{representor.cpf}",
        representor.last_email,
        "residente e #{word_for_gender('live', representor.gender)} à #{representor_address.street.to_s.downcase.titleize&.strip}, n° #{representor_address.number}",
        representor_address.description.to_s.downcase.titleize&.strip,
        "#{representor_address.city&.strip} - #{representor_address.state&.strip}, CEP #{representor_address.zip_code&.strip}"
      ].join(', ')
    end

    # tranlate lawyers informations with office
    def lawyers_text
      text = []
      @lawyers.each do |lawyer|
        text.push(lawyer.full_name)
        text.push(word_for_gender(lawyer.civil_status, lawyer.gender))
        text.push("OAB n° #{lawyer.oab}")
      end
      text.join(', ')
    end

    # translate word using gender
    def word_for_gender(text, gender)
      I18n.t("gender.#{text}.#{gender}")
    end

    private

    def service_name
      return :local if Rails.env.development?
      return :test  if Rails.env.test?

      :amazon
    end
  end
end
