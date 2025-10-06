# frozen_string_literal: true

module DocxServices
  module FormatterConstantsOffices
    SOCIETY = {
      individual: 'Individual',
      company: 'Sociedade'
    }.freeze

    ACCOUNTING_TYPE = {
      simple: 'Simples Nacional',
      presumed_profit: 'Lucro Presumido',
      real_profit: 'Lucro Real'
    }.freeze

    OAB_STATUS = {
      active: 'Ativo',
      inactive: 'Inativo'
    }.freeze

    PARTNERSHIP_TYPE = {
      socio: 'Sócio',
      associado: 'Associado',
      socio_de_servico: 'Sócio de Serviço'
    }.freeze

    PARTNERSHIP_SUBSCRIPTION_PREFIXES = {
      male: {
        socio: 'O sócio',
        associado: 'O associado',
        socio_de_servico: 'O sócio de serviço'
      },
      female: {
        socio: 'A sócia',
        associado: 'A associada',
        socio_de_servico: 'A sócia de serviço'
      }
    }.freeze

    SUBSCRIPTION_TEMPLATE = "subscreve e integraliza neste ato"
    QUOTES_TEXT = "quotas no valor de"
    EACH_ONE_TEXT = "cada uma, perfazendo o total de"
    
    # Dividend constants
    DIVIDENDS_TITLE = "Parágrafo Terceiro:"
    DIVIDENDS_TEXT = "Os eventuais lucros serão distribuídos entre os sócios proporcionalmente às contribuições de cada um para o resultado."
    
    # Pro labore constants
    PRO_LABORE_TITLE = "Parágrafo Sétimo:"
    PRO_LABORE_TEXT = 'Pelo exercício da administração terão os sócios administradores direito a uma retirada mensal a título de "pró-labore", cujo valor será fixado em comum acordo entre os sócios e levado à conta de Despesas Gerais da Sociedade.'
    
    # Administrator constants
    ADMINISTRATOR_PREFIXES = {
      single: {
        male: 'pelo sócio',
        female: 'pela sócia'
      },
      multiple: {
        all_female: 'pelas sócias',
        mixed_or_male: 'pelos sócios'
      }
    }.freeze
  end
end
