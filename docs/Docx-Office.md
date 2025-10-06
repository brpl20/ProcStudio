[Back](../README.md)

# Docx Office

## Organizar Informações do Escritório

O `FormatterOffices` é responsável por extrair e formatar informações específicas de um escritório (`Office`) e suas relações com os advogados. Este formatter **NÃO** é para extrair qualificação, nome e outros atributos que estão concentrados no `formatter_qualification`.

- **Arquivo**: `app/services/docx_services/formatter_offices.rb`
- **Constantes**: `app/services/docx_services/formatter_constants_offices.rb`

### Uso Básico

```ruby
office = Office.find(1)
formatter = DocxServices::FormatterOffices.new(office)

# Ou usar o método factory
formatter = DocxServices::FormatterOffices.for(office)
```

## Métodos Disponíveis

### Informações do Escritório

```ruby
# Dados básicos
society                     # Retorna o tipo de sociedade formatado
accounting_type             # Retorna o tipo de contabilidade formatado
oab_status                  # Retorna o status da OAB formatado
oab_id                      # Retorna o ID da OAB formatado
oab_inscricao              # Retorna a inscrição da OAB

# Valores financeiros
quote_value(extenso: false) # Retorna o valor da cota formatado, opcionalmente por extenso
number_of_quotes(extenso: false) # Retorna o número de cotas formatado, opcionalmente por extenso
```

**Exemplos:**
```ruby
formatter.society           # => "Sociedade"
formatter.accounting_type   # => "Simples Nacional"
formatter.oab_status        # => "Ativo"
formatter.quote_value       # => "R$ 175,00"
formatter.quote_value(extenso: true)  # => "R$ 175,00 (cento e setenta e cinco reais)"
```

### Relacionamento com Advogados

```ruby
# Informações individuais por advogado
partnership_type(lawyer_number)       # Retorna o tipo de sociedade do advogado especificado
partnership_percentage(lawyer_number) # Retorna a porcentagem de participação do advogado
is_administrator(lawyer_number)       # Retorna se o advogado é administrador

# Informações gerais
partners_count                        # Retorna o número total de sócios
partners_info                         # Retorna informações completas de todos os sócios
```

**Exemplos:**
```ruby
formatter.partnership_type(1)        # => "Sócio"
formatter.partnership_percentage(1)  # => "55%"
formatter.is_administrator(1)        # => true
formatter.partners_count             # => 2
```

### Configurações de Distribuição Proporcional

```ruby
# Verifica se o escritório usa distribuição proporcional
is_proportional                      # Retorna true/false se o escritório tem distribuição proporcional ativada
```

**Exemplo:**
```ruby
formatter.is_proportional           # => true ou false
```

### Informações Completas dos Sócios

O método `partners_info` retorna um array com informações detalhadas de todos os sócios, incluindo cálculos de participação financeira:

```ruby
formatter.partners_info
# => [
#   {
#     number: 1,
#     partnership_type: "Sócio",
#     partnership_percentage: "55%",
#     is_administrator: true,
#     partner_quote_value: 96.25,          # nil se proportional = false
#     partner_quote_value_formatted: "R$ 96,25", # nil se proportional = false
#     partner_number_of_quotes: 13.75,     # nil se proportional = false
#     partner_number_of_quotes_formatted: "13,75" # nil se proportional = false
#   },
#   {
#     number: 2,
#     partnership_type: "Sócio",
#     partnership_percentage: "45%",
#     is_administrator: false,
#     partner_quote_value: 78.75,
#     partner_quote_value_formatted: "R$ 78,75",
#     partner_number_of_quotes: 11.25,
#     partner_number_of_quotes_formatted: "11,25"
#   }
# ]
```

### Informações de Remuneração dos Sócios

O método `partners_compensation` retorna informações detalhadas sobre a remuneração de todos os sócios:

```ruby
formatter.partners_compensation
# => [
#   {
#     number: 1,
#     lawyer_name: "JOÃO AUGUSTO PRADO",
#     partnership_type: "Sócio",
#     partnership_percentage: "100%",
#     is_administrator: true,
#     compensation_type: "pro_labore",        # ou "salary" ou nil
#     compensation_amount: 5000.0,
#     compensation_amount_formatted: "R$ 5.000,00",
#     payment_frequency: "monthly",
#     effective_date: "2024-01-01",
#     end_date: nil,
#     notes: "Valor fixado em assembleia",
#     all_compensations: [                    # Histórico completo
#       {
#         type: "pro_labore",
#         amount: 5000.0,
#         amount_formatted: "R$ 5.000,00",
#         frequency: "monthly",
#         effective_date: "2024-01-01",
#         end_date: nil,
#         notes: "Valor fixado em assembleia"
#       }
#     ]
#   }
# ]
```

