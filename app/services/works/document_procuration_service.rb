# frozen_string_literal: true

require 'docx'

module Works
  class DocumentProcurationService < ApplicationService
    def initialize(document_id)
      @document = Document.find(document_id)
      @work = @document.work
      @customer = @work.profile_customers.first
      @bank = @customer.bank_accounts.first
      @address = @customer.addresses.first
      @customer_email = @customer.emails.first
      @office = @work.office
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

    def substitute_bank(text)
      return if @bank.nil?

      text.substitute('_proc_bank_name_', @bank.bank_name.downcase.titleize)
      text.substitute('_proc_agency_', @bank.agency)
      text.substitute('_proc_type_account_', @bank.type_account)
      text.substitute('_proc_account_', @bank.account)
    end

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
      return if @customer.nil?

      translated_text_one = [@customer.full_name.downcase.titleize, ProfileCustomer.human_enum_name(:nationality, @customer.nationality),
                             ProfileCustomer.human_enum_name(:civil_status, @customer.civil_status), @customer.profession,
                             "portador do RG n° #{@customer.rg} e inscrito no CPF sob o n° #{@customer.cpf}",
                             @customer.last_email,
                             "residente e domiciliado: #{@address.street.to_s.downcase.titleize}, n° #{@address.number}, #{@address.description.to_s.downcase.titleize}",
                             "#{@address.city} - #{@address.state}, CEP #{@address.zip_code}"].join(', ')

      text.substitute('_proc_outorgante_', translated_text_one)
    end

    def word_for_gender(text); end

    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      substitute_outorgante(text)
      substitute_bank(text)
      substitute_address(text)
      substitute_office(text)

      text.substitute('_proc_today_', "#{@address.city}, #{@address.state}, #{proc_date}")
      text.substitute('_proc_date_', proc_date)
      text.substitute('_proc_full_name_', @customer.full_name.downcase.titleize)
    end
  end
end
