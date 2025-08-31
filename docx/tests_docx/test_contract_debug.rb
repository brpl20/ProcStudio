#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'contract_processor'

class DebugContractProcessor < ContractProcessor
  def substitute_society_info(society)
    puts "\n🏢 Substituting Society Info:"
    puts '-' * 40

    count = 0
    @doc.paragraphs.each do |paragraph|
      paragraph.each_text_run do |text|
        original = text.text.dup

        text.substitute('_society_name_', society[:name])
        text.substitute('_city_', society[:city])
        text.substitute('_state_', society[:state])
        text.substitute('_address_', society[:address])
        text.substitute('_zip_code_', society[:zip_code]) if society[:zip_code]

        next unless original != text.text

        count += 1
        puts "✓ Replaced in: '#{original[0..50]}...'"
        puts "  New: '#{text.text[0..50]}...'"
      end
    end
    puts "Total society replacements: #{count}"
  end

  def substitute_partners_info(partners)
    puts "\n👥 Substituting Partners Info:"
    puts '-' * 40

    partners_text = partners.map { |partner| format_partner(partner) }.join("\n\n")

    count = 0
    @doc.paragraphs.each do |paragraph|
      paragraph.each_text_run do |text|
        original = text.text.dup
        text.substitute('_partner_', partners_text)

        next unless original != text.text

        count += 1
        puts '✓ Replaced _partner_ in paragraph'
        puts "  Original: '#{original[0..100]}...'"
        puts "  New: '#{text.text[0..200]}...'"
      end
    end
    puts "Total partner replacements: #{count}"
  end

  def substitute_capital_info(capital)
    puts "\n💰 Substituting Capital Info:"
    puts '-' * 40

    total_value_words = Extenso.moeda(capital[:total_value])
    quote_value_words = Extenso.moeda(capital[:quote_value])

    puts "Total value: R$ #{format_currency(capital[:total_value])} = #{total_value_words}"
    puts "Quote value: R$ #{format_currency(capital[:quote_value])} = #{quote_value_words}"

    count = 0
    @doc.paragraphs.each do |paragraph|
      paragraph.each_text_run do |text|
        original = text.text.dup

        # Replace all capital-related fields
        text.substitute('_total_value_', format_currency(capital[:total_value]).to_s)
        text.substitute('_quotes_', capital[:total_quotes].to_s)
        text.substitute('_quote_value_', format_currency(capital[:quote_value]).to_s)
        text.substitute('_total_quotes_', capital[:total_quotes].to_s)
        text.substitute('_sum_', total_value_words)
        text.substitute('_sum_percentage_', '100,00')
        text.substitute('_parner_valute_', capital[:partners].first[:quotes].to_s) if capital[:partners].any?
        text.substitute('_partner_quotes_', capital[:partners].first[:quotes].to_s) if capital[:partners].any?
        text.substitute('_value_', format_currency(capital[:partners].first[:value])) if capital[:partners].any?
        text.substitute('_percentage_', capital[:partners].first[:percentage].round(2).to_s) if capital[:partners].any?

        if original != text.text
          count += 1
          puts "✓ Replaced in: '#{original[0..80]}...'"
        end
      end
    end
    puts "Total capital replacements: #{count}"
  end

  def process_partners_table(partners, capital)
    puts "\n📊 Processing Partners Table:"
    puts '-' * 40
    super
    puts '✓ Table processing complete'
  end

  def substitute_administrators(partners)
    puts "\n👔 Substituting Administrators:"
    puts '-' * 40

    administrators = partners.select { |p| p[:is_administrator] }
    puts "Administrators found: #{administrators.pluck(:name).join(', ')}"

    count = 0
    @doc.paragraphs.each do |paragraph|
      next unless paragraph.text.include?('será administrada') && paragraph.text.include?('_partner_')

      puts "Found administration paragraph: '#{paragraph.text[0..100]}...'"

      paragraph.each_text_run do |text|
        next unless administrators.any? && text.text.include?('_partner_')

        original = text.text.dup

        if administrators.size == 1
          admin = administrators.first
          text.substitute('_partner_', admin[:name])
        else
          names = administrators.map { |a| a[:name] }.join(' e ')
          text.substitute('_partner_', names)
        end

        if original != text.text
          count += 1
          puts '✓ Replaced administrator in text run'
        end
      end
    end
    puts "Total administrator replacements: #{count}"
  end
end

# Test data
data = {
  society: {
    name: 'PELLIZZETTI E WALBER ADVOGADOS ASSOCIADOS',
    city: 'Cascavel',
    state: 'PR',
    address: 'Rua Paraná, 3045, Sala 1204, Centro',
    zip_code: '85810-010'
  },
  partners: [
    {
      name: 'EDUARDO HAMILTON WALBER',
      nationality: 'BRASILEIRO',
      civil_status: 'SOLTEIRO',
      birth_city: 'Cascavel – PR',
      oab_state: 'PR',
      oab_number: 'OABpr 106344',
      birth_date: '13/03/1998',
      profession: 'Advogado',
      cpf: '063.989.629-40',
      city: 'Cascavel',
      state: 'PR',
      address: 'RUA KAMACAS',
      number: '681',
      complement: 'CASA',
      neighborhood: 'SANTA CRUZ',
      zip_code: '85806-010',
      is_administrator: false
    },
    {
      name: 'BRUNO PELLIZZETTI',
      nationality: 'BRASILEIRO',
      civil_status: 'SOLTEIRO',
      birth_city: 'Curitiba – PR',
      oab_state: 'PR',
      oab_number: 'OABpr 54159',
      birth_date: '01/01/1986',
      profession: 'Advogado',
      cpf: '058.802.539-96',
      city: 'Cascavel',
      state: 'PR',
      address: 'RUA RUI BARBOSA - ATE 879/880',
      number: '262',
      complement: 'APT 703',
      neighborhood: 'CENTRO',
      zip_code: '85810-240',
      is_administrator: true
    }
  ],
  capital: {
    total_value: 10_000.00,
    total_quotes: 10_000,
    quote_value: 1.00,
    partners: [
      {
        name: 'EDUARDO HAMILTON WALBER',
        quotes: 3000,
        value: 3000.00,
        percentage: 30.00
      },
      {
        name: 'BRUNO PELLIZZETTI',
        quotes: 7000,
        value: 7000.00,
        percentage: 70.00
      }
    ]
  }
}

begin
  puts '=' * 50
  puts 'DEBUG CONTRACT PROCESSOR'
  puts '=' * 50

  processor = DebugContractProcessor.new('CS-TEMPLATE.docx')
  processor.process(data)

  output_filename = "CS-DEBUG-#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.docx"
  processor.save(output_filename)

  puts "\n#{'=' * 50}"
  puts "✅ Contract generated: #{output_filename}"
  puts '=' * 50
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace
end
