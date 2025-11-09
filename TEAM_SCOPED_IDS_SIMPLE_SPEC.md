# Especificação Simplificada: Team-Scoped IDs (SEM Backward Compatibility)

## 🎯 Solução com Gem `sequenced`

Sem necessidade de backward compatibility, podemos usar a gem **sequenced** que automatiza sequências por escopo + formatação customizada simples.

---

## 📦 Instalação

### 1. Adicionar Gem

```ruby
# Gemfile
gem 'sequenced'
```

```bash
bundle install
```

### 2. Database - Opção A: Usar `sequential_id` como número + `display_id` formatado

**Migration:**
```ruby
class AddTeamScopedIdsToJobs < ActiveRecord::Migration[7.0]
  def change
    # Adicionar sequential_id (gerenciado pela gem)
    add_column :jobs, :sequential_id, :integer, null: false
    add_column :jobs, :display_id, :string, null: false

    # Índices únicos
    add_index :jobs, :display_id, unique: true
    add_index :jobs, [:team_id, :sequential_id], unique: true,
              name: 'index_jobs_on_team_sequential'
  end
end
```

**Aplicar para:** jobs, works, offices, documents, procedures

---

## 🛠️ Implementação Backend

### 1. Concern Reutilizável

```ruby
# app/models/concerns/team_scoped_identifier.rb
module TeamScopedIdentifier
  extend ActiveSupport::Concern

  included do
    # Gem sequenced cuida da sequência por team
    acts_as_sequenced scope: :team_id, column: :sequential_id

    # Gerar display_id após sequenced atribuir sequential_id
    after_create :generate_display_id

    validates :display_id, presence: true, uniqueness: true
  end

  # Usar display_id em URLs
  def to_param
    display_id
  end

  private

  def generate_display_id
    team_prefix = team.subdomain&.upcase&.first(3) || "T#{team_id}"
    entity_prefix = self.class.name.upcase.first(3)
    sequence_str = sequential_id.to_s.rjust(3, '0')

    formatted_id = "#{team_prefix}-#{entity_prefix}-#{sequence_str}"

    update_column(:display_id, formatted_id)
  end

  module ClassMethods
    # Finder por display_id
    def find_by_display_id!(display_id)
      find_by!(display_id: display_id)
    end
  end
end
```

### 2. Aplicar nos Models

```ruby
# app/models/job.rb
class Job < ApplicationRecord
  include TeamScopedIdentifier

  belongs_to :team
  # ... resto do model
end
```

Aplicar em: `Work`, `Office`, `Document`, `Procedure`

### 3. Atualizar Controllers

```ruby
# app/controllers/api/v1/jobs_controller.rb
class Api::V1::JobsController < ApplicationController
  def show
    @job = team_scoped(Job).find_by_display_id!(params[:id])
    render_job
  end

  def index
    # Ordenar por sequential_id (mais recente primeiro)
    @jobs = team_scoped(Job).order(sequential_id: :desc)
    render_jobs
  end
end
```

### 4. Atualizar Serializers

```ruby
# app/serializers/job_serializer.rb
class JobSerializer
  include JSONAPI::Serializer

  # display_id como ID principal
  attribute :id do |job|
    job.display_id
  end

  attribute :sequential_id
  attributes :title, :description, :status, :priority

  belongs_to :team
  belongs_to :work
end
```

---

## 💎 Opção B: Display ID como Primary Key (AINDA MAIS SIMPLES!)

Se você quer ser **radical** e usar string como ID primário:

### Migration

```ruby
class ConvertJobsToDisplayIdPrimaryKey < ActiveRecord::Migration[7.0]
  def change
    # Remover auto-increment bigint
    remove_column :jobs, :id

    # Adicionar display_id como primary key
    add_column :jobs, :id, :string, primary_key: true, null: false
    add_column :jobs, :sequential_id, :integer, null: false

    add_index :jobs, [:team_id, :sequential_id], unique: true
  end
end
```

### Model (super simples!)

```ruby
class Job < ApplicationRecord
  belongs_to :team
  acts_as_sequenced scope: :team_id, column: :sequential_id

  before_create :generate_id

  private

  def generate_id
    # sequential_id já foi atribuído pela gem
    team_prefix = team.subdomain&.upcase&.first(3) || "T#{team_id}"
    self.id = "#{team_prefix}-JOB-#{sequential_id.to_s.rjust(3, '0')}"
  end
end
```

**Vantagens:**
- ✅ Não precisa de `display_id` separado
- ✅ Apenas 1 campo: `id` (string)
- ✅ Serializers não precisam mudar nada
- ✅ `to_param` já funciona automaticamente

**Desvantagens:**
- ⚠️ Foreign keys precisam ser string também
- ⚠️ Não pode reverter facilmente (mas você disse que não precisa!)

---

## 🎨 Frontend (Mudanças Mínimas)

### Types

```typescript
// frontend/src/lib/api/types/job.types.ts
export interface Job {
  id: string;              // "ABC-JOB-001"
  sequentialId: number;    // 1, 2, 3...
  title: string;
  status: JobStatus;
  // ... outros campos
}
```

### Services