### Subscrição de Sócios (Para Contratos Sociais)

```ruby
# Subscrição individual de um sócio
partner_subscription(lawyer_number)  # Retorna o texto completo de subscrição do sócio

# Subscrição de todos os sócios
all_partners_subscription            # Retorna o texto de subscrição de todos os sócios
```

**Exemplo de Subscrição:**
```ruby
formatter.partner_subscription(1)
# => "O sócio RICARDO COSTA, subscreve e integraliza neste ato 13,75 (treze vírgula setenta e cinco) quotas no valor de R$ 7,00 (sete reais) cada uma, perfazendo o total de R$ 96,25 (noventa e seis reais e vinte e cinco centavos)"

formatter.all_partners_subscription
# => "O sócio RICARDO COSTA, subscreve e integraliza neste ato 13,75 (treze vírgula setenta e cinco) quotas no valor de R$ 7,00 (sete reais) cada uma, perfazendo o total de R$ 96,25 (noventa e seis reais e vinte e cinco centavos); A sócia AMANDA RODRIGUES, subscreve e integraliza neste ato 11,25 (onze vírgula vinte e cinco) quotas no valor de R$ 7,00 (sete reais) cada uma, perfazendo o total de R$ 78,75 (setenta e oito reais e setenta e cinco centavos)"
```

#### Características da Subscrição

- **Suporte a Gênero**: O texto adapta automaticamente entre "O sócio"/"A sócia", "O associado"/"A associada"
- **Formatação Brasileira**: Números com vírgula para decimais (13,75) e pontos para milhares
- **Extenso em Minúsculas**: Todos os valores por extenso em letras minúsculas
- **Cálculos Automáticos**: Valores calculados automaticamente baseados na porcentagem de participação

## Geração de Contratos Sociais

### SocialContractServiceSociety

O `SocialContractServiceSociety` é responsável por gerar contratos sociais em formato DOCX baseado em um template, substituindo placeholders com informações do escritório e sócios.

- **Arquivo**: `app/services/docx_services/social_contract_service_society.rb`
- **Template**: `app/services/docx_services/templates/CS-TEMPLATE.docx`

#### Uso Básico

```ruby
# Criar e gerar contrato social
service = DocxServices::SocialContractServiceSociety.new(office_id)
file_path = service.call

# O arquivo será salvo em:
# app/services/docx_services/output/cs-{office-name-parameterized}.docx
```

#### Placeholders Suportados

**Informações do Escritório:**
- `_office_name_` - Nome do escritório
- `_office_state_` - Estado do escritório
- `_office_city_` - Cidade do escritório
- `_office_address_` - Endereço completo
- `_office_zip_code_` - CEP
- `_office_total_value_` - Valor total das cotas
- `_office_quotes_` - Número total de cotas
- `_office_quote_value_` - Valor individual da cota
- `_office_society_type_` - Tipo de sociedade
- `_office_accounting_type_` - Tipo de enquadramento contábil

**Informações dos Sócios:**
- `_partner_qualification_` - Qualificação de todos os sócios
- `_partner_subscription_` - Subscrição de todos os sócios
- `_partner_full_name_{n}_` - Nome completo do sócio (numerado)
- `_partner_total_quotes_{n}_` - Total de cotas do sócio
- `_partner_sum_{n}_` - Valor total das cotas do sócio
- `_%_{n}_` - Porcentagem de participação do sócio
- `_total_quotes_` - Total geral de cotas

**Administração:**
- `_partner_full_name_administrator_` - Nome(s) do(s) administrador(es) com prefixo adequado

**Distribuição Proporcional (condicional baseada em `office.proportional`):**
- `_dividends_` - "Parágrafo Terceiro:" (se proportional = true)
- `_dividends_text_` - Texto sobre distribuição proporcional de lucros (se proportional = true)

