# frozen_string_literal: true

Rails.logger.debug '⚖️ Criando poderes base por procedimento...'

# ============================================================================
# 1. CRIAÇÃO DOS PODERES BASE (PROCEDIMENTOS)
# ============================================================================


# PODERES ADMINISTRATIVOS BASE
administrative_base_powers = [
  'representar',
  'peticionar',
  'solicitar',
  'assinar',
  'recorrer',
  'desistir',
  'dar ciência',
  'retirar',
  'requerer',
  'criar senhas e consultar dados de acesso',
  'copiar processos',
  'notificar',
  'cobrar'
]

administrative_base_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'administrative',
    is_base: true,
    law_area_id: nil,
    created_by_team_id: nil
  )
end

# PODERES JUDICIAIS BASE
judicial_base_powers = [
  'Foro em geral, contidos na cláusula ad judicia et extra',
  'representar órgãos públicos e privados',
  'receber citação',
  'confessar',
  'reconhecer a procedência do pedido',
  'transigir',
  'indicar e-mail para notificações',
  'firmar compromissos e acordos',
  'desistir do processo e incidentes',
  'renunciar ao direito o qual se funda a ação',
  'receber e dar quitação',
  'firmar declaração de imposto de renda',
  'assinar declaração de hipossuficiência econômica e termo de renúncia para fins de Juizado Especial',
  'renunciar valores superiores à Requisições de Pequeno Valor em Precatórios',
  'substabelecer com ou sem reserva de poderes'
]

judicial_base_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'judicial',
    is_base: true,
    law_area_id: nil,
    created_by_team_id: nil
  )
end

# PODERES EXTRAJUDICIAIS BASE
extrajudicial_base_powers = [
  'peticionar',
  'solicitar',
  'assinar',
  'recorrer',
  'desistir',
  'dar ciência',
  'retirar',
  'requerer',
  'criar senhas e consultar dados de acesso',
  'copiar processos',
  'notificar',
  'cobrar'
]

extrajudicial_base_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'extrajudicial',
    is_base: true,
    law_area_id: nil,
    created_by_team_id: nil
  )
end

# ============================================================================
# 4. PODERES ESPECÍFICOS POR ÁREA
# ============================================================================

Rails.logger.debug '🎯 Criando poderes específicos por área...'

# CIVIL - Poderes específicos
civil_powers = [
  'representar em ações de indenização por danos morais e materiais',
  'transigir em valores até R$ 40.000,00',
  'assinar declaração de união estável',
  'representar em ações possessórias'
]

civil_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'judicial',
    is_base: false,
    law_area: civil,
    created_by_team_id: nil
  )
end

# FAMÍLIA - Poderes específicos (herda de Civil + próprios)
familia_powers = [
  'representar em ação de divórcio consensual',
  'representar em ação de guarda unilateral',
  'representar em ação de alimentos',
  'assinar acordo de pensão alimentícia',
  'representar em ação de reconhecimento de paternidade'
]

familia_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'judicial',
    is_base: false,
    law_area: familia,
    created_by_team_id: nil
  )
end

# PREVIDENCIÁRIO - Poderes específicos
previdenciario_powers = [
  'acessar documentos resguardados pelo sigilo médico',
  'preencher e assinar autodeclaração rural',
  'buscar informações de titularidade de familiares falecidos',
  'firmar e declarar Imposto de Renda e Isenções',
  'acessar autos em segredo de justiça relativos a direitos sucessórios'
]

previdenciario_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'administrative',
    is_base: false,
    law_area: previdenciario,
    created_by_team_id: nil
  )
end

# APOSENTADORIA - Poderes específicos
aposentadoria_powers = [
  'requerer aposentadoria por tempo de contribuição',
  'requerer aposentadoria especial',
  'requerer aposentadoria por idade',
  'requerer revisão de aposentadoria'
]

aposentadoria_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'administrative',
    is_base: false,
    law_area: aposentadoria,
    created_by_team_id: nil
  )
end

# TRIBUTÁRIO - Poderes específicos
tributario_powers = [
  'negativas, protocolos, extratos de débitos',
  'parcelamentos, extrato e saldo de parcelamentos',
  'pedidos de ressarcimentos e restituições',
  'certidão negativa de débitos (CND)',
  'extrato de contribuições de funcionários domésticos'
]

tributario_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'administrative',
    is_base: false,
    law_area: tributario,
    created_by_team_id: nil
  )
end

# PIS/COFINS - Poderes específicos
pis_cofins_powers = [
  'acesso caixa postal',
  'downloads speds (contribuições)',
  'transmissão de declarações',
  'todas opções Restituição e Compensação (perdcomp)',
  'acessar Per/Dcomp Web'
]

pis_cofins_powers.each do |description|
  Power.find_or_create_by(
    description: description,
    category: 'administrative',
    is_base: false,
    law_area: pis_cofins,
    created_by_team_id: nil
  )
end

Rails.logger.debug '✅ Seeds criados com sucesso!'
Rails.logger.debug ''
Rails.logger.debug '📊 Resumo:'
Rails.logger.debug { "   - #{Power.count} poderes" }
Rails.logger.debug { "   - #{Power.base_powers.count} poderes base" }
Rails.logger.debug { "   - #{Power.specific_powers.count} poderes específicos" }
