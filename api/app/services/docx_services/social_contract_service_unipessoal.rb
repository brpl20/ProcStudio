# frozen_string_literal: true

require 'docx'
require_relative 'formatter_constants_offices'

module DocxServices
  class SocialContractServiceUnipessoal
    include FormatterConstantsOffices

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

      # Process all paragraphs in the document
      doc.paragraphs.each do |paragraph|
        substitute_placeholders_with_block(paragraph)
      end

      # Process all tables in the document
      doc.tables.each do |table|
        table.rows.each do |row|
          row.cells.each do |cell|
            cell.paragraphs.each do |paragraph|
              substitute_placeholders_with_block(paragraph)
            end
          end
        end
      end

      doc.save(file_path.to_s)
    end

    protected

    def template_path
      Rails.root.join('app/services/docx_services/templates/CS-UNIPESSOAL-TEMPLATE.docx')
    end

    def file_name
      "cs-unipessoal-#{@office.name.parameterize}.docx"
    end

    private

    def substitute_placeholders_with_block(paragraph)
      substitute_partner_qualification(paragraph)
      substitute_office_qualification(paragraph)
      substitute_office_settings(paragraph)
      substitute_partner_specific_placeholders(paragraph)
      substitute_dividends_placeholders(paragraph)
      substitute_administrator_placeholders(paragraph)
      substitute_date_field(paragraph)
    end

    def substitute_partner_qualification(paragraph)
      # Replace single placeholder with partner's qualification (single partner for unipessoal)
      paragraph.substitute_across_runs_with_block_regex('_partner_qualification_') do |_|
        @user_formatters.first&.qualification || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_partner_subscription_') do |_|
        @formatter_office.all_partners_subscription
      end
    end

    def substitute_office_qualification(paragraph)
      paragraph.substitute_across_runs_with_block_regex('_office_name_') do |_|
        @formatter_qualification.full_name
      end

      paragraph.substitute_across_runs_with_block_regex('_office_state_') do |_|
        @formatter_qualification.state || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_city_') do |_|
        @formatter_qualification.city || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_address_') do |_|
        @formatter_qualification.address(with_prefix: false) || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_zip_code_') do |_|
        @formatter_qualification.zip_code || ''
      end
    end

    def substitute_office_settings(paragraph)
      paragraph.substitute_across_runs_with_block_regex('_office_total_value_') do |_|
        @formatter_office.quote_value || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_quotes_') do |_|
        @formatter_office.number_of_quotes || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_quote_value_') do |_|
        individual_quote_value
      end

      paragraph.substitute_across_runs_with_block_regex('_office_society_type_') do |_|
        @formatter_office.society || ''
      end

      paragraph.substitute_across_runs_with_block_regex('_office_accounting_type_') do |_|
        @formatter_office.accounting_type || ''
      end
      
      # Total quotes placeholder for tables
      paragraph.substitute_across_runs_with_block_regex('_total_quotes_') do |_|
        @office.number_of_quotes.to_s
      end
    end

    def substitute_partner_specific_placeholders(paragraph)
      # For Unipessoal template, we need specific partner placeholders
      if @user_formatters.any?
        partner_formatter = @user_formatters.first
        partners_info = @formatter_office.partners_info.first
        
        # Partner personal information
        paragraph.substitute_across_runs_with_block_regex('_partner_full_name_') do |_|
          partner_formatter.full_name
        end
        
        paragraph.substitute_across_runs_with_block_regex('_partner_name_') do |_|
          partner_formatter.full_name
        end
        
        paragraph.substitute_across_runs_with_block_regex('_partner_cpf_') do |_|
          partner_formatter.cpf
        end
        
        paragraph.substitute_across_runs_with_block_regex('_partner_rg_') do |_|
          partner_formatter.rg
        end
        
        paragraph.substitute_across_runs_with_block_regex('_partner_address_') do |_|
          partner_formatter.address
        end
        
        paragraph.substitute_across_runs_with_block_regex('_partner_email_') do |_|
          partner_formatter.email
        end
        
        paragraph.substitute_across_runs_with_block_regex('_partner_phone_') do |_|
          partner_formatter.phone
        end
        
        # Partner capital/quotes information
        paragraph.substitute_across_runs_with_block_regex('_partner_total_quotes_') do |_|
          partners_info ? partners_info[:partner_number_of_quotes_formatted] : @office.number_of_quotes.to_s
        end
        
        paragraph.substitute_across_runs_with_block_regex('_partner_sum_') do |_|
          partners_info ? partners_info[:partner_quote_value_formatted] : @formatter_office.quote_value
        end
        
        paragraph.substitute_across_runs_with_block_regex('_%_') do |_|
          '100%'
        end
        
        paragraph.substitute_across_runs_with_block_regex('_sum_percentage_') do |_|
          '100%'
        end
        
        # Partner 1 specific fields (for signature sections)
        paragraph.substitute_across_runs_with_block_regex('_partner_1_full_name_') do |_|
          partner_formatter.full_name
        end
        
        paragraph.substitute_across_runs_with_block_regex('_partner_1_association_') do |_|
          'Sócio Administrador'
        end
        
        # Handle potential typo in template
        paragraph.substitute_across_runs_with_block_regex('_parner_1_association_') do |_|
          'Sócio Administrador'
        end
        
        paragraph.substitute_across_runs_with_block_regex('_parner_full_name_') do |_|
          partner_formatter.full_name
        end
      else
        # Clear all partner placeholders if no partner found
        placeholders = [
          '_partner_full_name_', '_partner_name_', '_partner_cpf_', '_partner_rg_',
          '_partner_address_', '_partner_email_', '_partner_phone_', '_partner_total_quotes_',
          '_partner_sum_', '_%_', '_sum_percentage_', '_partner_1_full_name_',
          '_partner_1_association_', '_parner_1_association_', '_parner_full_name_'
        ]
        
        placeholders.each do |placeholder|
          paragraph.substitute_across_runs_with_block_regex(placeholder) do |_|
            ''
          end
        end
      end
      
      # Empty partner 2 placeholders for Unipessoal (since there's only one partner)
      paragraph.substitute_across_runs_with_block_regex('_partner_2_full_name_') do |_|
        ''
      end
      
      paragraph.substitute_across_runs_with_block_regex('_partner_2_association_') do |_|
        ''
      end
    end

    def substitute_dividends_placeholders(paragraph)
      if @formatter_office.is_proportional
        # If proportional is TRUE, replace with specific text from constants
        paragraph.substitute_across_runs_with_block_regex('_dividends_') do |_|
          DIVIDENDS_TITLE
        end
        
        paragraph.substitute_across_runs_with_block_regex('_dividends_text_') do |_|
          DIVIDENDS_TEXT
        end
      else
        # If proportional is FALSE, remove the placeholders
        paragraph.substitute_across_runs_with_block_regex('_dividends_') do |_|
          ''
        end
        
        paragraph.substitute_across_runs_with_block_regex('_dividends_text_') do |_|
          ''
        end
      end
      
      # Check if the single partner has pro_labore compensation
      partners_compensation = @formatter_office.partners_compensation
      has_pro_labore = partners_compensation.any? { |partner| partner[:compensation_type] == 'pro_labore' }
      
      if has_pro_labore
        # If partner has pro_labore, replace with specific text from constants
        paragraph.substitute_across_runs_with_block_regex('_pro_labore_') do |_|
          PRO_LABORE_TITLE
        end
        
        paragraph.substitute_across_runs_with_block_regex('_pro_labore_text_') do |_|
          PRO_LABORE_TEXT
        end
      else
        # If no pro_labore, remove the placeholders
        paragraph.substitute_across_runs_with_block_regex('_pro_labore_') do |_|
          ''
        end
        
        paragraph.substitute_across_runs_with_block_regex('_pro_labore_text_') do |_|
          ''
        end
      end
    end

    def substitute_administrator_placeholders(paragraph)
      # For unipessoal, the single partner is always the administrator
      if @user_formatters.any?
        formatter = @user_formatters.first
        user = @office.user_profiles.first
        
        # Determine gender and get prefix from constants
        gender = determine_administrator_gender(user)
        prefix = ADMINISTRATOR_PREFIXES[:single][gender]
        
        paragraph.substitute_across_runs_with_block_regex('_partner_full_name_administrator_') do |_|
          "#{prefix} #{formatter.full_name}"
        end
      else
        paragraph.substitute_across_runs_with_block_regex('_partner_full_name_administrator_') do |_|
          ''
        end
      end
    end

    def substitute_date_field(paragraph)
      paragraph.substitute_across_runs_with_block_regex('_current_date_') do |_|
        I18n.l(Date.current, format: :long)
      end
      
      paragraph.substitute_across_runs_with_block_regex('_date_') do |_|
        I18n.l(Date.current, format: :long)
      end
    end
    
    def determine_administrator_gender(user)
      # Use the same gender determination logic
      return :male unless user
      
      # Check if user has gender field
      if user.respond_to?(:gender)
        return user.gender&.to_sym == :female ? :female : :male
      end
      
      # Default to male if we can't determine
      :male
    end

    def individual_quote_value
      return '' unless @office.quote_value && @office.number_of_quotes&.positive?

      individual_value = @office.quote_value / @office.number_of_quotes.to_f
      MonetaryValidator.format(individual_value)
    end

  end
end