**Pró-labore (condicional baseada em compensações dos sócios):**
- `_pro_labore_` - "Parágrafo Sétimo:" (se algum sócio tem compensation_type = 'pro_labore')
- `_pro_labore_text_` - Texto sobre retirada de pró-labore (se condição atendida)

**Datas:**
- `_current_date_` - Data atual em formato longo brasileiro
- `_date_` - Data atual em formato longo brasileiro

#### Lógica de Substituição Condicional

**Distribuição Proporcional:**
```ruby
# Se office.proportional == true:
_dividends_ → "Parágrafo Terceiro:"
_dividends_text_ → "Os eventuais lucros serão distribuídos entre os sócios proporcionalmente às contribuições de cada um para o resultado."

# Se office.proportional == false:
_dividends_ → "" (removido)
_dividends_text_ → "" (removido)
```

**Pró-labore:**
```ruby
# Se qualquer sócio tem compensation_type == 'pro_labore':
_pro_labore_ → "Parágrafo Sétimo:"
_pro_labore_text_ → "Pelo exercício da administração terão os sócios administradores direito a uma retirada mensal a título de \"pró-labore\", cujo valor será fixado em comum acordo entre os sócios e levado à conta de Despesas Gerais da Sociedade."

# Se nenhum sócio tem pro_labore:
_pro_labore_ → "" (removido)
_pro_labore_text_ → "" (removido)
```

**Administradores:**
```ruby
# Um administrador:
_partner_full_name_administrator_ → "pelo sócio JOÃO SILVA" ou "pela sócia MARIA SILVA"

# Múltiplos administradores (todos femininos):
_partner_full_name_administrator_ → "pelas sócias MARIA SILVA e ANA COSTA"

# Múltiplos administradores (mistos ou masculinos):
_partner_full_name_administrator_ → "pelos sócios JOÃO SILVA e MARIA COSTA"
```

#### Processamento do Template

O serviço executa 6 etapas principais:

1. **STEP 1**: Inserção de linhas para múltiplos sócios na tabela
2. **STEP 2**: Inserção de linhas para assinaturas (se > 2 sócios)
3. **STEP 3**: Substituição de placeholders gerais no documento
4. **STEP 4**: Substituição de placeholders de tabelas gerais
5. **STEP 5**: Substituição de placeholders numerados dos sócios
6. **STEP 6**: Substituição de placeholders de assinaturas

## Constantes Utilizadas

As constantes são definidas em `formatter_constants_offices.rb`:

```ruby
SOCIETY                           # Tipos de sociedade
ACCOUNTING_TYPE                   # Tipos de contabilidade
OAB_STATUS                       # Status da OAB
PARTNERSHIP_TYPE                 # Tipos de participação societária
PARTNERSHIP_SUBSCRIPTION_PREFIXES # Prefixos com suporte a gênero para subscrição
SUBSCRIPTION_TEMPLATE            # Template base para subscrição
QUOTES_TEXT                      # Texto padrão para quotas
EACH_ONE_TEXT                    # Texto padrão para finalização

# Constantes para distribuição proporcional
DIVIDENDS_TITLE                  # "Parágrafo Terceiro:"
DIVIDENDS_TEXT                   # Texto sobre distribuição proporcional

# Constantes para pró-labore
PRO_LABORE_TITLE                 # "Parágrafo Sétimo:"
PRO_LABORE_TEXT                  # Texto sobre pró-labore

# Constantes para administradores
ADMINISTRATOR_PREFIXES           # Prefixos com suporte a gênero para administradores
```

## Notas Importantes

1. **Numeração dos Advogados**: Os métodos que recebem `lawyer_number` esperam números iniciados em 1 (não zero)
2. **Distribuição Proporcional**: Os cálculos de cotas por sócio só são exibidos quando `office.proportional = true`
3. **Formatação Monetária**: Todos os valores monetários seguem o padrão brasileiro
4. **Extenso Aprimorado**: O sistema suporta números decimais por extenso (ex: "treze vírgula setenta e cinco")
5. **Compensações**: O modelo de compensação foi atualizado - apenas 'pro_labore' e 'salary' são suportados
6. **Geração Condicional**: Seções do contrato social são incluídas/excluídas automaticamente baseadas nas configurações do escritório e compensações dos sócios
7. **Suporte a Gênero**: Todos os textos gerados respeitam o gênero dos sócios (masculino/feminino)

## Método Factory

```ruby
FormatterOffices.for(entity)         # Método factory para criar uma instância
```
