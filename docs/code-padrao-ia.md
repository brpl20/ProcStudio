[Voltar](../README.md)

# 📋 Padrão de Desenvolvimento com IA - ProcStudio

## 🎯 Visão Geral

Este documento estabelece os padrões e práticas para desenvolvimento com assistência de IA no projeto ProcStudio. O objetivo é maximizar a produtividade mantendo a qualidade, segurança e consistência do código.

## 🤖 Configuração do Claude

### Estrutura de Pastas e Contextos

O projeto utiliza uma estrutura multi-contexto com Claude, onde cada pasta possui suas próprias regras e ferramentas especializadas:

```
/              → Tarefas gerais que podem implicar múltiplas estruturas de pasta
/api           → Usar Claude-swarm com servidores MCP e ferramentas apropriadas
/frontend      → Desenvolvimento Frontend com Svelte 5
/docs          → Documentação do projeto
/tests         → Testes especializados com múltiplos arquivos CLAUDE
```

### ⚠️ Cuidados Importantes com Uso do Modelo

1. **Gestão de Tokens**: Especialmente na pasta `/api` com Claude-swarm, o uso de tokens pode se esgotar rapidamente
2. **Mudança de Branch**: Sempre confirme com revisão humana antes de permitir que o Claude mude de branch
3. **Ferramentas Permitidas**: Configure e revise as permissões de ferramentas em cada contexto
4. **Revisão Humana**: Todo código gerado deve passar por revisão humana antes do merge

## 📁 Arquivos CLAUDE.md

Cada pasta principal deve conter um arquivo `CLAUDE.md` com regras específicas:

### `/api/CLAUDE.md`
```markdown
# Regras específicas para desenvolvimento Rails API
- Versão Rails: 8.0.2.1
- Versão Ruby: 3.2.7
- Framework de testes: RSpec
- Arquitetura Swarm com agentes especializados
- Ferramentas MCP disponíveis
```

### `/frontend/CLAUDE.md`
```markdown
# Regras específicas para desenvolvimento Frontend
- Framework: Svelte 5 com TypeScript
- Estilização: Tailwind CSS 4 com DaisyUI
- Build: Vite com proxy para API
- Gerenciamento de Estado: Svelte stores
```

### `/tests/`
Múltiplos arquivos CLAUDE especializados:
- `CLAUDE-API.md` - Testes da API Rails Backend
- `CLAUDE-RAILS.md` - Testes Rails
- `CLAUDE-SVELTE.md` - Testes Svelte
- `CLAUDE-E2E.md` - Testes end-to-end
- `CLAUDE-DB.md` - Testes PostgreSQL
- `CLAUDE-DOCS.md` - Documentação de testes

## 🔧 Padrões de Código

### Ruby/Rails (Backend)

#### Formatação e Estilo
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
end
```

#### Configurações RuboCop
- Indentação: 2 espaços (não usar tabs)
- Aspas: Simples (`'`) exceto com interpolação
- Linha máxima: 120 caracteres
- Sempre incluir `# frozen_string_literal: true`
- Hash syntax: Ruby 1.9+ (`:key =>` vira `key:`)

#### Scripts de Qualidade
```bash
bin/lint              # Verifica erros de lint
bin/lint-fix          # Corrige erros automaticamente
bundle exec rubocop   # RuboCop completo
bundle exec rubocop -A # Auto-correção
```

### Frontend (Svelte/TypeScript)

