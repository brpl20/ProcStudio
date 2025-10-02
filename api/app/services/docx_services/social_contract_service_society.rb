# frozen_string_literal: true

require 'docx'

module DocxServices
  class SocialContractServiceSociety
    attr_reader :office, :formatter_qualification, :formatter_office, :user_formatters, :doc, :file_path

    def initialize(office_id)
      @office = Office.find(office_id)
      @formatter_qualification = FormatterQualification.new(@office)
      @formatter_office = FormatterOffices.new(@office)
      @user_formatters = @office.user_profiles.map { |user| FormatterQualification.new(user) }
    end

    def call
      process_document
      file_path
    end

    def process_document
      @doc = ::Docx::Document.open(template_path.to_s)
      @file_path = Rails.root.join('app', 'services', 'docx_services', 'output', file_name)

      doc.paragraphs.each do |paragraph|
        substitute_placeholders_with_block(paragraph)
      end

      doc.save(file_path.to_s)
    end

    protected

    def template_path
      Rails.root.join('app', 'services', 'docx_services', 'templates', 'CS-TEMPLATE.docx')
    end

    def file_name
      "cs-#{@office.name.parameterize}.docx"
    end

    private

    def substitute_placeholders_with_block(paragraph)
      substitute_partner_qualification(paragraph)
      substitute_office_qualification(paragraph)
      substitute_office_settings(paragraph)
      substitute_date_field(paragraph)
    end

    def substitute_partner_qualification(paragraph)
      # Partner full name - iterate through all partners
      @user_formatters.each_with_index do |user_formatter, index|
        paragraph.substitute_across_runs_with_block_regex("_partner_#{index + 1}_full_name_") do |_|
          user_formatter.full_name(upcase: true)
        end
        
        paragraph.substitute_across_runs_with_block_regex("_partner_#{index + 1}_qualification_") do |_|
          user_formatter.qualification
        end
      end
      
      # Generic partner placeholders (for first partner)
      if @user_formatters.first
        first_user = @user_formatters.first
        
        paragraph.substitute_across_runs_with_block_regex("_partner_full_name_") do |_|
          first_user.full_name(upcase: true)
        end
        
        paragraph.substitute_across_runs_with_block_regex("_partner_qualification_") do |_|
          first_user.qualification
        end
      end
    end

    def substitute_office_qualification(paragraph)
      paragraph.substitute_across_runs_with_block_regex("_office_name_") do |_|
        @formatter_qualification.full_name
      end

      paragraph.substitute_across_runs_with_block_regex("_office_state_") do |_|
        @formatter_qualification.state || ''
      end

      paragraph.substitute_across_runs_with_block_regex("_office_city_") do |_|
        @formatter_qualification.city || ''
      end

      paragraph.substitute_across_runs_with_block_regex("_office_address_") do |_|
        @formatter_qualification.address(with_prefix: false) || ''
      end

      paragraph.substitute_across_runs_with_block_regex("_office_zip_code_") do |_|
        @formatter_qualification.zip_code || ''
      end
    end

    def substitute_office_settings(paragraph)
      paragraph.substitute_across_runs_with_block_regex("_office_total_value_") do |_|
        @formatter_office.quote_value || ''
      end
      
      paragraph.substitute_across_runs_with_block_regex("_office_quotes_") do |_|
        @formatter_office.number_of_quotes || ''
      end
      
      paragraph.substitute_across_runs_with_block_regex("_office_quote_value_") do |_|
        individual_quote_value
      end
      
      paragraph.substitute_across_runs_with_block_regex("_office_society_type_") do |_|
        @formatter_office.society || ''
      end
      
      paragraph.substitute_across_runs_with_block_regex("_office_accounting_type_") do |_|
        @formatter_office.accounting_type || ''
      end
    end

    def substitute_date_field(paragraph)
      paragraph.substitute_across_runs_with_block_regex("_current_date_") do |_|
        I18n.l(Date.current, format: :long)
      end
    end
    
    private
    
    def individual_quote_value
      return '' unless @office.quote_value && @office.number_of_quotes && @office.number_of_quotes > 0
      
      individual_value = @office.quote_value.to_f / @office.number_of_quotes.to_f
      MonetaryValidator.format(individual_value)
    end
  end
end