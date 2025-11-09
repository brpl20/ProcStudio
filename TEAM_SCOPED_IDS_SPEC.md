# Especificação: Sistema de IDs Baseados em Equipes (Team-Scoped IDs)

## 📋 Análise do Problema Atual

### Situação Atual
- **IDs Globais**: BigInt sequencial (1, 2, 3...) compartilhado entre TODAS as equipes
- **Vazamento de Informações**: Equipes podem inferir volume de dados de outras equipes
- **UX Ruim**: Usuários veem "pulos" nos IDs (Job #1, #5, #23...) sem explicação
- **Previsibilidade**: IDs sequenciais facilitam ataques de enumeração
- **Confusão**: Customer ID ≠ Job ID causa ambiguidade

### Problemas Identificados

```
Equipe A cria Job ID: 1, 2, 3
Equipe B cria Job ID: 4, 5, 6
Equipe A cria Job ID: 7        ← Usuário vê: #1, #2, #3, #7 (onde está #4-6?)
```

**Impactos:**
1. ❌ **Segurança**: Vazamento de informações sobre volume total do sistema
2. ❌ **Usabilidade**: Sequências com "pulos" confundem usuários
3. ❌ **Escalabilidade**: Limite de BigInt compartilhado entre teams
4. ❌ **Multi-tenancy**: Violação de isolamento conceitual entre equipes

---

## 🎯 Objetivos da Solução

### Requisitos Funcionais
- [x] IDs únicos **por equipe** (Team A pode ter Job #1 E Team B pode ter Job #1)
- [x] Sequência contínua **visível ao usuário** (1, 2, 3, 4... sem pulos)
- [x] Compatibilidade com sistema de segurança atual (`team_scoped()`)
- [x] Suporte a múltiplos tipos de entidades (Job, Work, Office, Document, Procedure)

### Requisitos Não-Funcionais
- [x] **Performance**: Sem degradação nas queries existentes
- [x] **Migração**: Dados existentes devem ser preservados
- [x] **Backward Compatibility**: APIs devem suportar IDs antigos temporariamente
- [x] **Type Safety**: TypeScript deve validar tipos de IDs

---

## 🔍 Opções de Solução Avaliadas

### Opção 1: IDs Compostos (team_id + sequence) ⭐ **RECOMENDADA**

```ruby
# Estrutura
ID Interno (DB):  BigInt global (mantém compatibilidade)
ID Display:       "TEAM_PREFIX-ENTITY-SEQUENCE"

Exemplos:
  Job:       "ABC-JOB-001", "ABC-JOB-002"
  Work:      "ABC-WRK-001", "ABC-WRK-002"
  Office:    "ABC-OFF-001"
  Document:  "ABC-DOC-001"
```

**Vantagens:**
- ✅ IDs legíveis e descritivos
- ✅ Fácil identificar tipo de entidade
- ✅ Não requer alteração de schema (adiciona coluna)
- ✅ Permite migração gradual
- ✅ UUIDs internos mantêm unicidade global

**Desvantagens:**
- ⚠️ Mudança de tipo (number → string) no frontend
- ⚠️ URLs ficam mais longas
- ⚠️ Precisa gerenciar sequências por team+entity

---

### Opção 2: Apenas Sequência Numérica por Team

```ruby
# Estrutura
ID Interno (DB):  UUID
ID Display:       Integer sequencial por team

Exemplos:
  Team A - Job 1, 2, 3
  Team B - Job 1, 2, 3 (duplicado, ok porque team diferente)
```

**Vantagens:**
- ✅ Simples para o usuário (números pequenos)
- ✅ Sequência contínua garantida

**Desvantagens:**
- ❌ Ambiguidade entre entidades (Job #1 vs Work #1)
- ❌ IDs compostos em URLs (`/teams/:team_id/jobs/:job_id`)
- ❌ Migração complexa (trocar BigInt por UUID)

---

### Opção 3: Prefixo de Team + Sequência Global

```ruby
# Estrutura
ID Display: "ABC-123", "ABC-124", "XYZ-456"
            (ABC = team, 123 = ID global do job)
```

**Vantagens:**
- ✅ Implementação mais simples
- ✅ Mantém IDs globais únicos

**Desvantagens:**
- ❌ Não resolve "pulos" (ABC-001, ABC-005, ABC-023...)
- ❌ Ainda vaza informação sobre volume total

---

## ✅ Solução Recomendada: Opção 1 (IDs Compostos)

### Arquitetura Proposta

```
┌─────────────────────────────────────────────────────────────┐
│                     DATABASE LAYER                          │
├─────────────────────────────────────────────────────────────┤
│ jobs                                                        │
│  - id (bigint, PK)           [Mantém compatibilidade]      │
│  - team_id (bigint, FK)                                     │
│  - display_id (string)       [NOVO: "ABC-JOB-001"]         │
│  - sequence_number (integer) [NOVO: 1, 2, 3...]            │
│                                                             │
│ Constraint:                                                 │
│   UNIQUE(team_id, sequence_number) per entity               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    RAILS MODEL LAYER                        │
├─────────────────────────────────────────────────────────────┤
│ Concern: TeamScopedIdentifier                               │
│                                                             │
│  before_create :generate_team_scoped_id                     │
│                                                             │
│  def generate_team_scoped_id                                │
│    self.sequence_number = next_sequence_for_team            │
│    self.display_id = format_display_id                      │
│  end                                                        │
│                                                             │
│  def to_param                                               │
│    display_id  # Usado em URLs                              │
│  end                                                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   SERIALIZER LAYER                          │
├─────────────────────────────────────────────────────────────┤
│ JobSerializer                                               │
│                                                             │
│  attributes :id, :display_id, :sequence_number              │
│                                                             │
│  # API retorna:                                             │
│  {                                                          │
│    "id": "ABC-JOB-001",        # display_id como ID         │
│    "internal_id": 42,           # BigInt (opcional)         │
│    "sequence_number": 1         # Para sorting              │
│  }                                                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND LAYER                           │
├─────────────────────────────────────────────────────────────┤
│ TypeScript Types:                                           │
│                                                             │
│  interface Job {                                            │
│    id: string;              // "ABC-JOB-001"                │
│    sequenceNumber: number;  // 1 (para sorting/display)    │
│  }                                                          │
│                                                             │
│ API Service:                                                │
│  - Aceita string IDs em URLs                                │
│  - GET /api/v1/jobs/ABC-JOB-001                             │
│                                                             │
│ UI Components:                                              │
│  <td>{job.id}</td>         → "ABC-JOB-001"                  │
│  <td>#{job.sequenceNumber}</td> → "#1" (se preferir curto) │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Especificação Técnica Detalhada

### 1. Schema Database (Rails Migration)

```ruby
# db/migrate/XXXXXX_add_team_scoped_ids_to_jobs.rb
class AddTeamScopedIdsToJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :jobs, :display_id, :string
    add_column :jobs, :sequence_number, :integer

    add_index :jobs, :display_id, unique: true
    add_index :jobs, [:team_id, :sequence_number], unique: true,
              name: 'index_jobs_on_team_sequence'

    # Migrar dados existentes
    reversible do |dir|
      dir.up do
        Team.find_each do |team|
          team.jobs.order(:id).each_with_index do |job, index|
            sequence = index + 1
            display_id = format_display_id(team, 'JOB', sequence)

            job.update_columns(
              sequence_number: sequence,
              display_id: display_id
            )
          end
        end
      end
    end

    # Tornar obrigatório após migração
    change_column_null :jobs, :display_id, false
    change_column_null :jobs, :sequence_number, false
  end

  private

  def format_display_id(team, entity_prefix, sequence)
    team_prefix = team.subdomain&.upcase&.first(3) || "T#{team.id}"
    "#{team_prefix}-#{entity_prefix}-#{sequence.to_s.rjust(3, '0')}"
  end
end
```

**Aplicar para outras entidades:**
- `AddTeamScopedIdsToWorks`
- `AddTeamScopedIdsToOffices`
- `AddTeamScopedIdsToDocuments`
- `AddTeamScopedIdsToProcedures`

---

### 2. Model Concern (Reusável)

```ruby
# app/models/concerns/team_scoped_identifier.rb
module TeamScopedIdentifier
  extend ActiveSupport::Concern

  included do
    before_validation :generate_team_scoped_id, on: :create
    validates :sequence_number, presence: true,
              uniqueness: { scope: :team_id }
    validates :display_id, presence: true, uniqueness: true
  end

  # Override to_param para usar display_id em URLs
  def to_param
    display_id
  end

  private

  def generate_team_scoped_id
    return if display_id.present? # Já gerado

    self.sequence_number = next_sequence_number
    self.display_id = format_display_id
  end

  def next_sequence_number
    # Thread-safe: usa lock da database
    max_sequence = self.class
      .where(team_id: team_id)
      .lock
      .maximum(:sequence_number) || 0

    max_sequence + 1
  end

  def format_display_id
    team_prefix = team.subdomain&.upcase&.first(3) || "T#{team_id}"
    entity_prefix = self.class.name.upcase.first(3)
    sequence_str = sequence_number.to_s.rjust(3, '0')

    "#{team_prefix}-#{entity_prefix}-#{sequence_str}"
  end

  module ClassMethods
    # Finder que aceita tanto display_id quanto id numérico
    def find_by_any_id(identifier)
      if identifier.to_s.include?('-')
        find_by!(display_id: identifier)
      else
        find(identifier) # Fallback para IDs numéricos (migração)
      end
    end
  end
end
```

---

### 3. Atualização dos Models

```ruby
# app/models/job.rb
class Job < ApplicationRecord
  include TeamScopedIdentifier

  belongs_to :team
  # ... resto do model
end

# app/models/work.rb
class Work < ApplicationRecord
  include TeamScopedIdentifier

  belongs_to :team
  # ... resto do model
end

# Aplicar em: Office, Document, Procedure
```

---

### 4. Atualização dos Controllers

```ruby
# app/controllers/api/v1/jobs_controller.rb
class Api::V1::JobsController < ApplicationController
  def show
    # Suporta tanto "123" quanto "ABC-JOB-001"
    @job = team_scoped(Job).find_by_any_id(params[:id])
    render_job
  end

  def index
    @jobs = team_scoped(Job).order(sequence_number: :desc)
    # Ordenar por sequence_number em vez de id
    render_jobs
  end

  # ... resto do controller
end
```

---

### 5. Atualização dos Serializers

```ruby
# app/serializers/job_serializer.rb
class JobSerializer
  include JSONAPI::Serializer

  # display_id como ID principal
  attribute :id do |job|
    job.display_id
  end

  # ID numérico para compatibilidade (opcional, pode remover depois)
  attribute :internal_id do |job|
    job.id
  end

  attribute :sequence_number
  attribute :display_id

  # Outros atributos...
  attributes :title, :description, :status, :priority

  belongs_to :team
  belongs_to :work
  belongs_to :profile_customer
end
```

---

### 6. Frontend - Atualização de Types

```typescript
// frontend/src/lib/api/types/job.types.ts
export interface Job {
  id: string;              // MUDANÇA: number → string
  displayId: string;       // "ABC-JOB-001" (redundante com id)
  sequenceNumber: number;  // 1, 2, 3... para sorting
  internalId?: number;     // Opcional, para migração

  // Outros campos
  title: string;
  description?: string;
  status: JobStatus;
  priority: JobPriority;

  // Relacionamentos (também mudam para string)
  teamId: string;
  workId: string;
  customerId: string;
  assigneeIds: string[];
}

// Aplicar em: Work, Office, Document, Procedure
```

---

### 7. Frontend - Atualização de Services

```typescript
// frontend/src/lib/api/services/job.service.ts
export class JobService extends BaseService {
  async getJob(id: string): Promise<Job> {  // MUDANÇA: string em vez de number
    const response = await this.httpClient.get(`/jobs/${id}`);
    return this.parseJob(response.data);
  }

  async listJobs(filters?: JobFilters): Promise<Job[]> {
    const response = await this.httpClient.get('/jobs', { params: filters });
    return response.data.data.map(this.parseJob);
  }

  private parseJob(jsonApiData: any): Job {
    return {
      id: jsonApiData.id,  // Já vem como string "ABC-JOB-001"
      displayId: jsonApiData.attributes.display_id,
      sequenceNumber: jsonApiData.attributes.sequence_number,
      internalId: jsonApiData.attributes.internal_id,  // Opcional

      title: jsonApiData.attributes.title,
      status: jsonApiData.attributes.status,
      // ... outros campos
    };
  }

  async createJob(data: CreateJobDto): Promise<Job> {
    const response = await this.httpClient.post('/jobs', {
      data: {
        type: 'jobs',
        attributes: data
      }
    });
    return this.parseJob(response.data.data);
  }

  async updateJob(id: string, data: Partial<CreateJobDto>): Promise<Job> {
    const response = await this.httpClient.patch(`/jobs/${id}`, {
      data: {
        type: 'jobs',
        id: id,
        attributes: data
      }
    });
    return this.parseJob(response.data.data);
  }
}
```

---

### 8. Frontend - Atualização de UI Components

```svelte
<!-- frontend/src/lib/components/jobs/JobList.svelte -->
<script lang="ts">
  import type { Job } from '$lib/api/types/job.types';

  export let jobs: Job[];

  // Ordenar por sequence_number
  $: sortedJobs = [...jobs].sort((a, b) =>
    b.sequenceNumber - a.sequenceNumber
  );

  function handleSearch(term: string) {
    return sortedJobs.filter(job =>
      job.id.toLowerCase().includes(term.toLowerCase()) ||
      job.title.toLowerCase().includes(term.toLowerCase()) ||
      job.sequenceNumber.toString().includes(term)
    );
  }
</script>

<table>
  <thead>
    <tr>
      <th>#</th>
      <th>ID</th>
      <th>Título</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    {#each sortedJobs as job}
      <tr on:click={() => navigateTo(`/jobs/${job.id}`)}>
        <td class="text-muted">#{job.sequenceNumber}</td>
        <td>
          <code class="job-id">{job.id}</code>
        </td>
        <td>{job.title}</td>
        <td>
          <StatusBadge status={job.status} />
        </td>
      </tr>
    {/each}
  </tbody>
</table>

<style>
  .job-id {
    font-family: 'Fira Code', monospace;
    font-size: 0.85rem;
    background: var(--color-bg-code);
    padding: 2px 6px;
    border-radius: 3px;
  }
</style>
```

---

### 9. Formato de IDs por Entidade

| Entidade   | Prefixo | Exemplo          | Descrição           |
|------------|---------|------------------|---------------------|
| Job        | JOB     | `ABC-JOB-001`    | Tarefas/trabalhos   |
| Work       | WRK     | `ABC-WRK-001`    | Processos/casos     |
| Office     | OFF     | `ABC-OFF-001`    | Escritórios         |
| Document   | DOC     | `ABC-DOC-001`    | Documentos          |
| Procedure  | PRC     | `ABC-PRC-001`    | Procedimentos       |
| User       | USR     | `ABC-USR-001`    | Usuários (opcional) |

**Formato Geral:**
```
{TEAM_PREFIX}-{ENTITY_PREFIX}-{SEQUENCE}

TEAM_PREFIX: 3 caracteres do subdomain (ex: "ABC") ou "T{id}" se não houver
ENTITY_PREFIX: 3 caracteres fixos por tipo
SEQUENCE: 3+ dígitos com zero-padding (001, 002, ..., 999, 1000)
```

---

## 📊 Plano de Implementação

### Fase 1: Preparação (1-2 dias)
- [ ] **1.1** Criar migrations para adicionar `display_id` e `sequence_number`
- [ ] **1.2** Implementar concern `TeamScopedIdentifier`
- [ ] **1.3** Migrar dados existentes (preencher display_id/sequence_number)
- [ ] **1.4** Testes unitários do concern
- [ ] **1.5** Validar unicidade e integridade dos dados migrados

### Fase 2: Backend (2-3 dias)
- [ ] **2.1** Incluir concern nos models (Job, Work, Office, Document, Procedure)
- [ ] **2.2** Atualizar controllers para usar `find_by_any_id`
- [ ] **2.3** Atualizar serializers para retornar `display_id` como `id`
- [ ] **2.4** Atualizar testes de integração
- [ ] **2.5** Validar ordenação por `sequence_number`

### Fase 3: Frontend - Types & Services (1-2 dias)
- [ ] **3.1** Atualizar types: `id: number` → `id: string`
- [ ] **3.2** Atualizar services para aceitar string IDs
- [ ] **3.3** Remover `parseInt()` nos parsers
- [ ] **3.4** Atualizar testes unitários dos services
- [ ] **3.5** Validar type safety com TypeScript

### Fase 4: Frontend - UI (2 dias)
- [ ] **4.1** Atualizar componentes de listagem (JobList, WorkList, etc.)
- [ ] **4.2** Atualizar componentes de detalhes/formulários
- [ ] **4.3** Atualizar lógica de busca/filtro
- [ ] **4.4** Melhorar exibição visual dos IDs (badges, códigos)
- [ ] **4.5** Testes E2E de fluxos críticos

### Fase 5: Testes & Validação (1-2 dias)
- [ ] **5.1** Testes de criação de novos registros
- [ ] **5.2** Testes de acesso a registros existentes (IDs antigos)
- [ ] **5.3** Testes de unicidade e concorrência
- [ ] **5.4** Testes de segurança (isolamento entre teams)
- [ ] **5.5** Testes de performance (índices, queries)

### Fase 6: Deployment & Monitoramento (1 dia)
- [ ] **6.1** Deploy em staging
- [ ] **6.2** Testes de regressão completos
- [ ] **6.3** Treinamento do time (se necessário)
- [ ] **6.4** Deploy em produção
- [ ] **6.5** Monitorar logs e métricas

### Fase 7: Cleanup (1 dia - após 2 semanas)
- [ ] **7.1** Remover suporte a IDs numéricos antigos (`find_by_any_id`)
- [ ] **7.2** Remover campo `internal_id` dos serializers
- [ ] **7.3** Remover campo `internalId` dos types do frontend
- [ ] **7.4** Atualizar documentação

**Total Estimado: 8-12 dias de desenvolvimento**

---

## 🔒 Considerações de Segurança

### 1. Isolamento de Teams
```ruby
# ANTES (vulnerável a vazamento de informação)
Job.find(params[:id])  # Pode acessar jobs de outros teams

# DEPOIS (seguro)
team_scoped(Job).find_by_any_id(params[:id])
# Retorna 404 se job não pertencer ao team atual
```

### 2. Prevenção de Enumeração
```ruby
# ANTES
# Atacante pode iterar /jobs/1, /jobs/2, /jobs/3...
# e contar total de jobs do sistema

# DEPOIS
# /jobs/ABC-JOB-001 não revela informação sobre outros teams
# Sequências são isoladas por team
```

### 3. Rate Limiting
```ruby
# Adicionar rate limiting para prevenir brute-force
# de IDs mesmo com prefixo
class Api::V1::JobsController < ApplicationController
  before_action :rate_limit_by_ip, only: [:show]

  def rate_limit_by_ip
    # Implementar com Rack::Attack ou similar
  end
end
```

---

## 🧪 Testes Essenciais

### 1. Model Tests
```ruby
# spec/models/job_spec.rb
RSpec.describe Job, type: :model do
  let(:team) { create(:team, subdomain: 'acme') }

  describe 'team scoped identifiers' do
    it 'generates display_id on create' do
      job = create(:job, team: team)
      expect(job.display_id).to eq('ACM-JOB-001')
    end

    it 'increments sequence_number per team' do
      job1 = create(:job, team: team)
      job2 = create(:job, team: team)

      expect(job1.sequence_number).to eq(1)
      expect(job2.sequence_number).to eq(2)
    end

    it 'allows same sequence_number for different teams' do
      team2 = create(:team, subdomain: 'other')

      job1 = create(:job, team: team)   # ACM-JOB-001
      job2 = create(:job, team: team2)  # OTH-JOB-001

      expect(job1.sequence_number).to eq(1)
      expect(job2.sequence_number).to eq(1)
    end

    it 'prevents duplicate display_id' do
      job1 = create(:job, team: team, display_id: 'ACM-JOB-001')

      expect {
        create(:job, team: team, display_id: 'ACM-JOB-001')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'uses display_id in to_param' do
      job = create(:job, team: team)
      expect(job.to_param).to eq(job.display_id)
    end
  end

  describe '.find_by_any_id' do
    let!(:job) { create(:job, team: team) }

    it 'finds by display_id' do
      found = Job.find_by_any_id(job.display_id)
      expect(found).to eq(job)
    end

    it 'finds by numeric id (backward compatibility)' do
      found = Job.find_by_any_id(job.id)
      expect(found).to eq(job)
    end
  end
end
```

### 2. Controller Tests
```ruby
# spec/controllers/api/v1/jobs_controller_spec.rb
RSpec.describe Api::V1::JobsController, type: :controller do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team) }
  let!(:job) { create(:job, team: team) }

  before { sign_in user }

  describe 'GET #show' do
    it 'finds job by display_id' do
      get :show, params: { id: job.display_id }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(job.display_id)
    end

    it 'prevents access to other team jobs' do
      other_team = create(:team)
      other_job = create(:job, team: other_team)

      get :show, params: { id: other_job.display_id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #index' do
    it 'orders by sequence_number desc' do
      job2 = create(:job, team: team)
      job3 = create(:job, team: team)

      get :index
      ids = json_response['data'].map { |j| j['id'] }

      expect(ids).to eq([job3.display_id, job2.display_id, job.display_id])
    end
  end
end
```

### 3. Frontend Tests
```typescript
// frontend/src/lib/api/services/job.service.test.ts
import { describe, it, expect, vi } from 'vitest';
import { JobService } from './job.service';

describe('JobService', () => {
  const mockHttpClient = {
    get: vi.fn(),
    post: vi.fn(),
    patch: vi.fn(),
  };

  const service = new JobService(mockHttpClient);

  it('accepts string IDs', async () => {
    mockHttpClient.get.mockResolvedValue({
      data: {
        data: {
          id: 'ABC-JOB-001',
          attributes: {
            display_id: 'ABC-JOB-001',
            sequence_number: 1,
            title: 'Test Job'
          }
        }
      }
    });

    const job = await service.getJob('ABC-JOB-001');

    expect(job.id).toBe('ABC-JOB-001');
    expect(job.sequenceNumber).toBe(1);
    expect(mockHttpClient.get).toHaveBeenCalledWith('/jobs/ABC-JOB-001');
  });

  it('parses job without parseInt', async () => {
    // Teste que parseInt foi removido e ID é mantido como string
    const job = service['parseJob']({
      id: 'ABC-JOB-001',
      attributes: { sequence_number: 1 }
    });

    expect(typeof job.id).toBe('string');
  });
});
```

---

## 📈 Migração de Dados Existentes

### Script de Migração Seguro

```ruby
# db/migrate/XXXXXX_migrate_existing_ids.rb
class MigrateExistingIds < ActiveRecord::Migration[7.0]
  def up
    say "Migrando IDs existentes para team-scoped IDs..."

    # Processar por team para garantir sequências corretas
    Team.find_each do |team|
      say "  Processando team: #{team.name} (ID: #{team.id})"

      migrate_entity(team, Job, 'JOB')
      migrate_entity(team, Work, 'WRK')
      migrate_entity(team, Office, 'OFF')
      migrate_entity(team, Document, 'DOC')
      migrate_entity(team, Procedure, 'PRC')
    end

    say "Migração concluída!"
  end

  def down
    # Remover display_id e sequence_number
    Job.update_all(display_id: nil, sequence_number: nil)
    Work.update_all(display_id: nil, sequence_number: nil)
    Office.update_all(display_id: nil, sequence_number: nil)
    Document.update_all(display_id: nil, sequence_number: nil)
    Procedure.update_all(display_id: nil, sequence_number: nil)
  end

  private

  def migrate_entity(team, model, prefix)
    records = model.where(team_id: team.id).order(:id)
    total = records.count

    return if total.zero?

    say "    Migrando #{total} #{model.name.pluralize}..."

    records.each_with_index do |record, index|
      sequence = index + 1
      display_id = format_display_id(team, prefix, sequence)

      record.update_columns(
        sequence_number: sequence,
        display_id: display_id,
        updated_at: record.updated_at # Preservar timestamp
      )

      print '.' if (sequence % 100).zero?
    end

    puts " ✓"
  end

  def format_display_id(team, entity_prefix, sequence)
    team_prefix = if team.subdomain.present?
      team.subdomain.upcase.first(3)
    else
      "T#{team.id.to_s.rjust(2, '0')}"
    end

    sequence_str = sequence.to_s.rjust(3, '0')
    "#{team_prefix}-#{entity_prefix}-#{sequence_str}"
  end
end
```

### Validação Pós-Migração

```ruby
# lib/tasks/validate_team_scoped_ids.rake
namespace :db do
  desc "Validate team scoped IDs integrity"
  task validate_team_scoped_ids: :environment do
    errors = []

    [Job, Work, Office, Document, Procedure].each do |model|
      puts "Validating #{model.name.pluralize}..."

      # 1. Verificar que todos têm display_id e sequence_number
      missing = model.where(display_id: nil).or(model.where(sequence_number: nil))
      if missing.any?
        errors << "#{model.name}: #{missing.count} records sem display_id/sequence_number"
      end

      # 2. Verificar unicidade de display_id
      duplicates = model.group(:display_id).having('COUNT(*) > 1').count
      if duplicates.any?
        errors << "#{model.name}: display_ids duplicados: #{duplicates.keys.join(', ')}"
      end

      # 3. Verificar sequências por team
      Team.find_each do |team|
        sequences = model.where(team: team).pluck(:sequence_number).sort
        expected = (1..sequences.size).to_a

        unless sequences == expected
          errors << "#{model.name} (Team #{team.id}): sequência inválida. " \
                    "Esperado: #{expected.inspect}, Atual: #{sequences.inspect}"
        end
      end
    end

    if errors.any?
      puts "\n❌ ERROS ENCONTRADOS:"
      errors.each { |e| puts "  - #{e}" }
      exit 1
    else
      puts "\n✅ Validação concluída com sucesso!"
    end
  end
end
```

---

## 🎨 UX/UI Improvements

### Exibição de IDs no Frontend

```svelte
<!-- Opção 1: ID Completo como Badge -->
<span class="job-id-badge">
  <span class="team-prefix">ABC</span>
  <span class="separator">-</span>
  <span class="entity-type">JOB</span>
  <span class="separator">-</span>
  <span class="sequence">001</span>
</span>

<!-- Opção 2: Apenas Sequência (mais limpo) -->
<div class="job-header">
  <span class="sequence-number">#1</span>
  <h2>{job.title}</h2>
  <code class="full-id">{job.id}</code>
</div>

<!-- Opção 3: Com Tooltip -->
<span
  class="job-reference"
  title="ID Completo: {job.id}"
  data-clipboard="{job.id}"
>
  #{job.sequenceNumber}
</span>
```

### Estilos CSS Sugeridos

```css
/* IDs como código legível */
.job-id-badge {
  font-family: 'Fira Code', 'Courier New', monospace;
  font-size: 0.875rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 4px 10px;
  border-radius: 6px;
  font-weight: 500;
  letter-spacing: 0.5px;
}

.job-id-badge .separator {
  opacity: 0.6;
  margin: 0 2px;
}

/* Número de sequência destacado */
.sequence-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: var(--color-primary-100);
  color: var(--color-primary-700);
  border-radius: 50%;
  font-weight: 600;
  font-size: 0.875rem;
}

/* ID completo discreto */
.full-id {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  background: var(--color-bg-secondary);
  padding: 2px 6px;
  border-radius: 3px;
  cursor: pointer;
}

.full-id:hover {
  background: var(--color-bg-hover);
}
```

---

## 📚 Documentação para Desenvolvedores

### Como Usar Team Scoped IDs

```ruby
# ✅ CORRETO: Buscar registros
job = team_scoped(Job).find_by_any_id('ABC-JOB-001')
job = team_scoped(Job).find_by_any_id(123)  # Backward compatible

# ✅ CORRETO: Criar registros (ID gerado automaticamente)
job = Job.create!(
  team: current_team,
  title: 'Nova tarefa'
)
# job.display_id => "ABC-JOB-001"
# job.sequence_number => 1

# ✅ CORRETO: URLs
job_path(job)  # => "/jobs/ABC-JOB-001" (usa to_param)

# ❌ ERRADO: Não usar find sem team_scoped
Job.find('ABC-JOB-001')  # Pode acessar jobs de outros teams!

# ❌ ERRADO: Não setar display_id manualmente
job.display_id = 'ABC-JOB-999'  # Vai quebrar sequência!
```

### Frontend Best Practices

```typescript
// ✅ CORRETO: Usar string IDs
interface Job {
  id: string;  // "ABC-JOB-001"
}

// ✅ CORRETO: Passar IDs em URLs
fetch(`/api/v1/jobs/${job.id}`)

// ✅ CORRETO: Comparar IDs
if (job.id === selectedJobId) { ... }

// ❌ ERRADO: Converter para number
parseInt(job.id)  // Não vai funcionar com IDs com prefixo!

// ❌ ERRADO: Assumir IDs numéricos
jobs.sort((a, b) => a.id - b.id)  // Use sequenceNumber!

// ✅ CORRETO: Ordenar por sequence
jobs.sort((a, b) => a.sequenceNumber - b.sequenceNumber)
```

---

## 🚀 Rollout Plan

### Semana 1: Backend + Migração
- Implementar concern e migrations
- Migrar dados existentes
- Testes unitários e integração
- Deploy em staging

### Semana 2: Frontend + Testes
- Atualizar types e services
- Atualizar UI components
- Testes E2E
- QA em staging

### Semana 3: Production + Monitoring
- Deploy gradual em produção (feature flag opcional)
- Monitorar performance e erros
- Coletar feedback de usuários
- Ajustes finos

### Semana 4: Cleanup
- Remover código de compatibilidade
- Remover feature flags
- Documentação final
- Retrospectiva

---

## 🔍 Métricas de Sucesso

### Técnicas
- ✅ 100% dos registros com `display_id` válido
- ✅ 0 conflitos de unicidade
- ✅ Tempo de resposta < 200ms (mesmo após mudança)
- ✅ 0 erros 500 relacionados a IDs
- ✅ 100% cobertura de testes

### Negócio
- ✅ Usuários reportam sequências "contínuas"
- ✅ Redução de confusão sobre "pulos" em IDs
- ✅ Melhor rastreabilidade de entidades
- ✅ Feedback positivo sobre nova UX

---

## 📞 Pontos de Atenção

### ⚠️ Cuidados Durante Implementação

1. **Concorrência**: Usar `lock` na query de `next_sequence_number`
2. **Migração**: Executar em horário de baixo tráfego
3. **Rollback**: Manter IDs numéricos como fallback temporário
4. **Performance**: Adicionar índices ANTES de tornar campos obrigatórios
5. **Cache**: Invalidar caches que usam IDs numéricos
6. **URLs antigas**: Considerar redirects de IDs numéricos para display_id

### 🐛 Troubleshooting Comum

**Problema**: "Sequence number já existe"
**Solução**: Verificar se migration rodou corretamente e se não há registros duplicados

**Problema**: "Display ID não único"
**Solução**: Verificar se múltiplos workers estão criando registros simultaneamente (usar lock)

**Problema**: "404 ao buscar por ID antigo"
**Solução**: Garantir que `find_by_any_id` está sendo usado nos controllers

---

## 📖 Referências

- [Rails Composite Primary Keys](https://api.rubyonrails.org/classes/ActiveRecord/CompositeKey.html)
- [JSONAPI Specification](https://jsonapi.org/format/#document-resource-object-identification)
- [TypeScript String Literal Types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)
- [Friendly IDs Pattern](https://github.com/norman/friendly_id)

---

## ✅ Checklist de Implementação

### Backend
- [ ] Criar concern `TeamScopedIdentifier`
- [ ] Criar migrations para todas entidades
- [ ] Implementar `find_by_any_id` em models
- [ ] Atualizar controllers para usar team-scoped finders
- [ ] Atualizar serializers para retornar `display_id`
- [ ] Adicionar índices de performance
- [ ] Escrever testes unitários (models)
- [ ] Escrever testes de integração (controllers)
- [ ] Executar migração de dados
- [ ] Validar integridade pós-migração

### Frontend
- [ ] Atualizar types: `id: string`
- [ ] Remover `parseInt()` dos parsers
- [ ] Atualizar services para aceitar string IDs
- [ ] Atualizar componentes de listagem
- [ ] Atualizar componentes de formulários
- [ ] Melhorar exibição visual de IDs
- [ ] Atualizar lógica de busca/filtro
- [ ] Escrever testes unitários (services)
- [ ] Escrever testes E2E (fluxos críticos)
- [ ] Validar type safety com TypeScript

### DevOps
- [ ] Planejar janela de manutenção
- [ ] Backup de produção
- [ ] Deploy em staging
- [ ] Testes de regressão em staging
- [ ] Deploy em produção
- [ ] Monitorar logs e métricas
- [ ] Planejar rollback se necessário

### Documentação
- [ ] Atualizar README com novos formatos de ID
- [ ] Documentar API changes (se houver versioning)
- [ ] Criar guia de migração para desenvolvedores
- [ ] Atualizar documentação de usuário (se houver)

---

**Versão**: 1.0
**Data**: 2025-11-09
**Autor**: Claude Code
**Status**: 📝 Especificação Pronta para Implementação
