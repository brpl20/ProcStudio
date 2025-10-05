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
#     partner_quote_value: 96.25,
#     partner_quote_value_formatted: "R$ 96,25",
#     partner_number_of_quotes: 13.75,
#     partner_number_of_quotes_formatted: "13,75"
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
```

## Notas Importantes

1. **Numeração dos Advogados**: Os métodos que recebem `lawyer_number` esperam números iniciados em 1 (não zero)
2. **Cálculos Automáticos**: Os valores de cotas por sócio são calculados automaticamente baseados na porcentagem
3. **Formatação Monetária**: Todos os valores monetários seguem o padrão brasileiro
4. **Extenso Aprimorado**: O sistema suporta números decimais por extenso (ex: "treze vírgula setenta e cinco")

## Método Factory

```ruby
FormatterOffices.for(entity)         # Método factory para criar uma instância
```
