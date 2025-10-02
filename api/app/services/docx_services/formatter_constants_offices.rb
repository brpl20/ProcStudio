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
  end
end