```typescript
// frontend/src/lib/api/services/job.service.ts
private parseJob(jsonApiData: any): Job {
  return {
    id: jsonApiData.id,  // Já vem como string
    sequentialId: jsonApiData.attributes.sequential_id,
    title: jsonApiData.attributes.title,
    // ... outros campos
  };
}
```

### UI

```svelte
<!-- JobList.svelte -->
{#each jobs as job}
  <tr on:click={() => goto(`/jobs/${job.id}`)}>
    <td>#{job.sequentialId}</td>
    <td><code>{job.id}</code></td>
    <td>{job.title}</td>
  </tr>
{/each}
```

---

## 📊 Comparação das Opções

| Aspecto | Opção A (display_id separado) | Opção B (string PK) |
|---------|-------------------------------|---------------------|
| **Complexidade** | Média | Baixa |
| **Campos DB** | 2 (sequential_id + display_id) | 1 (id string) |
| **Foreign Keys** | Mantém bigint | Muda para string |
| **Reversibilidade** | Fácil | Difícil |
| **Simplicidade Code** | Concern reutilizável | Super simples |
| **Performance** | Igual | Igual |

---

## ✅ Recomendação Final

### Para começar rápido: **Opção A** (display_id separado)
- Menos invasiva
- Usa a gem `sequenced` como projetada
- Concern reutilizável
- Foreign keys não mudam

### Para máxima simplicidade: **Opção B** (string PK)
- Menos código
- Menos campos
- Mais direto
- Mas requer mudar FKs para string

---

## 🚀 Implementação - Opção A (Recomendada)

### Passo 1: Instalar Gem
```bash
echo "gem 'sequenced'" >> Gemfile
bundle install
```

### Passo 2: Criar Migrations

```bash
rails generate migration AddTeamScopedIdsToJobs sequential_id:integer display_id:string
rails generate migration AddTeamScopedIdsToWorks sequential_id:integer display_id:string
rails generate migration AddTeamScopedIdsToOffices sequential_id:integer display_id:string
# ... outras entidades
```

Editar migrations para adicionar índices:
```ruby
add_index :jobs, :display_id, unique: true
add_index :jobs, [:team_id, :sequential_id], unique: true
change_column_null :jobs, :sequential_id, false
change_column_null :jobs, :display_id, false
```

### Passo 3: Criar Concern (código acima)

### Passo 4: Aplicar nos Models

### Passo 5: Atualizar Controllers e Serializers

### Passo 6: Atualizar Frontend

**Total: ~2-3 dias de dev** (vs 8-12 dias da solução complexa!)

---

## 🧪 Testes Essenciais

```ruby
# spec/models/job_spec.rb
RSpec.describe Job do
  let(:team) { create(:team, subdomain: 'acme') }

  it 'generates sequential_id per team' do
    job1 = create(:job, team: team)
    job2 = create(:job, team: team)

    expect(job1.sequential_id).to eq(1)
    expect(job2.sequential_id).to eq(2)
  end

  it 'generates formatted display_id' do
    job = create(:job, team: team)
    expect(job.display_id).to eq('ACM-JOB-001')
  end

  it 'isolates sequences between teams' do
    team2 = create(:team, subdomain: 'other')

    job1 = create(:job, team: team)
    job2 = create(:job, team: team2)

    expect(job1.sequential_id).to eq(1)
    expect(job2.sequential_id).to eq(1)
    expect(job1.display_id).to eq('ACM-JOB-001')
    expect(job2.display_id).to eq('OTH-JOB-001')
  end
end
```

---

## ⚠️ Notas Importantes da Gem Sequenced

1. **PostgreSQL Only**: Gem é thread-safe **apenas para PostgreSQL**
   - Se usar MySQL/SQLite: adicionar lock manual ou aceitar race conditions

2. **Índices Únicos**: SEMPRE adicionar índice único em `[team_id, sequential_id]`

3. **Not Null**: Tornar `sequential_id` e `display_id` NOT NULL

4. **Skip Condition**: Se precisar pular numeração em certos casos:
   ```ruby
   acts_as_sequenced scope: :team_id, skip: -> { draft? }
   ```

---

## 📈 Estimativa de Esforço

| Fase | Tempo |
|------|-------|
| Setup gem + migrations | 2h |
| Implementar concern | 1h |
| Aplicar em 5 models | 1h |
| Atualizar controllers/serializers | 2h |
| Frontend (types + services + UI) | 3h |
| Testes | 3h |
| **TOTAL** | **12h (~2 dias)** |

---

## 🎉 Vantagens vs Solução Manual

| Aspecto | Com Gem | Solução Manual |
|---------|---------|----------------|
| Código | ~30 linhas concern | ~100 linhas concern |
| Thread-safety | Garantido (PG) | Precisa implementar locks |
| Battle-tested | ✅ Usado em produção | ⚠️ Precisa testar |
| Tempo dev | 2 dias | 8-12 dias |
| Manutenção | Gem atualiza | Você mantém |

---

## ❓ Qual Opção Você Prefere?

1. **Opção A**: `sequential_id` + `display_id` (separados)
   - Menos radical
   - FKs mantêm bigint

2. **Opção B**: String como Primary Key
   - Mais simples
   - Requer mudar FKs

Qual faz mais sentido para o seu caso?
