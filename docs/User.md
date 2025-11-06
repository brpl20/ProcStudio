[Back](../README.md)

# User & UserProfile

## Visão Geral

O sistema ProcStudio utiliza uma arquitetura de dois modelos para gerenciamento de usuários:

- **User**: Modelo de autenticação com campos essenciais (email, senha, team)
- **UserProfile**: Informações detalhadas do perfil profissional e pessoal

Esta separação facilita o onboarding progressivo, permitindo registro rápido com completamento posterior dos dados.

_Nota: Em produção, o ID do User deve corresponder ao ID do UserProfile para manter integridade referencial._

## Modelos de Dados

### User Model
Campos principais do modelo de autenticação:

```ruby
# Campos obrigatórios
email        # Único no sistema
password     # Mínimo 6 caracteres
team_id      # Auto-atribuído no registro público

# Campos opcionais  
oab          # Formato: UF_NUMERO (ex: PR_54159)
status       # Enum: active/inactive (default: active)

# Campos de sistema
deleted_at   # Soft delete com paranoia gem
created_at
updated_at
```

### UserProfile Model
Informações detalhadas do usuário:

```ruby
# Relacionamentos
user_id      # FK obrigatório
office_id    # FK opcional

# Dados pessoais
name         # Nome
last_name    # Sobrenome
cpf          # CPF brasileiro
rg           # Documento de identidade
gender       # Enum: male/female (removido 'other')
civil_status # Estado civil
nationality  # Nacionalidade (default: brazilian)
birth        # Data de nascimento
mother_name  # Nome da mãe

# Dados profissionais
role         # Enum: lawyer (único ativo no MVP)
oab          # Obrigatório para role=lawyer

# Associações polimórficas
addresses    # Via addressable
phones       # Via phoneable
emails       # Via emailable
bank_accounts # Via bankable
```

## Validações de Modelo

### Validações User
- Email: presença e formato válido
- Password: presença se novo registro
- Team: presença obrigatória

### Validações UserProfile
- User: presença obrigatória
- OAB: obrigatória apenas quando role='lawyer'
- Office: deve pertencer ao mesmo team do user (se presente)

## Fluxos de Criação

### 1. Registro Público (Novo Usuário)
```
POST /api/v1/public/user_registration
→ Cria User + Team automático
→ Busca dados OAB (se fornecida)
→ Cria UserProfile parcial
→ Redireciona para completar perfil
```

### 2. Criação Privada (Usuário Existente)
```
POST /api/v1/user_profiles (com user_attributes)
→ Valida permissões do criador
→ Cria User no team atual
→ Cria UserProfile completo
→ Sem necessidade de completar perfil
```

### 3. Convite por Email (Novo no MVP)
```
POST /api/v1/user_profiles/invite
→ Envia apenas email
→ Destinatário recebe link
→ Completa cadastro via fluxo público
```

## API Endpoints

### Endpoints de Consulta

```ruby
# Informações do usuário atual
GET /api/v1/whoami
Response: FullUserSerializer (User + UserProfile combinados)

# Busca por identificador flexível
GET /api/v1/user_info/:identifier
Params: User ID ou UserProfile ID
Response: FullUserSerializer

# Busca específica por perfil
GET /api/v1/user_by_profile/:profile_id
Response: User data

# Busca específica por usuário
GET /api/v1/user_by_id/:user_id
Response: UserProfile data
```

### Endpoints de Criação/Atualização

```ruby
# Criar perfil com usuário (privado)
POST /api/v1/user_profiles
Body: user_profile com user_attributes aninhados

# Completar perfil (público)
POST /api/v1/user_profiles/complete_profile
Body: campos faltantes do perfil

# Atualizar perfil existente
PUT/PATCH /api/v1/user_profiles/:id
Body: campos a atualizar
```

## Serializers

### FullUserSerializer
Combina dados de User e UserProfile em resposta unificada:

```json
{
  "id": "user_profile_id",
  "type": "user_profile",
  "attributes": {
    "name": "João",
    "last_name": "Silva",
    "role": "lawyer",
    "oab": "PR_54159",
    "access_email": "joao@example.com",
    "user_id": 123,
    "team_id": 456,
    "status": "active",
    // ... outros campos do perfil
    "addresses": [...],
    "phones": [...],
    "bank_accounts": [...]
  }
}
```

## Regras de Negócio

### Campos Obrigatórios por Contexto

| Campo | Registro Público | Criação Privada | Completar Perfil |
|-------|-----------------|-----------------|------------------|
| email | ✅ Obrigatório | ✅ Obrigatório | ❌ Já existe |
| password | ✅ Obrigatório | ✅ Obrigatório | ❌ Já existe |
| name | ⚠️ Auto OAB | ✅ Obrigatório | ✅ Se faltante |
| role | ⚠️ Auto lawyer | ✅ Obrigatório | ✅ Se faltante |
| oab | ⚪ Opcional | ✅ Para lawyer | ✅ Para lawyer |
| cpf | ❌ Não requerido | ⚪ Opcional | ✅ Se faltante |

### Roles Disponíveis

No MVP, apenas o role `lawyer` está ativo. Os demais estão desabilitados no frontend:

```ruby
# Ativo
lawyer       # Advogado

# Desabilitados (futuro)
paralegal    # Paralegal
trainee      # Estagiário  
secretary    # Secretário
counter      # Contador
excounter    # Ex-contador
representant # Representante
```

## Integração com Frontend

### Arquitetura de Componentes

```
forms_commons/         # Componentes atômicos
  ├── Email.svelte    
  ├── Cpf.svelte
  └── OabId.svelte

forms_users_wrappers/  # Agrupamentos lógicos
  ├── UserBasicInfo.svelte
  └── UserCredentials.svelte

pages/                 # Formulários completos
  └── UserFormUnified.svelte
```

### Store Unificado

```typescript
userFormStore.svelte.ts
├── Modos: public_registration | private_creation | profile_completion | invite
├── Validação dinâmica baseada no modo
├── Submissão para endpoint correto
└── Estado compartilhado entre componentes
```

## Considerações de Segurança

- Senhas hasheadas com bcrypt via Devise
- Tokens JWT para autenticação
- Scoping automático por team
- Soft delete preserva dados para auditoria
- Validação de permissões em todas operações

## Migração e Manutenção

### Pendências
- Unificar formulários UserForm e ProfileCompletion
- Implementar sistema de convites
- Adicionar dados bancários no cadastro
- Remover opções de roles não utilizadas
- Automatizar status (sempre active ao criar)

### Boas Práticas
- Manter paridade User.id = UserProfile.id
- Usar FullUserSerializer para respostas completas
- Validar OAB via API externa quando fornecida
- Cachear dados de perfil no frontend
