# frozen_string_literal: true

puts 'Seeding Legal Cost Types...'

legal_cost_types = [
  # Judicial costs
  { key: 'custas_judiciais', name: 'Custas Judiciais', category: 'judicial', display_order: 10 },
  { key: 'taxa_judiciaria', name: 'Taxa Judiciária', category: 'judicial', display_order: 20 },
  { key: 'diligencia_oficial', name: 'Diligência de Oficial de Justiça', category: 'judicial', display_order: 30 },
  { key: 'distribuicao', name: 'Taxa de Distribuição', category: 'judicial', display_order: 40 },
  { key: 'taxa_recursal', name: 'Taxa de Recurso', category: 'judicial', display_order: 50 },
  { key: 'deposito_recursal', name: 'Depósito Recursal', category: 'judicial', display_order: 60 },
  { key: 'preparo', name: 'Preparo', category: 'judicial', display_order: 70 },
  { key: 'porte_remessa', name: 'Porte de Remessa e Retorno', category: 'judicial', display_order: 80 },
  { key: 'pericia', name: 'Honorários Periciais', category: 'judicial', display_order: 90 },
  
  # Tax costs
  { key: 'guia_darf', name: 'Guia DARF', category: 'tax', display_order: 100 },
  { key: 'guia_gps', name: 'Guia GPS', category: 'tax', display_order: 110 },
  { key: 'imposto_renda_advocacia', name: 'Imposto de Renda - Serviços Advocatícios', category: 'tax', display_order: 120 },
  { key: 'iss', name: 'ISS - Imposto sobre Serviços', category: 'tax', display_order: 130 },
  
  # Notarial costs
  { key: 'despesas_cartorarias', name: 'Despesas Cartorárias', category: 'notarial', display_order: 140 },
  { key: 'certidoes', name: 'Certidões', category: 'notarial', display_order: 150 },
  { key: 'autenticacoes', name: 'Autenticações', category: 'notarial', display_order: 160 },
  { key: 'reconhecimento_firma', name: 'Reconhecimento de Firma', category: 'notarial', display_order: 170 },
  
  # Administrative costs
  { key: 'guia_recolhimento_oab', name: 'Guia de Recolhimento OAB', category: 'administrative', display_order: 180 },
  { key: 'edital', name: 'Publicação de Edital', category: 'administrative', display_order: 190 },
  
  # Other
  { key: 'outros', name: 'Outros', category: 'other', display_order: 999 }
]

legal_cost_types.each do |type_data|
  LegalCostType.find_or_create_by!(
    key: type_data[:key],
    team_id: nil
  ) do |cost_type|
    cost_type.name = type_data[:name]
    cost_type.category = type_data[:category]
    cost_type.display_order = type_data[:display_order]
    cost_type.is_system = true
    cost_type.active = true
    cost_type.description = "Tipo de custo legal do sistema: #{type_data[:name]}"
    puts "  Created system type: #{cost_type.name}"
  end
end

puts "Created #{legal_cost_types.count} system legal cost types"