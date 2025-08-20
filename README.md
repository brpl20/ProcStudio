# Backend - PRC API

API RESTful desenvolvida em Ruby on Rails para o sistema PRC.

## 🚀 Início Rápido

### Requisitos
- Ruby 3.2.7
- Rails 8.0.2.1
- PostgreSQL
- Redis (para cache e jobs)

### Configuração

```bash
# Instalar dependências
bundle install

# Configurar banco de dados
rails db:create
rails db:migrate
rails db:seed

# Iniciar servidor
rails server

# Executar testes
rspec
```

## 📋 Padrões de Código e Boas Práticas

### Configuração de Qualidade de Código

Este projeto utiliza RuboCop para garantir qualidade e consistência do código Ruby/Rails.

#### Scripts Disponíveis

```bash
bin/lint              # Verifica erros de lint
bin/lint-fix          # Corrige erros automaticamente
bundle exec rubocop   # RuboCop completo
bundle exec rubocop -A # RuboCop com auto-correção
```

### Regras de Estilo de Código

#### 1. **Formatação Geral**
- **Indentação**: 2 espaços (não usar tabs)
- **Aspas**: Sempre usar aspas simples (`'`) exceto em strings com interpolação
- **Comprimento de linha**: Máximo 120 caracteres
- **Frozen string literals**: Sempre incluir `# frozen_string_literal: true`
- **Hash syntax**: Usar sintaxe Ruby 1.9+ (`:key =>` vira `key:`)
- **Vírgulas finais**: Não usar vírgulas no último item de arrays/hashes

#### 2. **Ruby Style**
- **Arrays de símbolos**: Usar `[:symbol1, :symbol2]` ao invés de `%i[symbol1 symbol2]` para arrays pequenos
- **Condicionais**: Sempre usar chaves mesmo para uma linha
- **Guard clauses**: Preferir `return unless` no início dos métodos
- **Operadores**: Usar `&&`/`||` ao invés de `and`/`or` exceto para controle de fluxo
- **Return explícito**: Evitar `return` desnecessário no final de métodos

#### 3. **Rails Específico**
- **Validações**: Não usar validação explícita de `presence` para `belongs_to` (Rails já faz automaticamente)
- **Enums**: Usar sintaxe posicional ao invés de keyword arguments
- **Timezone**: Usar `Time.zone.now` ou `Time.current` ao invés de `Time.now`
- **Queries**: Evitar `update_all` quando validações são necessárias
- **File paths**: Usar `Rails.root.join('path', 'to', 'file')` ao invés de strings
- **JSON parsing**: Usar `response.parsed_body` ao invés de `JSON.parse(response.body)` em testes

#### 4. **Naming Conventions**
- **Variáveis e métodos**: `snake_case`
- **Classes e módulos**: `PascalCase`
- **Constantes**: `SCREAMING_SNAKE_CASE`
- **Predicados**: Evitar prefixo `is_` (usar `active?` ao invés de `is_active?`)

#### 5. **Métricas de Qualidade**
- **Métodos**: Máximo 20 linhas
- **Classes**: Máximo 200 linhas
- **Complexidade ciclomática**: Máximo 10
- **Parâmetros**: Máximo 5 por método
- **Blocos**: Máximo 25 linhas

### Exemplos de Código

#### ✅ Correto
```ruby
# frozen_string_literal: true

class UserService
  MAX_RETRIES = 3
  
  def initialize(user)
    @user = user
  end
  
  def process_user
    return false unless @user.valid?
    
    if @user.premium?
      process_premium_user
    else
      process_regular_user
    end
  end
  
  private
  
  def process_premium_user
    # Método pequeno e focado
    @user.update(status: 'premium_processed')
  end
  
  # Enum com sintaxe posicional
  enum status: ['pending', 'active', 'suspended']
  
  # Validações sem presence redundante para belongs_to
  belongs_to :team
  validates :name, presence: true
  
  # Timezone correto
  scope :recent, -> { where(created_at: Time.current..1.day.ago) }
end
```

