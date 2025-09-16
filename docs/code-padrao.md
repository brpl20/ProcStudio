[Voltar](../README.md)

# 📋 Padrões de Código e Boas Práticas - ProcStudio

## 🎯 Configuração de Qualidade de Código

Este projeto utiliza RuboCop para garantir qualidade e consistência do código Ruby/Rails, ESLint para JavaScript/TypeScript e Prettier para formatação.

## 🛠️ Scripts Disponíveis

### Backend (Ruby/Rails)

```bash
bin/lint              # Verifica erros de lint
bin/lint-fix          # Corrige erros automaticamente  
bundle exec rubocop   # RuboCop completo
bundle exec rubocop -A # RuboCop com auto-correção
```

### Frontend (JavaScript/TypeScript)

```bash
npm run lint         # Executar ESLint em todos os arquivos
npm run lint:fix     # Corrigir issues auto-fixáveis do ESLint
npm run format       # Formatar código com Prettier
npm run format:check # Verificar formatação do código
npm run check        # Executar lint e verificação de formatação
```

## 📐 Regras de Estilo de Código

### 1. **Formatação Geral**

#### Ruby/Rails
- **Indentação**: 2 espaços (não usar tabs)
- **Aspas**: Sempre usar aspas simples (`'`) exceto em strings com interpolação
- **Comprimento de linha**: Máximo 120 caracteres
- **Frozen string literals**: Sempre incluir `# frozen_string_literal: true`
- **Hash syntax**: Usar sintaxe Ruby 1.9+ (`:key =>` vira `key:`)
- **Vírgulas finais**: Não usar vírgulas no último item de arrays/hashes

#### JavaScript/TypeScript
- **Indentação**: 2 espaços (configurado via Prettier)
- **Aspas**: Simples para imports, duplas para strings
- **Ponto e vírgula**: Opcional (configurado no ESLint)
- **Comprimento de linha**: Máximo 100 caracteres
- **Trailing commas**: Usar em objetos multi-linha

### 2. **Ruby Style**

- **Arrays de símbolos**: Usar `[:symbol1, :symbol2]` ao invés de `%i[symbol1 symbol2]` para arrays pequenos
- **Condicionais**: Sempre usar chaves mesmo para uma linha
- **Guard clauses**: Preferir `return unless` no início dos métodos
- **Operadores**: Usar `&&`/`||` ao invés de `and`/`or` exceto para controle de fluxo
- **Return explícito**: Evitar `return` desnecessário no final de métodos

### 3. **Rails Específico**

- **Validações**: Não usar validação explícita de `presence` para `belongs_to` (Rails já faz automaticamente)
- **Enums**: Usar sintaxe posicional ao invés de keyword arguments
- **Timezone**: Usar `Time.zone.now` ou `Time.current` ao invés de `Time.now`
- **Queries**: Evitar `update_all` quando validações são necessárias
- **File paths**: Usar `Rails.root.join('path', 'to', 'file')` ao invés de strings
- **JSON parsing**: Usar `response.parsed_body` ao invés de `JSON.parse(response.body)` em testes

### 4. **TypeScript/JavaScript Específico**

- **Tipos**: Sempre tipar parâmetros e retornos de funções
- **Interfaces**: Definir interfaces para todos os objetos complexos
- **Enums**: Preferir const assertions ou union types
- **Async/Await**: Preferir sobre Promises encadeadas
- **Destructuring**: Usar para extrair propriedades de objetos
- **Template literals**: Usar para strings com interpolação

### 5. **Convenções de Nomenclatura**

#### Ruby
- **Variáveis e métodos**: `snake_case`
- **Classes e módulos**: `PascalCase`
- **Constantes**: `SCREAMING_SNAKE_CASE`
- **Predicados**: Evitar prefixo `is_` (usar `active?` ao invés de `is_active?`)

#### JavaScript/TypeScript
- **Variáveis e funções**: `camelCase`
- **Classes e tipos**: `PascalCase`
- **Constantes**: `SCREAMING_SNAKE_CASE`
- **Componentes React/Svelte**: `PascalCase`

### 6. **Métricas de Qualidade**

#### Ruby/Rails
- **Métodos**: Máximo 20 linhas
- **Classes**: Máximo 200 linhas
- **Complexidade ciclomática**: Máximo 10
- **Parâmetros**: Máximo 5 por método
- **Blocos**: Máximo 25 linhas

#### JavaScript/TypeScript
- **Funções**: Máximo 50 linhas
- **Arquivos**: Máximo 300 linhas
- **Complexidade ciclomática**: Máximo 10
- **Parâmetros**: Máximo 4 por função
- **Imports**: Máximo 15 por arquivo

## 💻 Exemplos de Código

### ✅ Código Ruby Correto

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

### ❌ Código Ruby a Evitar

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

### ✅ Código TypeScript Correto

```typescript
// Interfaces bem definidas
interface UserData {
  id: number;
  name: string;
  email: string;
  isActive: boolean;
}

// Função com tipos explícitos
async function fetchUser(userId: number): Promise<UserData> {
  try {
    const response = await api.get(`/users/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Erro ao buscar usuário:', error);
    throw error;
  }
}

