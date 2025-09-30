# frozen_string_literal: true

module DocxServices
  module FormatterConstants
    DOCUMENT_PREFIXES = {
      cpf: {
        male: 'inscrito no CPF sob o nº',
        female: 'inscrita no CPF sob o nº'
      },
      cnpj: {
        company: 'inscrita no CNPJ sob o nº'
      },
      rg: {
        male: 'RG nº',
        female: 'RG nº'
      },
      oab: {
        male: 'inscrito na OAB sob o nº',
        female: 'inscrita na OAB sob o nº'
      },
      nb: {
        default: 'NB: '
      },
      nit: {
        default: 'NIT:'
      },
      email: {
        default: 'com endereço eletrônico:'
      },
      phone: {
        default: 'com telefone:'
      },
      mother_name: {
        male: 'filho de',
        female: 'filha de'
      },
      bank: {
        default: 'Dados Bancários:'
      }
    }.freeze

    ADDRESS_PREFIXES = {
      person: {
        male: 'residente e domiciliado',
        female: 'residente e domiciliada',
        lawyer: 'com endereço profissional à'
      },
      company: {
        default: 'com sede à'
      }
    }.freeze

    CIVIL_STATUS = {
      male: {
        single: 'solteiro',
        married: 'casado',
        divorced: 'divorciado',
        widower: 'viúvo',
        union: 'união estável'
      },
      female: {
        single: 'solteira',
        married: 'casada',
        divorced: 'divorciada',
        widower: 'viúva',
        union: 'união estável'
      }
    }.freeze

    NATIONALITY = {
      male: {
        brazilian: 'brasileiro',
        foreigner: 'estrangeiro'
      },
      female: {
        brazilian: 'brasileira',
        foreigner: 'estrangeira'
      }
    }.freeze

    ROLE_TO_PROFESSION = {
      male: {
        lawyer: 'advogado',
        secretary: 'secretário',
        paralegal: 'paralegal',
        intern: 'estagiário'
      },
      female: {
        lawyer: 'advogada',
        secretary: 'secretária',
        paralegal: 'paralegal',
        intern: 'estagiária'
      }
    }.freeze

    # Office and Partnership constants
    SUBSCRIPTION_TEXT = {
      single: 'O Sócio %<name>s, subscreve e integraliza neste ato %<quotes>s quotas ' \
              'no valor de R$ %<value>s,00 cada uma, perfazendo o total de R$ %<total>s',
      multiple: 'O Sócio %<name>s, subscreve e integraliza neste ato %<quotes>s quotas ' \
                'no valor de R$ %<value>s,00 cada uma, perfazendo o total de R$ %<total>s;'
    }.freeze

    PARTNER_ROLES = {
      administrator: 'Sócio Administrador',
      partner: 'Sócio'
    }.freeze

    ROLE_IDENTIFIERS = {
      administrator: 'administrator',
      admin_field: 'is_admin'
    }.freeze

    PRO_LABORE = {
      default_text: 'Pelo exercício da administração terão os sócios administradores direito a uma retirada mensal ' \
                    'a título de "pró-labore", cujo valor será fixado em comum acordo entre os sócios e levado à ' \
                    'conta de Despesas Gerais da Sociedade.',
      enabled_by_default: true
    }.freeze

    DIVIDENDS = {
      default_text: 'Os sócios receberão dividendos proporcionais às suas respectivas participações no capital social.',
      enabled_by_default: true
    }.freeze

    OFFICE_DEFAULTS = {
      total_quotes: 10_000,
      total_capital_value: 10_000,
      percentage_format: '%<value>s%',
      full_percentage: '100%'
    }.freeze

    FORMATTING = {
      currency_separator: '.',
      currency_decimal: ',00',
      thousands_separator: '.'
    }.freeze

    SEPARATORS = {
      partner_lines: "\n\n"
    }.freeze

    ACCOUNT_TYPES = {
      checking: 'Conta Corrente',
      savings: 'Conta Poupança',
      default: 'Conta'
    }.freeze

    CAPACITY_PREFIXES = {
      unable: {
        person: 'representado por',
        company: 'representada por'
      },
      relatively: {
        person: 'assistido por',
        company: 'assistida por'
      }
    }.freeze

    COMPANY_REPRESENTATION = {
      single_admin: 'seu sócio administrador',
      multiple_admins: 'seus sócios administradores'
    }.freeze

    ADDRESS_COMBINATION = {
      both: 'ambos',
      all: 'todos'
    }.freeze
  end
end