#### ❌ Evitar
```ruby
# Sem frozen string literal
class UserService
  def initialize(user)
    @user = user
  end
  
  # Método muito longo (>20 linhas)
  def process_user
    if @user.present?
      if @user.premium?
        # Lógica complexa aqui...
      else
        # Mais lógica...
      end
    else
      return false
    end
    # Muito código...
  end
  
  # Enum com keyword arguments (deprecado)
  enum status: { pending: 0, active: 1 }
  
  # Validação redundante
  belongs_to :team
  validates :team, presence: true  # ❌ Redundante
  
  # Timezone incorreto
  scope :recent, -> { where(created_at: Time.now..1.day.ago) } # ❌ Usar Time.current
end
```

### Estrutura de Diretórios

```
app/
├── controllers/
│   └── api/v1/         # Controllers da API versionada
├── models/             # Modelos ActiveRecord
├── services/           # Lógica de negócio
├── policies/           # Autorização (Pundit)
├── serializers/        # Serialização JSON
└── jobs/              # Background jobs

spec/
├── controllers/        # Testes de controllers
├── models/            # Testes de modelos
├── services/          # Testes de services
├── factories/         # FactoryBot factories
└── support/           # Helpers de teste

config/
├── routes.rb          # Rotas da aplicação
├── database.yml       # Configuração do banco
└── environments/      # Configurações por ambiente
```

### Git Hooks

O projeto utiliza Husky para executar verificações antes dos commits:

1. **Pre-commit para Ruby**: Executa automaticamente:
   - RuboCop com auto-fix em arquivos `.rb` e `.rake` modificados
   - Re-adiciona arquivos corrigidos automaticamente
   - Bloqueia o commit se houver erros que não podem ser corrigidos

### Boas Práticas de Desenvolvimento

#### 1. **Controllers**
- Manter métodos pequenos (máximo 10 linhas)
- Usar `before_action` para código comum
- Retornar JSON consistente com status HTTP apropriados
- Usar strong parameters sempre

#### 2. **Models**
- Validações claras e específicas
- Usar scopes para queries complexas
- Callbacks apenas quando necessário
- Relacionamentos bem definidos com `dependent:` apropriado

#### 3. **Services**
- Uma responsabilidade por service
- Retornar objetos consistentes (success/error)
- Tratamento adequado de exceções
- Métodos pequenos e focados

#### 4. **Testes**
- Usar FactoryBot para dados de teste
- Testes unitários para modelos e services
- Testes de integração para controllers
- Coverage mínimo de 80%

#### 5. **Segurança**
- Nunca commitar credenciais
- Usar variáveis de ambiente para configurações
- Validar e sanitizar inputs
- Usar Pundit para autorização

#### 6. **Performance**
- Evitar N+1 queries (usar `includes`)
- Indexar colunas de busca frequente
- Usar cache quando apropriado
- Background jobs para operações lentas

#### 

### Padrões de API

```ruby
# Resposta de sucesso
{
  "success": true,
  "data": { ... },
  "message": "Optional success message"
}
```

```ruby
# Resposta de erro
{
  "success": false,
  "message": "Email já está em uso",  # Single user-friendly message
  "errors": ["Email já está em uso"]   # Array for detailed errors
}
```

### Ambientes

- **Development**: Configuração local com logs verbosos
- **Test**: Ambiente para execução de testes
- **Staging**: Ambiente de pré-produção
- **Production**: Ambiente de produção

### Deployment

O projeto usa Mina para deployment automatizado:

```bash
# Deploy para staging
mina deploy

# Deploy para production
mina production deploy
```

### Monitoramento

- Logs estruturados com Rails.logger
- Métricas de performance com New Relic (quando configurado)
- Health check endpoint: `/health`

### Troubleshooting

#### Problemas Comuns

1. **RuboCop falhando**: Execute `bundle exec rubocop -A` para auto-correção
2. **Testes falhando**: Verifique se o banco de teste está limpo com `rails db:test:prepare`
3. **Performance lenta**: Analise N+1 queries com `bullet` gem

#### Comandos Úteis

```bash
# Regenerar RuboCop TODO
bundle exec rubocop --auto-gen-config

# Rodar apenas testes modificados
bundle exec rspec --only-failures

# Limpar logs
rails log:clear

# Verificar rotas
rails routes
```
