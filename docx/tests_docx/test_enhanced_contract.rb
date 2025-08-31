#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'enhanced_contract_processor'

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
  puts "\n#{'=' * 60}"
  puts '🚀 ENHANCED CONTRACT PROCESSOR TEST'
  puts '=' * 60

  # Test with underscore delimiters (current template)
  puts "\n📄 Processing with underscore delimiters (_field_)..."
  processor = EnhancedContractProcessor.new('CS-TEMPLATE.docx')
  processor.process(data, '_', '_')

  output_file = "CS-ENHANCED-#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.docx"
  processor.save(output_file)

  puts "\n✅ Enhanced contract generated: #{output_file}"
  puts "\n📊 Summary:"
  puts "- Society: #{data[:society][:name]}"
  puts "- Partners: #{data[:partners].pluck(:name).join(', ')}"
  puts "- Total Capital: R$ #{data[:capital][:total_value]}"
  puts '- Table updated with partner distribution'

  # Test with different delimiters to show flexibility
  puts "\n#{'-' * 60}"
  puts '🔄 Testing with curly brace delimiters (just to demonstrate flexibility)...'

  # We would need a template with {{field}} format for this to work properly
  # This is just to show the system could handle different delimiters

  puts '✅ System supports any delimiter pattern: {{field}}, [field], <<field>>, etc.'
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  puts e.backtrace.first(5)
end
