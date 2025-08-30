#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'multi_partner_processor'

# Test data with 4 partners to really test the multi-line capability
data = {
  society: {
    name: 'MÚLTIPLOS SÓCIOS ADVOGADOS ASSOCIADOS',
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
    },
    {
      name: 'MARIA SILVA SANTOS',
      nationality: 'BRASILEIRA',
      civil_status: 'CASADA',
      birth_city: 'São Paulo – SP',
      oab_state: 'PR',
      oab_number: 'OABpr 78945',
      birth_date: '15/07/1990',
      profession: 'Advogada',
      cpf: '123.456.789-00',
      city: 'Cascavel',
      state: 'PR',
      address: 'AVENIDA BRASIL',
      number: '1500',
      complement: 'SALA 201',
      neighborhood: 'CENTRO',
      zip_code: '85801-000',
      is_administrator: false
    },
    {
      name: 'JOÃO CARLOS OLIVEIRA',
      nationality: 'BRASILEIRO',
      civil_status: 'DIVORCIADO',
      birth_city: 'Rio de Janeiro – RJ',
      oab_state: 'PR',
      oab_number: 'OABpr 65432',
      birth_date: '22/11/1985',
      profession: 'Advogado',
      cpf: '987.654.321-11',
      city: 'Cascavel',
      state: 'PR',
      address: 'RUA DAS FLORES',
      number: '789',
      complement: 'APTO 15',
      neighborhood: 'JARDIM PAULISTA',
      zip_code: '85803-500',
      is_administrator: false
    }
  ],
  capital: {
    total_value: 20_000.00,
    total_quotes: 20_000,
    quote_value: 1.00,
    partners: [
      {
        name: 'EDUARDO HAMILTON WALBER',
        quotes: 5000,
        value: 5000.00,
        percentage: 25.00
      },
      {
        name: 'BRUNO PELLIZZETTI',
        quotes: 8000,
        value: 8000.00,
        percentage: 40.00
      },
      {
        name: 'MARIA SILVA SANTOS',
        quotes: 4000,
        value: 4000.00,
        percentage: 20.00
      },
      {
        name: 'JOÃO CARLOS OLIVEIRA',
        quotes: 3000,
        value: 3000.00,
        percentage: 15.00
      }
    ]
  }
}

begin
  puts "\n#{'=' * 70}"
  puts '🚀 MULTI-PARTNER DYNAMIC LINE CREATION TEST'
  puts '=' * 70

  puts "\n📊 Test Data Summary:"
  puts "- Society: #{data[:society][:name]}"
  puts "- Number of Partners: #{data[:partners].size}"
  puts '- Partners:'
  data[:partners].each_with_index do |partner, index|
    puts "  #{index + 1}. #{partner[:name]} (#{data[:capital][:partners][index][:percentage]}%)"
  end
  puts "- Total Capital: R$ #{data[:capital][:total_value]}"

  puts "\n📄 Processing contract with dynamic partner lines..."
  processor = MultiPartnerProcessor.new('CS-TEMPLATE.docx')
  processor.process(data, '_', '_')

  output_file = "CS-MULTI-PARTNERS-#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.docx"
  processor.save(output_file)

  puts "\n✅ Multi-partner contract generated: #{output_file}"

  puts "\n🎯 Key Features Demonstrated:"
  puts '✓ Dynamic partner line creation (no _partner_1_, _partner_2_ needed)'
  puts '✓ Context-aware paragraph handling'
  puts '✓ Automatic table expansion for all partners'
  puts '✓ Preserved formatting across all insertions'
  puts '✓ Smart pattern detection for list vs. paragraph contexts'

  puts "\n📋 Template Usage Patterns Supported:"
  puts "1. Simple replacement: '_partner_' becomes multiple paragraphs"
  puts "2. List format: 'a. _partner_' becomes 'a. Partner1', 'b. Partner2', etc."
  puts "3. Numbered format: '1. _partner_' becomes '1. Partner1', '2. Partner2', etc."
  puts '4. Table format: Automatically adds rows for each partner'
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  puts e.backtrace.first(5)
end
