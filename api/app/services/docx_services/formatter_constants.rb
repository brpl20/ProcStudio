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
        male: 'portador da cédula de identidade RG nº',
        female: 'portadora da cédula de identidade RG nº'
      },
      oab: {
        male: 'inscrito na OAB sob o nº',
        female: 'inscrita na OAB sob o nº'
      },
      nb: {
        default: 'número do benefício'
      },
      nit: {
        default: 'número de inscrição do trabalhador'
      },
      email: {
        default: 'com endereço eletrônico:'
      },
      phone: {
        default: 'com telefone:'
      }
    }.freeze

    ADDRESS_PREFIXES = {
      person: {
        male: 'residente e domiciliado',
        female: 'residente e domiciliada'
      },
      company: {
        default: 'com sede à'
      }
    }.freeze

    # Office and Partnership constants
    SUBSCRIPTION_TEXT = {
      single: 'O Sócio %{name}, subscreve e integraliza neste ato %{quotes} quotas ' \
              'no valor de R$ %{value},00 cada uma, perfazendo o total de R$ %{total}',
      multiple: 'O Sócio %{name}, subscreve e integraliza neste ato %{quotes} quotas ' \
                'no valor de R$ %{value},00 cada uma, perfazendo o total de R$ %{total};'
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
      percentage_format: '%{value}%',
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
  end
end
