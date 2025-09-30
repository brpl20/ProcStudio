# Docx Methods

## Gem Customizada
Utilizamos uma gem customizada para gerar documentos Word (.docx) derivada da gem: [docx](https://github.com/ruby-docx/docx).

Nosa gem está hospedada [aqui](https://github.com/brpl20/docx).

Nós teremos mais liberdade para trabalhar com a gem e criar métodos específicos para o nosso trabalho:

1. substitute_across_runs_with_block_regex: Esse método utiliza o parâmetro da gem original com o bloco e acrescenta um delimitador em REGEX para evitar o problema de substituições parciais em nomes de placeholders parecidos. Você também pode passar outro argumento em REGEX, atualmente o que passamos é: `(/(?<![_\w])________(?![_\w])/)
2. Debugar
3. Checar substituições

Para mais informações consulte a documentação da gem no respositório.

Para utilizar a gem no Ruby on Rails use: `gem 'docx-br', github: 'brpl20/docx'`

Para importar utilize: `require 'docx'`

## Passo a Passo

### Organizar a Informação

O primeiro passo para um substituição bem sucedida é organizar a informação que será substituída.

Para isso nós temos um método genérico que servirá para todos os Modelos que tiverem informações pessoais, como nome, cpf, rg, email, telefone.

Esse método inclui também empresas, então poderemos utilizar nos seguintes modelos:

```ruby
ProfileCustomer # pessoa física ou jurídica
UserProfile # Usuários do sistema, vamos utilizar muito para os advogados por exemplo
Office # Para gerar dados dos escritórios
```

O método também contatena os dados para endereços e criação da qualificação completa da pessoa ou empresa: `qualification`.

O arquivo de referência é `formatter_qualification.rb`

Para informações como gênero e strings que precisam ser organizadas as constantes foram salvas em `formatter_constants.rb`:

```ruby
"inscrito/inscrita na"
"portador/portador"
"brasileiro/brasileira"
```

É recomendado utilizar o módulo de internacionalização do Ruby para isso. Mas como não iremos trabalhar com clientes fora do Brasil vamos utilizar este método pelo menos por enquatno.

Recomendo fazer testes usando `rails console` antes de passar para a programação efetiva, assim você terá uma noção melhor de como funciona, para isso siga os seguintes passos:

1. Selecionar um CustomerProfile, UserProfile, Office:

`x = ProfileCustomer.last`

2. Chamar o método de formatação:

`f = DocxServices::FormatterQualification.new(x)`

3. Utilizar o método `qualify` para gerar a qualificação completa da pessoa ou empresa ou simplesmente checar dados como e-mail e telefone individualmente:

```
f.qualify -> Qualificação Completa
f.email -> Email
f.street -> Apenas rua
f.address -> Endereço completo
```

#### Qualificação
A qualificação talvez venha a ser um dos métodos mais utilizados na geração de documentos, é o método que vai englobar todos os dados relevantes para o advogado gerar o documento naquele exato momento.

Alguns dadosão são de certa forma padronizados, como nome, endereço, profissão, nacionalidade, cpf. Outros dados são mais específicos como nome da mãe, e-mail, telefone. Muitas vezes o telefone por examplo não precisa constar na procuração mas precisa constar em um contrato até por questões de proteção de dados do cliente. Então para esse tipo de campo específico foi criado um método: `include`

Assim, como base teremos:
- Nome Completo (full_name) ou somente Nome se for empresa
- Nacionalidade (nationality)
- Estado Civil (civil_status)
- Profissão (não tratado exceto se for User)
- CPF
- RG
- Endereço

No `include` temos:
- E-mail (email)
- Telefone (phone)
- Nome da Mãe (mother_name)
- Número de Benefício (number_benefit)
- NIT (nit)

```ruby
include_email: true
include_phone: true
include_mother_name: true
include_number_benefit: true
include_nit: true
```

Exemplos:
1. Sem Include:
```ruby
doc.qualification
=> "ESCRITÓRIO DE ADVOCACIA EXEMPLO, inscrita no CNPJ sob o nº 11.222.333/0001-81, com sede à Rua Exemplo, nº 123, Sala 456, Centro, São Paulo - SP, CEP 01234-567"
```

2. Com Include:
```ruby
doc.qualification(include_email: true)
=> "ESCRITÓRIO DE ADVOCACIA EXEMPLO, inscrita no CNPJ sob o nº 11.222.333/0001-81, com endereço eletrônico: contato@exemplo.com.br, com sede à Rua Exemplo, nº 123, Sala 456, Centro, São Paulo - SP, CEP 01234-567"
```

1. Com NIT:
```ruby
docpf.qualification(include_nit:true)
=> "JOHN DOE, brasileiro, solteiro, software engineer, inscrito no CPF sob o nº 058.802.539-96, RG nº 12.345.678-9, NIT: 134154124, residente e domiciliado Avenida Paulista, nº 1578, Bela Vista, São Paulo - SP, CEP 01310-100"
```

Os campos padrões `cpf, rg, oab` também podem ser desabilitados;

```ruby
include_cpf: false
include_rg: false
include_oab: false
```

Isso pode acontecer por exemplo na qualificação de um advogado no contrato, em que só é necessário a sua oab:

`... advogado, inscrito na OAB/PR 54.159 ...`

#### Dados Bancários e PIX

A partir da versão atual, o sistema também suporta a inclusão de dados bancários e informações de PIX na qualificação. Estes dados são extraídos automaticamente da associação polimórfica `bank_accounts` dos modelos.

Os campos bancários disponíveis incluem:
- Nome do Banco (bank_name)
- Agência (bank_agency) 
- Conta (bank_account)
- Operação (bank_operation)
- Tipo de Conta (definido automaticamente como "Conta Corrente", "Conta Poupança" ou "Conta")
- PIX (pix)

No `include` para dados bancários temos:
- Dados Bancários Completos (bank)
- PIX isolado (pix)

```ruby
include_bank: true    # Inclui todos os dados bancários
include_pix: true     # Inclui apenas o PIX
```

Exemplos:

1. Qualificação com dados bancários completos:
```ruby
f.qualification(include_bank: true)
=> "JOÃO SILVA SANTOS, brasileiro, solteiro, advogado, inscrito no CPF sob o nº 123.456.789-01, RG nº 1234567, inscrito na OAB sob o nº 123456, com endereço profissional à Rua das Flores, nº 123, Centro, São Paulo - SP, CEP 01234-567, Dados Bancários: Agência: 12345, Conta Corrente: 123456, Banco do Brasil, Operação: 001, PIX: joao.silva@email.com"
```

2. Qualificação apenas com PIX:
```ruby
f.qualification(include_pix: true)
=> "JOÃO SILVA SANTOS, brasileiro, solteiro, advogado, inscrito no CPF sob o nº 123.456.789-01, RG nº 1234567, inscrito na OAB sob o nº 123456, com endereço profissional à Rua das Flores, nº 123, Centro, São Paulo - SP, CEP 01234-567, PIX: joao.silva@email.com"
```

3. Métodos individuais para dados bancários:
```ruby
f.bank           # "Dados Bancários: Agência: 12345, Conta Corrente: 123456, Banco do Brasil, Operação: 001, PIX: joao.silva@email.com"
f.bank_name      # "Banco do Brasil"
f.bank_agency    # "12345"
f.bank_account   # "123456"
f.bank_operation # "001"
f.pix           # "PIX: joao.silva@email.com"
```

**Importante**: Quando `include_bank: true` é utilizado junto com `include_pix: true`, o PIX não será duplicado na qualificação, sendo exibido apenas dentro dos dados bancários completos.

#### Advogados e Endereço Profissional

O sistema detecta automaticamente quando uma pessoa é advogada através da presença do campo `oab`. Nestes casos, o prefixo do endereço é alterado automaticamente de "residente e domiciliado/a" para "com endereço profissional à", conforme as convenções jurídicas brasileiras.
