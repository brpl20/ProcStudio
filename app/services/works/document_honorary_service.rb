# frozen_string_literal: true

require 'docx'

module Works
  class DocumentHonoraryService < ApplicationService
    include Works::Base
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
      doc.paragraphs.each do |paragraph|
        paragraph.each_text_run do |text|
          substitute_word(text)
        end
      end
      doc.save(filename)

      save
    end

    private

    attr_reader :document, :work, :honorary, :office, :lawyers, :lawyer_address, :customer, :address

    def bank_information(resource)
      return 'Dados Bancários Não Informados' unless resource&.bank_accounts&.present?

      bank = resource.bank_accounts.first
      [
        "Banco: #{bank&.bank_name&.strip}",
        "Tipo de Conta: #{bank&.type_account&.strip}",
        "Agência: #{bank&.agency&.strip}",
        "Conta: #{bank&.account&.strip}",
        "Operação: #{bank&.operation&.strip}",
        "Pix: #{bank&.pix&.strip || 'Não informado'}"
      ].join(', ')
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
      when 'bonus'
        'Nada a ser pago'
      when 'work'
        if honorary.work_prev.present? && honorary.parcelling_value.present?
          "O(A) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value)} (#{Extenso.moeda(honorary.fixed_honorary_value.to_f)}) e #{honorary.work_prev} (#{Extenso.numero(honorary.work_prev)}) benefícios previdenciários em #{honorary&.parcelling_value&.to_i} (#{Extenso.numero(honorary.parcelling_value.to_i, 1)}) parcelas de igual valor e com mesmo vencimento a partir da assinatura deste documento"
        elsif honorary.work_prev.present? && honorary.parcelling_value.blank?
          "O(A) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value)} (#{Extenso.moeda(honorary.fixed_honorary_value.to_f)}) a vista e #{honorary.work_prev} (#{Extenso.numero(honorary.work_prev)}) benefícios previdenciários"
        elsif honorary.parcelling_value.present?
          "O(A) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value)} (#{Extenso.moeda(honorary.fixed_honorary_value.to_f)}) em #{honorary&.parcelling_value&.to_i} (#{Extenso.numero(honorary.parcelling_value.to_i, 1)}) parcelas de igual valor e com mesmo vencimento a partir da assinatura deste documento"
        else
          "O(A) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value)} (#{Extenso.moeda(honorary.fixed_honorary_value.to_f)}) a vista"
        end
      when 'success'
        "O(A) advogado(a) receberá o valor de #{number_to_percentage(honorary&.percent_honorary_value, precision: 2)} dos benefícios brutos advindos deste processo"
      when 'both'
        if honorary.work_prev.present? && honorary.parcelling_value.present?
          "O(A) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value)} (#{Extenso.moeda(honorary.fixed_honorary_value.to_f)}) a vista e #{honorary.work_prev} (#{Extenso.numero(honorary.work_prev)}) benefícios previdenciários em #{honorary&.parcelling_value&.to_i} (#{Extenso.numero(honorary.parcelling_value.to_i, 1)}) parcelas de igual valor e mais um valor variável de #{number_to_percentage(honorary&.percent_honorary_value, precision: 2)} dos benefícios brutos advindos deste processo"
        elsif honorary.work_prev.present? && honorary.parcelling_value.blank?
          "O(A) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value)} (#{Extenso.moeda(honorary.fixed_honorary_value.to_f)}) a vista e mais #{honorary.work_prev} (#{Extenso.numero(honorary.work_prev)}) benefícios previdenciários e maisl um valor variável de #{number_to_percentage(honorary&.percent_honorary_value, precision: 2)} dos benefícios brutos advindos deste processo"
        elsif honorary.parcelling_value.present?
          [
            "O(A) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value)} (#{Extenso.moeda(honorary.fixed_honorary_value.to_f)})",
            "em #{honorary&.parcelling_value&.to_i} (#{Extenso.numero(honorary.parcelling_value.to_i, 1)}) parcelas de igual valor e com mesmo vencimento a partir da assinatura deste documento,",
            "mais um valor variável de #{number_to_percentage(honorary&.percent_honorary_value, precision: 2)} dos benefícios brutos advindos deste processo"
          ].join(' ')
        else
          "O(A) advogado(a) receberá o valor de #{number_to_currency(honorary&.fixed_honorary_value, precision: 2)} (#{Extenso.moeda(honorary.fixed_honorary_value.to_f)}) a vista e mais um valor variável de #{number_to_percentage(honorary&.percent_honorary_value, precision: 2)} dos benefícios brutos advindos deste processo"
        end
      end
    end

    def save
      document.file.attach(blob)
      FileUtils.remove_file(filename, true)
    rescue StandardError => e
      Rails.logger.error("[Document Error]: #{e.message}")
      false
    end

    def doc
      @doc ||=
        if customer.able?
          Docx::Document.open('app/template_documents/honorario.docx')
        elsif customer.unable?
          Docx::Document.open('app/template_documents/honorario_incapaz.docx')
        else
          Docx::Document.open('app/template_documents/honorario_parcialmente_incapaz.docx')
        end
    end

    def representor
      customer&.represent&.representor
    end

    def filename
      @filename ||= "tmp/honorario_#{work.id}_#{customer.id}.docx"
    end

    def blob
      @blob ||=
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(filename),
          filename: "honorario_#{work.id}_#{customer.id}.docx",
          service_name: service_name
        )
    end

    def substitute_word(text)
      proc_date = I18n.l(Time.now, format: '%d de %B de %Y')

      substitute_client_info(text)
      substitute_justice_agents(text)
      substitute_job(text)
      substitute_action(text)
      substitute_rates(text)
      substitute_office_bank(text)

      text.substitute('_proc_today_', "#{address.city&.strip}, #{address.state&.strip}, #{proc_date}")
      text.substitute('_proc_full_name_', customer.full_name.upcase)
      text.substitute('_proc_lawyer_full_name_', lawyers.first.full_name.upcase)
      text.substitute('_proc_represent_full_name_', representor&.full_name&.upcase) if representor&.present?
    end
  end
end
