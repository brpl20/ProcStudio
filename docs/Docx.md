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
f.qualify
f.email
f.street
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

Os campos padrões `cpf, rg, oab` também podem ser desabilitados;

```ruby
include_cpf: false
include_rg: false
include_oab: false
```

Isso pode acontecer por exemplo na qualificação de um advogado no contrato, em que só é necessário a sua oab:

`... advogado, inscrito na OAB/PR 54.159 ...`
