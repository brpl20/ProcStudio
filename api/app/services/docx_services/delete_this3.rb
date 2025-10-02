    PARTNER_ROLES = {
      socio: 'socio',
      associado: 'associado',
      socio_de_servico: 'socio_de_servico'
    }.freeze
    
    
    
    
    SUBSCRIPTION_TEXT = {
      single: 'O Sócio %<name>s, subscreve e integraliza neste ato %<quotes>s quotas ' \
              'no valor de R$ %<value>s,00 cada uma, perfazendo o total de R$ %<total>s',
      multiple: 'O Sócio %<name>s, subscreve e integraliza neste ato %<quotes>s quotas ' \
                'no valor de R$ %<value>s,00 cada uma, perfazendo o total de R$ %<total>s;'
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