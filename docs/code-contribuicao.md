[Voltar](../README.md)

# Guia de Contribuição - ProcStudio

## Visão Geral

Este documento estabelece as diretrizes e processos para contribuir com o projeto ProcStudio. Seguir estas convenções garante um fluxo de trabalho eficiente e rastreabilidade completa entre issues, commits e pull requests.

## Kaízen 

Quando você ver alguma coisa errada, levante uma bandeira vermelha e alerte todos da linha de produção que existem melhorias a serem feitas. Na API nós tínhamos um erro que o nosso Rails era o único Rails do mundo que usava o termo `bundler install` ao invés de `bundle install` e isso sempre gerava confusão. Entra programador, sai programador e ninguém nunca foi atrás para resolver esse problema, simplesmente aceitando que especificamente neste Rails, o único do planeta deveria ser utilizado `bundler`! Até que quando eu iniciei a trabalhar mais efetivamente no sistema resolvi atacar este problema e o erro estava em mudar um `[` para `(`, o que fazia com que a leitura ficasse incorreta: https://github.com/brpl20/ProcStudio/commit/bf26e7199f8d19c9e9ad78ba255ea9d263e3e53e

A lição é: _Não passe por cima dos problemas, não ignore os bugs, eles voltarão para te assombrar. Se algo estiver errado, pare conserte, peça ajuda e cresça aprendendo com o sistema._


TD: Terminar essa documentação <---- Parei Aqui ! 


## Fluxo de Trabalho Git

### 1. Estrutura de Branches

#### **Branch Principal (`main`)**
- Branch estável e sempre deployável
- Protegida contra push direto
- Todos os merges requerem PR aprovado
- CI/CD deve passar antes do merge

#### **Branches de Feature (`re[número]`)**
- Prefixo: `re` seguido do número do ticket
- Exemplo: `re123`, `re456`
- Criadas sempre a partir da `main` atualizada
- Uma branch por ticket/issue
- Deletadas após merge bem-sucedido

#### **Branches de Hotfix (`hotfix/[descrição]`)**
- Para correções urgentes em produção
- Exemplo: `hotfix/corrige-login-critico`
- Criadas a partir da `main`
- Merge prioritário após testes

#### **Branches de Release (`release/[versão]`)**
- Para preparação de releases
- Exemplo: `release/v1.2.0`
- Apenas ajustes finais e documentação
- Merge na `main` e criação de tag

### 2. Processo de Desenvolvimento

#### **Passo 1: Escolher um Ticket**

```bash
# Verificar issues disponíveis no GitHub
# Escolher ticket #123 para trabalhar
```

#### **Passo 2: Preparar Branch**

```bash
# Garantir que está na main atualizada
git checkout main
git pull origin main

# Verificar status atual
git status
# Deve retornar: "On branch main"

# Criar nova branch para o ticket
git checkout -b re123
```

#### **Passo 3: Desenvolvimento**

Durante o desenvolvimento:
- Faça commits frequentes e descritivos
- Execute testes localmente
- Verifique lint e formatação
- Mantenha a branch atualizada com a main

#### **Passo 4: Commits**

### 3. Padrão de Commits

#### **Formato Básico**

```bash
git commit -m "RE #123 - Descrição clara da mudança"
```

#### **Tipos de Commit (Conventional Commits)**

```bash
# Feature nova
git commit -m "RE #123 - feat: adiciona sistema de notificações"

# Correção de bug
git commit -m "RE #123 - fix: corrige erro no login"

# Documentação
git commit -m "RE #123 - docs: atualiza README com novas instruções"

# Refatoração
git commit -m "RE #123 - refactor: melhora performance da query"

# Testes
git commit -m "RE #123 - test: adiciona testes para UserService"

# Configuração
git commit -m "RE #123 - chore: atualiza dependências"

# Estilo
git commit -m "RE #123 - style: ajusta formatação do código"
```

#### **Commits Multi-linha**

```bash
git commit -m "RE #123 - feat: implementa autenticação 2FA

- Adiciona modelo TwoFactorAuth
- Implementa geração de QR code
- Cria endpoints de verificação
- Adiciona testes de integração"
```

### 4. Pull Requests

#### **Criando um PR**

1. **Push da Branch**
```bash
git push origin re123
```

2. **Abrir PR no GitHub**
   - Título: `RE#123 - Breve descrição`
   - Descrição detalhada usando o template
   - Link para a issue relacionada
   - Screenshots se aplicável

#### **Template de PR**

