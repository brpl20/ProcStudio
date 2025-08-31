# frozen_string_literal: true

# Script de teste para demonstrar o fluxo de custos legais
# NÃO EXECUTAR EM PRODUÇÃO - APENAS EXEMPLO

# 1. Primeiro, encontrar o Work
work = Work.find(35)
puts "Work ##{work.id}: #{work.folder}"

# 2. Verificar se tem honorary global
if work.global_honorary
  honorary = work.global_honorary
  puts "Honorary encontrado: #{honorary.name}"

  # 3. Verificar se o honorary tem legal_cost (criar se não tiver)
  legal_cost = honorary.legal_cost || honorary.create_legal_cost!(
    client_responsible: true,
    include_in_invoices: true,
    admin_fee_percentage: 10.0
  )
  puts "LegalCost ID: #{legal_cost.id}"

  # 4. Agora você pode adicionar entries ao legal_cost
  # Método 1: Usando o método helper
  legal_cost.add_entry(
    'custas_judiciais',
    'Custas iniciais do processo',
    850.00,
    estimated: false,
    due_date: 30.days.from_now,
    description: 'Pagamento das custas iniciais para protocolo'
  )

  # Método 2: Criando diretamente
  legal_cost.entries.create!(
    legal_cost_type_id: LegalCostType.find_by(key: 'taxa_judiciaria').id,
    name: 'Taxa judiciária estadual',
    amount: 450.00,
    estimated: false,
    due_date: 15.days.from_now,
    description: 'Taxa obrigatória do TJPR'
  )

  puts "Entries criadas: #{legal_cost.entries.count}"
  puts "Total de custos: R$ #{legal_cost.total_amount}"
end

# Para listar todos os custos de um Work:
work.honoraries.each do |honorary|
  next unless honorary.legal_cost

  puts "\nHonorary: #{honorary.name}"
  puts 'Custos legais:'

  honorary.legal_cost_entries.each do |entry|
    puts "  - #{entry.name}: R$ #{entry.amount} (#{entry.paid? ? 'PAGO' : 'PENDENTE'})"
  end
end