#### Princípios de Qualidade
- DRY (Don't Repeat Yourself)
- SOLID
- Separação de Responsabilidades
- Código mínimo necessário

#### Comandos de Qualidade
```bash
npm run lint         # Executar ESLint
npm run lint:fix     # Corrigir issues auto-fixáveis
npm run format       # Formatar com Prettier
npm run format:check # Verificar formatação
npm run check        # Lint + format check
```

#### TypeScript
- Todo código novo DEVE usar TypeScript
- Definir interfaces em `src/lib/api/types/`
- Usar strict type checking
- Verificar lint após criações
- Verificar lint do repositório antes do commit

## 🌿 Fluxo Git e Contribuições

### Convenções de Branch

```bash
# Verificar branch atual
git status

# Criar nova branch a partir da main
git checkout -b re123  # RE + número do ticket
```

### Padrões de Commit

```bash
# Formato do commit
git commit -m "RE #123 - Implementa funcionalidade X"
```

### Pull Requests

1. Nome do PR: `RE#123` (RE + número do ticket)
2. Sempre criar PR para a branch `main`
3. Retornar para `main` após PR criado
4. Revisão humana obrigatória antes do merge

### Regras de Branch por Contexto

#### Branch `main` (Principal)
- Branch estável e deployável
- Todos os PRs devem ser direcionados aqui
- Requer aprovação para merge

#### Branches de Feature (`re[número]`)
- Criadas a partir da `main`
- Uma branch por ticket/issue
- Deletadas após merge

#### Branches de Hotfix
- Prefixo: `hotfix/`
- Para correções urgentes em produção
- Merge direto na `main` e tags de release

## 🔒 Segurança e Boas Práticas

### Segurança
- **NUNCA** commitar credenciais ou chaves
- Usar variáveis de ambiente para configurações sensíveis
- Validar e sanitizar todos os inputs
- Implementar autorização apropriada (Pundit no Rails)
- Revisar código gerado por IA antes de executar

### Performance
- Evitar N+1 queries (usar `includes` no Rails)
- Indexar colunas de busca frequente
- Implementar cache quando apropriado
- Background jobs para operações lentas
- Otimizar bundle size no frontend

### Testes

#### Rails/RSpec
```bash
# Executar todas as specs
bundle exec rspec

# Executar specs de um diretório
bundle exec rspec spec/models

# Executar spec específica
bundle exec rspec spec/controllers/accounts_controller_spec.rb:8
```

#### Coverage Mínimo
- Modelos: 90%
- Services: 85%
- Controllers: 80%
- Coverage geral: 80%

## 📊 Métricas de Qualidade de Código

### Backend (Ruby/Rails)
- **Métodos**: Máximo 20 linhas
- **Classes**: Máximo 200 linhas
- **Complexidade Ciclomática**: Máximo 10
- **Parâmetros por método**: Máximo 5
- **Blocos**: Máximo 25 linhas

### Frontend (TypeScript/Svelte)
- **Componentes**: Máximo 300 linhas
- **Funções**: Máximo 50 linhas
- **Complexidade**: Máximo 10
- **Imports**: Organizados e agrupados
- **Props**: Tipadas com interfaces

## 🛠️ Ferramentas de Desenvolvimento com IA

### Autenticador (API)
```bash
# Autenticar usuário específico
node ai-tools/authenticator.js auth user1

# Autenticar todos os usuários de teste
node ai-tools/authenticator.js auth-all

# Testar API com token armazenado
node ai-tools/authenticator.js test user1 /api/v1/users
```

### Model Explorer (Rails)
```bash
# Gerar documentação de modelo
rails runner public/brpl/model_explorer.rb ModelName
```

### Structure Analyzer (Frontend)
```bash
# Analisar estrutura do projeto
node ai-tools/structure-analyzer.js
```

## 🎓 Diretrizes para uso do Claude

### Comandos Pré-aprovados

O Claude tem permissão automática para executar:

#### Backend
```bash
bundle exec rails:*
bundle exec rspec:*
rails generate migration:*
git add:*
git commit:*
git checkout:*
```

#### Frontend
```bash
npm install:*
npm run lint
npx eslint:*
```

#### Utilitários
```bash
node authenticator.js
ruby --version
rails routes
```

### Princípios de Interação

1. **Proatividade Controlada**: Claude pode ser proativo quando solicitado, mas não deve surpreender com ações não requisitadas
2. **Convenções First**: Sempre seguir convenções existentes do projeto antes de introduzir novos padrões
3. **Segurança First**: Nunca expor secrets, sempre validar inputs, seguir práticas de segurança
4. **Revisão Humana**: Todo código crítico deve passar por revisão humana

## 📝 Padrões de Resposta da API

### Resposta de Sucesso
```json
{
  "success": true,
  "data": { ... },
  "message": "Mensagem opcional de sucesso"
}
```

### Resposta de Erro
```json
{
  "success": false,
  "message": "Email já está em uso",
  "errors": ["Email já está em uso"]
}
```

## 🚀 Ambientes

### Development
- Logs verbosos
- Hot reload ativado
- Proxy para API local

### Test
- Ambiente isolado para testes
- Banco de dados de teste separado
- Fixtures e factories disponíveis

### Staging
- Pré-produção
- Dados similares à produção
- Testes de integração

### Production
- Otimizado para performance
- Logs estruturados
- Monitoramento ativo

## 📋 Checklist de Desenvolvimento

### Antes de Começar
- [ ] Verificar branch atual (`git status`)
- [ ] Criar branch a partir da `main`
- [ ] Ler documentação relevante
- [ ] Verificar CLAUDE.md da pasta

### Durante o Desenvolvimento
- [ ] Seguir padrões de código estabelecidos
- [ ] Escrever testes para código novo
- [ ] Usar TypeScript no frontend
- [ ] Documentar funções complexas
- [ ] Verificar lint regularmente

### Antes do Commit
- [ ] Executar testes (`rspec` ou `npm test`)
- [ ] Executar linters (`rubocop` ou `npm run lint`)
- [ ] Revisar código gerado por IA
- [ ] Verificar que não há secrets expostos
- [ ] Escrever mensagem de commit descritiva

### Após o PR
- [ ] Aguardar revisão humana
- [ ] Responder feedback
- [ ] Verificar CI/CD passou
- [ ] Retornar para branch `main`

## 🔄 Processo de Atualização

Este documento deve ser atualizado sempre que:
- Novas ferramentas de IA forem integradas
- Padrões de código forem modificados
- Novos contextos/pastas forem adicionados
- Lições aprendidas precisarem ser documentadas

## 📚 Recursos Adicionais

- [Documentação Svelte 5](https://svelte.dev)
- [Rails Guides](https://guides.rubyonrails.org)
- [TypeScript Handbook](https://www.typescriptlang.org/docs)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [DaisyUI Components](https://daisyui.com)

---

**Última atualização**: Dezembro 2024
**Mantenedor**: Equipe ProcStudio