```markdown
## 📋 Descrição
Breve descrição do que foi implementado/corrigido

## 🎯 Issue Relacionada
Closes #123

## 💻 Tipo de Mudança
- [ ] 🐛 Bug fix (correção que não quebra funcionalidade existente)
- [ ] ✨ Nova feature (mudança que adiciona funcionalidade)
- [ ] 💥 Breaking change (correção ou feature que quebra funcionalidade existente)
- [ ] 📝 Documentação
- [ ] ♻️ Refatoração

## ✅ Checklist
- [ ] Meu código segue os padrões do projeto
- [ ] Fiz auto-revisão do meu código
- [ ] Comentei código complexo quando necessário
- [ ] Atualizei a documentação correspondente
- [ ] Minhas mudanças não geram warnings
- [ ] Adicionei testes que cobrem minhas mudanças
- [ ] Todos os testes passam localmente
- [ ] Dependências foram atualizadas corretamente

## 🧪 Como Testar
Passos para testar as mudanças:
1. Passo 1
2. Passo 2
3. ...

## 📸 Screenshots (se aplicável)
Adicione screenshots para demonstrar mudanças visuais

## 📝 Notas Adicionais
Informações adicionais relevantes para os revisores
```

#### **Após Criar o PR**

```bash
# Retornar para a branch main
git checkout main

# Atualizar com últimas mudanças
git pull origin main
```

### 5. Revisão de Código

#### **Para Revisores**

##### Checklist de Revisão

- **Funcionalidade**
  - [ ] O código resolve o problema descrito na issue?
  - [ ] Existem edge cases não tratados?
  - [ ] A solução é eficiente?

- **Código**
  - [ ] O código é legível e manutenível?
  - [ ] Segue os padrões do projeto?
  - [ ] Não há duplicação desnecessária?
  - [ ] Variáveis e funções têm nomes descritivos?

- **Testes**
  - [ ] Existem testes adequados?
  - [ ] Os testes cobrem casos importantes?
  - [ ] Todos os testes passam?

- **Segurança**
  - [ ] Não há exposição de dados sensíveis?
  - [ ] Inputs são validados?
  - [ ] Não há vulnerabilidades conhecidas?

- **Performance**
  - [ ] Não há queries N+1?
  - [ ] Uso adequado de índices?
  - [ ] Cache implementado quando necessário?

##### Como Revisar

```bash
# Fazer checkout do PR localmente
git fetch origin pull/123/head:pr-123
git checkout pr-123

# Testar as mudanças
bundle exec rspec  # Backend
npm test          # Frontend

# Verificar qualidade
bundle exec rubocop
npm run lint
```

#### **Para Autores**

- Responda todos os comentários
- Faça as alterações solicitadas
- Re-solicite revisão após mudanças
- Mantenha o PR atualizado com a main

## 🧪 Testes

### Backend (RSpec)

```bash
# Executar todas as specs
bundle exec rspec

# Executar specs de um diretório
bundle exec rspec spec/models

# Executar spec específica
bundle exec rspec spec/controllers/accounts_controller_spec.rb

# Executar linha específica
bundle exec rspec spec/controllers/accounts_controller_spec.rb:8

# Com coverage
COVERAGE=true bundle exec rspec
```

### Frontend (Vitest/Jest)

```bash
# Executar todos os testes
npm test

# Modo watch
npm run test:watch

# Com coverage
npm run test:coverage

# Testes específicos
npm test -- UserStore
```

## 🔧 Ferramentas de Qualidade

### Linters e Formatadores

#### Ruby/Rails

```bash
# Verificar código
bundle exec rubocop

# Auto-corrigir
bundle exec rubocop -A

# Arquivo específico
bundle exec rubocop app/models/user.rb

# Atualizar configuração
bundle exec rubocop --auto-gen-config
```

#### JavaScript/TypeScript

```bash
# Verificar código
npm run lint

# Auto-corrigir
npm run lint:fix

# Formatar código
npm run format

# Verificar formatação
npm run format:check
```

### Git Hooks (Husky)

Os hooks são executados automaticamente, mas podem ser executados manualmente:

```bash
# Pre-commit
npm run pre-commit

# Pre-push
npm run pre-push

# Pular hooks (usar com cuidado!)
git commit --no-verify
```

## 📋 Convenções e Padrões

### Nomenclatura

#### Issues
- Título claro e descritivo
- Labels apropriadas (bug, feature, docs, etc.)
- Milestone quando aplicável
- Assignee quando em desenvolvimento