// Componente Svelte tipado
<script lang="ts">
  import type { UserData } from '$lib/types';
  
  export let user: UserData;
  
  const handleClick = (): void => {
    console.log(`Usuário ${user.name} clicado`);
  };
</script>
```

## 📂 Estrutura de Diretórios

### Backend (Rails API)

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

### Frontend (Svelte)

```
src/
├── lib/
│   ├── api/           # Services e tipos da API
│   ├── components/    # Componentes reutilizáveis
│   ├── stores/        # Stores Svelte
│   ├── utils/         # Utilitários
│   └── validation/    # Validações
├── pages/             # Páginas da aplicação
├── assets/            # Assets estáticos
└── App.svelte         # Componente raiz
```

## 🔄 Git Hooks

O projeto utiliza Husky para executar verificações antes dos commits:

### Pre-commit para Ruby
- Executa RuboCop com auto-fix em arquivos `.rb` e `.rake` modificados
- Re-adiciona arquivos corrigidos automaticamente
- Bloqueia o commit se houver erros que não podem ser corrigidos

### Pre-commit para JavaScript/TypeScript
- Executa ESLint em arquivos staged
- Formata com Prettier
- Bloqueia commit se houver erros de lint

## 🎯 Boas Práticas de Desenvolvimento

### 1. **Controllers**
- Manter métodos pequenos (máximo 10 linhas)
- Usar `before_action` para código comum
- Retornar JSON consistente com status HTTP apropriados
- Usar strong parameters sempre
- Implementar paginação para listagens

### 2. **Models**
- Validações claras e específicas
- Usar scopes para queries complexas
- Callbacks apenas quando necessário
- Relacionamentos bem definidos com `dependent:` apropriado
- Evitar lógica de negócio em models

### 3. **Services**
- Uma responsabilidade por service
- Retornar objetos consistentes (success/error)
- Tratamento adequado de exceções
- Métodos pequenos e focados
- Usar dependency injection

### 4. **Componentes Frontend**
- Componentes pequenos e reutilizáveis
- Props tipadas com TypeScript
- Usar stores para estado compartilhado
- Evitar lógica complexa no template
- Separar lógica de apresentação

### 5. **Testes**

#### Backend
- Usar FactoryBot para dados de teste
- Testes unitários para modelos e services
- Testes de integração para controllers
- Coverage mínimo de 80%
- Usar `let` ao invés de variáveis de instância

#### Frontend
- Testes unitários para funções utilitárias
- Testes de componente para Svelte
- Mocks para chamadas de API
- Coverage mínimo de 70%

### 6. **Segurança**
- Nunca commitar credenciais
- Usar variáveis de ambiente para configurações
- Validar e sanitizar inputs
- Usar Pundit para autorização no backend
- Implementar CORS apropriadamente
- Usar HTTPS em produção

### 7. **Performance**
- Evitar N+1 queries (usar `includes`)
- Indexar colunas de busca frequente
- Usar cache quando apropriado
- Background jobs para operações lentas
- Lazy loading para componentes pesados
- Otimizar bundle size no frontend

## 📡 Padrões de API

### Resposta de Sucesso

```json
{
  "success": true,
  "data": { 
    "id": 1,
    "name": "João Silva",
    "email": "joao@example.com"
  },
  "message": "Usuário criado com sucesso"
}
```

### Resposta de Erro

```json
{
  "success": false,
  "message": "Email já está em uso",
  "errors": [
    "Email já está em uso",
    "CPF inválido"
  ]
}
```

### Paginação

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 100,
    "per_page": 10
  }
}
```

## 🌍 Ambientes

### Development
- Configuração local com logs verbosos
- Seeds disponíveis para testes
- Hot reload ativado
- Emails em modo sandbox

### Test
- Ambiente para execução de testes
- Banco de dados isolado
- Fixtures carregadas automaticamente
- Transações para rollback

### Staging
- Ambiente de pré-produção
- Dados similares à produção
- Testes de integração e aceitação
- Monitoramento básico

### Production
- Ambiente de produção
- Logs estruturados
- Cache ativado
- Monitoramento completo
- Backups automatizados

## 📋 Checklist de Qualidade

### Antes de Abrir um PR

- [ ] Código segue os padrões estabelecidos
- [ ] Testes passando (mínimo 80% coverage)
- [ ] Lint sem erros
- [ ] Documentação atualizada
- [ ] Sem código comentado ou console.log
- [ ] Migrations reversíveis
- [ ] Variáveis de ambiente documentadas
- [ ] Performance testada
- [ ] Segurança verificada

### Review de Código

- [ ] Lógica está correta e eficiente
- [ ] Código é legível e manutenível
- [ ] Testes cobrem casos importantes
- [ ] Sem duplicação de código
- [ ] Padrões do projeto seguidos
- [ ] Documentação adequada
- [ ] Performance aceitável
- [ ] Segurança implementada

---

**Última atualização**: Dezembro 2024
**Mantenedor**: Equipe ProcStudio