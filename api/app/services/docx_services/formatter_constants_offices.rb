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
  end
end
