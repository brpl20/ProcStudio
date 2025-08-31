#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'smart_multi_partner_processor'

# Test data with 3 partners
data = {
  society: {
    name: 'TRÊS SÓCIOS ADVOGADOS ASSOCIADOS',
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
      address: 'RUA RUI BARBOSA',
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
      is_administrator: true
    }
  ],
  capital: {
    total_value: 15_000.00,
    total_quotes: 15_000,
    quote_value: 1.00,
    partners: [
      {
        name: 'EDUARDO HAMILTON WALBER',
        quotes: 3000,
        value: 3000.00,
        percentage: 20.00
      },
      {
        name: 'BRUNO PELLIZZETTI',
        quotes: 7000,
        value: 7000.00,
        percentage: 46.67
      },
      {
        name: 'MARIA SILVA SANTOS',
        quotes: 5000,
        value: 5000.00,
        percentage: 33.33
      }
    ]
  }
}

begin
  puts "\n#{'=' * 70}"
  puts '🚀 SMART MULTI-PARTNER PROCESSOR TEST'
  puts '=' * 70

  puts "\n📊 Contract Details:"
  puts "- Society: #{data[:society][:name]}"
  puts "- Number of Partners: #{data[:partners].size}"
  puts "\n👥 Partners:"
  data[:partners].each_with_index do |partner, index|
    capital_info = data[:capital][:partners][index]
    admin_status = partner[:is_administrator] ? ' [ADMIN]' : ''
    puts "  #{index + 1}. #{partner[:name]}"
    puts "     - Quotas: #{capital_info[:quotes]} (#{capital_info[:percentage]}%)#{admin_status}"
  end
  puts "\n💰 Capital: R$ #{data[:capital][:total_value]} (#{data[:capital][:total_quotes]} quotas)"

  puts "\n#{'-' * 70}"
  processor = SmartMultiPartnerProcessor.new('CS-TEMPLATE.docx')
  processor.process(data, '_', '_')

  output_file = "CS-SMART-MULTI-#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.docx"
  processor.save(output_file)

  puts "\n✅ Smart multi-partner contract generated: #{output_file}"

  puts "\n🎯 Features Implemented:"
  puts '✓ Single _partner_ field handles multiple partners'
  puts '✓ Table automatically populated with all partners'
  puts '✓ Capital distribution section generated for each partner'
  puts '✓ No need for _partner_1_, _partner_2_ patterns'
  puts '✓ Context-aware replacement (list vs paragraph vs table)'
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  puts e.backtrace.first(5)
end