#### Branches
- `re[número]` - Features/bugs da issue
- `hotfix/[descrição]` - Correções urgentes
- `release/[versão]` - Preparação de release
- `docs/[descrição]` - Apenas documentação

#### Commits
- Prefixo `RE #[número]`
- Mensagem clara em português
- Verbos no presente do indicativo
- Máximo 72 caracteres no título

#### Pull Requests
- Título: `RE#[número]` ou descrição clara
- Sempre linkar issue relacionada
- Usar template fornecido
- Adicionar labels apropriadas

## 🚨 Processo de Hotfix

Para correções urgentes em produção:

```bash
# 1. Criar branch de hotfix
git checkout main
git pull origin main
git checkout -b hotfix/corrige-bug-critico

# 2. Fazer a correção
# ... código ...

# 3. Commit com mensagem clara
git commit -m "hotfix: corrige erro crítico no login"

# 4. Push e criar PR
git push origin hotfix/corrige-bug-critico

# 5. Após aprovação e merge, criar tag
git checkout main
git pull origin main
git tag -a v1.2.1 -m "Hotfix: correção crítica no login"
git push origin v1.2.1
```

## 📦 Processo de Release

### Preparação

```bash
# 1. Criar branch de release
git checkout main
git pull origin main
git checkout -b release/v1.3.0

# 2. Atualizar versão
# - package.json (frontend)
# - Gemfile (backend)
# - CHANGELOG.md

# 3. Gerar build de produção
npm run build     # Frontend
bundle exec rails assets:precompile  # Backend

# 4. Executar testes completos
npm test
bundle exec rspec

# 5. Commit de release
git commit -m "chore: prepara release v1.3.0"

# 6. Criar PR para main
git push origin release/v1.3.0
```

### Após Merge

```bash
# 1. Criar tag
git checkout main
git pull origin main
git tag -a v1.3.0 -m "Release v1.3.0: Nova funcionalidade X"
git push origin v1.3.0

# 2. Deploy (automático via CI/CD)
```

## 🆘 Resolução de Problemas

### Conflitos de Merge

```bash
# Atualizar branch com main
git checkout re123
git fetch origin
git merge origin/main

# Resolver conflitos manualmente
# Editar arquivos conflitantes
git add .
git commit -m "RE #123 - resolve conflitos com main"
```

### Branch Desatualizada

```bash
# Rebase com main
git checkout re123
git fetch origin
git rebase origin/main

# Se houver conflitos durante rebase
git rebase --continue  # após resolver
git rebase --abort     # para cancelar
```

### Commits Errados

```bash
# Desfazer último commit (mantém mudanças)
git reset --soft HEAD~1

# Desfazer último commit (descarta mudanças)
git reset --hard HEAD~1

# Editar mensagem do último commit
git commit --amend -m "Nova mensagem"
```

## 📊 Métricas de Qualidade

### Coverage Mínimo
- Backend: 80%
- Frontend: 70%
- Crítico: 90%

### Performance
- Tempo de resposta API: < 200ms
- Bundle size: < 500KB
- Lighthouse score: > 90

### Qualidade de Código
- RuboCop: 0 ofensas
- ESLint: 0 erros
- TypeScript: strict mode

## 🤝 Código de Conduta

- Seja respeitoso e profissional
- Aceite feedback construtivamente
- Ajude outros contribuidores
- Documente seu código
- Teste antes de submeter
- Mantenha discussões no escopo

## 📚 Recursos Úteis

### Documentação
- [Padrões de Código](./Padrão-de-desenvolvimento.md)
- [Desenvolvimento com IA](./Padrão-de-desenvolvimento-com-IA.md)
- [Instalação](./Instalação.md)
- [API Docs](./API.md)

### Links Externos
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Semantic Versioning](https://semver.org/)

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique a documentação
2. Busque em issues existentes
3. Abra uma nova issue com detalhes
4. Contate a equipe no Slack/Discord

---

**Última atualização**: Dezembro 2024
**Mantenedor**: Equipe ProcStudio

## Resumo Rápido

### Fluxo Típico

1. **Ticket**: #123
2. **Branch**: `re123`
3. **Commits**: `RE #123 - implementa feature X`
4. **Pull Request**: `RE#123`
5. **Merge**: Após aprovação
6. **Cleanup**: Voltar para `main`

### Comandos Essenciais

```bash
# Início
git checkout main && git pull
git checkout -b re123

# Durante desenvolvimento
git add .
git commit -m "RE #123 - descrição"
git push origin re123

# Após PR aprovado
git checkout main
git pull origin main
```
