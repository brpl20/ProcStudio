# frozen_string_literal: true

require 'docx'

module Works
  class DocumentProcurationService < ApplicationService
    def initialize(work, document)
      @work = work
      @document = document
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

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')
      # OUTORGANTE
      text.substitute('_proc_name_', 'Sasuke')
      text.substitute('_proc_gender_', 'Sasuke')
      text.substitute('_proc_status_', 'civil')
      text.substitute('_proc_capacity_', 'Sasuke')
      text.substitute('_proc_rg_', 'Sasuke')
      text.substitute('_proc_cpf_', 'Sasuke')
      text.substitute('_proc_number_benefit_', 'Sasuke')
      text.substitute('_proc_nit_', 'Sasuke')
      text.substitute('_proc_email_', 'Sasuke')
      text.substitute('_proc_mother_', 'Sasuke')
      text.substitute('_proc_bank_name_', 'Sasuke')
      text.substitute('_proc_agency_', 'Sasuke')
      text.substitute('_proc_type_account_', 'Sasuke')
      text.substitute('_proc_account_', 'Sasuke')
      text.substitute('_proc_street_', 'Sasuke')
      text.substitute('_proc_number_', 'Sasuke')
      text.substitute('_proc_description_', 'Sasuke')
      text.substitute('_proc_city_', 'Sasuke')
      text.substitute('_proc_state_', 'Sasuke')
      text.substitute('_proc_oab_', 'Sasuke')
      # outorgados
      text.substitute('_proc_customer_email_', 'Sasuke')
      # Date, state and city
      text.substitute('_pro_city_', 'Sasuke')
      text.substitute('_proc_state_', 'Sasuke')
      text.substitute('_proc_date_', proc_date)
      # full name
      text.substitute('_proc_full_name_', 'Sasuke')
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
