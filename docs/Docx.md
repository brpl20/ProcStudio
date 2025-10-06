[Back](../README.md)

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

Para isso nós temos um método genérico que servirá para todos os `Model` que tiverem informações pessoais, como nome, cpf, rg, email, telefone.

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

É recomendado utilizar o módulo de internacionalização do Ruby para isso. Mas como não iremos trabalhar com clientes fora do Brasil vamos utilizar o nosso método direto com constantes pelo menos por enquatno.

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

#### Métodos de Estado

O método `state` foi aprimorado para oferecer maior flexibilidade na formatação dos estados brasileiros:

```ruby
# Formato padrão - retorna a sigla
instance.state                         # => "PR"

# Com nome completo por extenso
instance.state(extenso: true)          # => "Paraná"

# Com preposição + nome completo
instance.state(prefix: true, extenso: true)  # => "do Paraná"

# Com preposição + sigla
instance.state(prefix: true)           # => "do PR"
```

**Exemplos por estado:**
- PR: "do Paraná", "do PR"
- SC: "de Santa Catarina", "de SC"
- RJ: "do Rio de Janeiro", "do RJ"
- SP: "de São Paulo", "de SP"
- MG: "de Minas Gerais", "de MG"
- BA: "da Bahia", "da BA"

O sistema utiliza automaticamente as preposições corretas ("do", "de", "da") conforme as regras gramaticais do português brasileiro.

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

#### Capacidade Civil e Representação Legal

A partir da versão atual, o sistema suporta automaticamente o tratamento da capacidade civil e representação legal para pessoas físicas, seguindo as normas do Código Civil brasileiro. O sistema identifica a capacidade através do campo `capacity` do modelo `ProfileCustomer` e formata a qualificação de acordo com as regras jurídicas.

##### Tipos de Capacidade

O sistema reconhece três tipos de capacidade civil:

- **able**: Pessoa plenamente capaz (não requer representação)
- **relatively**: Pessoa relativamente incapaz (requer assistência)
- **unable**: Pessoa absolutamente incapaz (requer representação)

##### Estrutura da Qualificação com Capacidade

Para pessoas com capacidade limitada, a qualificação segue a seguinte estrutura:

1. **Dados pessoais completos** da pessoa (nome, nacionalidade, estado civil, profissão, documentos, endereço)
2. **Termo de capacidade** ("relativamente incapaz" ou "absolutamente incapaz")
3. **Representação legal** ("assistido por" ou "representado por" + qualificação completa do representante)

##### Representação e Assistência

O sistema diferencia automaticamente entre assistência e representação:

- **Relativamente incapazes**: utiliza "**assistido por**" + qualificação do assistente
- **Absolutamente incapazes**: utiliza "**representado por**" + qualificação do representante

##### Exemplos de Qualificação com Capacidade

1. **Pessoa relativamente incapaz**:
```ruby
# ProfileCustomer com capacity: 'relatively' e representante cadastrado
f.qualification
=> "PEDRO SILVA JUNIOR, brasileiro, solteiro, estudante, inscrito no CPF sob o nº 111.222.333-96, RG nº 9876543, residente e domiciliado Rua São Paulo, nº 456, Apto 202, Centro, Cascavel - PR, CEP 85810-030, relativamente incapaz, assistido por CARLOS OLIVEIRA SANTOS, brasileiro, casado, empresário, inscrito no CPF sob o nº 123.456.789-09, RG nº 1234567, residente e domiciliado Rua Brasil, nº 123, Apto 202, Centro, Cascavel - PR, CEP 85810-030"
```

2. **Pessoa absolutamente incapaz**:
```ruby
# ProfileCustomer com capacity: 'unable' e representante cadastrado
f.qualification
=> "PAULO DA SILVA, brasileiro, casado, empresário, inscrito no CPF sob o nº 999.888.777-66, RG nº 1111111, residente e domiciliado Rua Alexandre de Gusmão, nº 100, Centro, São Paulo - SP, CEP 01000-000, absolutamente incapaz, representado por MARIA DA SILVA, brasileira, viúva, doméstica, inscrita no CPF sob o nº 555.444.333-22, RG nº 2222222, residente e domiciliada Rua das Flores, nº 200, Centro, São Paulo - SP, CEP 01001-000"
```

##### Endereços Compartilhados

Quando a pessoa incapaz e seu representante/assistente possuem o mesmo endereço, o sistema automaticamente detecta essa situação e formata a qualificação com as expressões "ambos" (para 2 pessoas) ou "todos" (para mais de 2 pessoas):

```ruby
# Mesmo endereço entre representado e representante
f.qualification
=> "PAULO DA SILVA, brasileiro, casado, empresário, inscrito no CPF sob o nº 999.888.777-66, RG nº 1111111, absolutamente incapaz, representado por MARIA DA SILVA, brasileira, viúva, doméstica, inscrita no CPF sob o nº 555.444.333-22, RG nº 2222222, ambos com endereço à Rua Alexandre de Gusmão, nº 100, Centro, São Paulo - SP, CEP 01000-000"
```

##### Múltiplos Representantes

O sistema também suporta múltiplos representantes para uma mesma pessoa incapaz:

```ruby
# ProfileCustomer com múltiplos representantes
f.qualification
=> "JOÃO DA SILVA, brasileiro, solteiro, absolutamente incapaz, representado por MARIA DA SILVA, brasileira, viúva, doméstica, inscrita no CPF sob o nº 111.111.111-11, RG nº 1111111, residente e domiciliada Rua A, nº 100 e CARLOS DA SILVA, brasileiro, casado, empresário, inscrito no CPF sob o nº 222.222.222-22, RG nº 2222222, residente e domiciliado Rua B, nº 200"
```

##### Associações Necessárias

Para o funcionamento correto da representação, é necessário que o modelo `ProfileCustomer` tenha os seguintes relacionamentos configurados:

- `has_many :representors` ou `has_many :active_representors`
- Relacionamento através da tabela `represents`

O sistema automaticamente detecta e extrai os dados dos representantes através dessas associações.

##### Notas Importantes

- A qualificação **sempre inclui** os dados da capacidade quando aplicável, sem necessidade de parâmetros adicionais
- O sistema **não duplica informações** quando endereços são iguais
- A **ordem da qualificação** segue rigorosamente as normas jurídicas brasileiras
- Todos os **documentos dos representantes** são incluídos automaticamente (CPF, RG, etc.)

#### MultiQualificação

Quando temos mais de um cliente precisaremos trabalhar qual a "multiqualificação" ou seja: Bruno, João e Paulo... por exemplo. Não temos uma forma automatizada de fazer isso ainda, então o caminho seria mais ou menos isso após a instância: ``x + ", " + y'`.

### Organizar a Informação => Modelos Específicos

Depois de organizar a primeira informação, você vai passar para as partes específicas, por exemplo quando um `Contrato Social` for criado você precisará de informações do Office que não estão na qualificação. Quando você trabalhar com um `Contrato` você precisará de dados do Work, quando for trabalhar com petições precisará dos dados Judiciais e assim por diante:

- [Office](./Docx-Office.md)
- Work (TD)
