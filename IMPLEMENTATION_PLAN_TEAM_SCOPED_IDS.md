# Plano de Implementação: Team-Scoped IDs com Soft/Hard Delete

## 📋 Contexto do Sistema Atual

### Sistema de Soft Delete (JÁ IMPLEMENTADO)
O sistema **JÁ usa** a gem `paranoia` (`acts_as_paranoid`) para soft delete:
- Models com soft delete: Job, Work, Office, Document, Procedure
- Campo: `deleted_at` (datetime)
- Comportamento: `destroy` marca `deleted_at` em vez de remover do banco

### Problema a Resolver
**IDs globais sequenciais** (1, 2, 3...) compartilhados entre todas as equipes causam:
- "Pulos" nas sequências para usuários de cada team
- Vazamento de informações sobre volume total do sistema
- IDs não amigáveis

## 🎯 Objetivo da Implementação

Implementar **IDs baseados em equipes** com:
1. ✅ Sequências isoladas por team (1, 2, 3... por team)
2. ✅ Formato amigável em **minúsculas**: `abc-job-001`, `abc-wrk-001`
3. ✅ Soft delete mantido (usando `acts_as_paranoid`)
4. ✅ Hard delete com timer de 5 minutos (control-z / desfazer)
5. ✅ Usar gem `sequenced` para automação

## 📦 Dependências e Gems

### Adicionar ao Gemfile

```ruby
# Gemfile (adicionar)
gem 'sequenced'  # Sequências automáticas por escopo
# Nota: paranoia já está instalado (acts_as_paranoid)
```

Executar:
```bash
cd api
bundle install
```

## 🗺️ Modelos a Serem Alterados

### Modelos Prioritários (com team_id direto)

| Modelo | Team ID | Soft Delete | Prefixo | Exemplo |
|--------|---------|-------------|---------|---------|
| Job | ✅ team_id | ✅ acts_as_paranoid | job | `abc-job-001` |
| Work | ✅ team_id | ✅ acts_as_paranoid | wrk | `abc-wrk-001` |
| Office | ✅ team_id | ✅ acts_as_paranoid | off | `abc-off-001` |
| Document | ❌ via work | ✅ acts_as_paranoid | doc | `abc-doc-001` |
| Procedure | ❌ via work | ✅ acts_as_paranoid | prc | `abc-prc-001` |

### Modelos Secundários (podem ser implementados depois)

| Modelo | Team ID | Soft Delete | Prefixo | Exemplo |
|--------|---------|-------------|---------|---------|
| Draft | ✅ team_id | ❌ não | dft | `abc-dft-001` |
| Notification | ✅ team_id | ❌ não | ntf | `abc-ntf-001` |

## 🛠️ Implementação Passo a Passo

---

## PASSO 1: Migrations - Adicionar Campos de ID

### 1.1 Migration para Jobs

```bash
cd api
rails generate migration AddTeamScopedIdsToJobs sequential_id:integer display_id:string
```

Editar o arquivo gerado:

```ruby
# api/db/migrate/XXXXXX_add_team_scoped_ids_to_jobs.rb
class AddTeamScopedIdsToJobs < ActiveRecord::Migration[7.0]
  def change
    # Adicionar colunas
    add_column :jobs, :sequential_id, :integer
    add_column :jobs, :display_id, :string
    add_column :jobs, :hard_delete_at, :datetime  # Para timer de hard delete

    # Índices para performance e unicidade
    add_index :jobs, :display_id, unique: true
    add_index :jobs, [:team_id, :sequential_id], unique: true,
              name: 'index_jobs_on_team_sequential'
    add_index :jobs, :hard_delete_at

    # Após adicionar, tornar obrigatório (feito em migration separada depois de popular)
  end
end
```

### 1.2 Migrations para Outros Modelos

**Work:**
```bash
rails generate migration AddTeamScopedIdsToWorks sequential_id:integer display_id:string hard_delete_at:datetime
```

```ruby
# api/db/migrate/XXXXXX_add_team_scoped_ids_to_works.rb
class AddTeamScopedIdsToWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :sequential_id, :integer
    add_column :works, :display_id, :string
    add_column :works, :hard_delete_at, :datetime

    add_index :works, :display_id, unique: true
    add_index :works, [:team_id, :sequential_id], unique: true,
              name: 'index_works_on_team_sequential'
    add_index :works, :hard_delete_at
  end
end
```

**Office:**
```bash
rails generate migration AddTeamScopedIdsToOffices sequential_id:integer display_id:string hard_delete_at:datetime
```

```ruby
# api/db/migrate/XXXXXX_add_team_scoped_ids_to_offices.rb
class AddTeamScopedIdsToOffices < ActiveRecord::Migration[7.0]
  def change
    add_column :offices, :sequential_id, :integer
    add_column :offices, :display_id, :string
    add_column :offices, :hard_delete_at, :datetime

    add_index :offices, :display_id, unique: true
    add_index :offices, [:team_id, :sequential_id], unique: true,
              name: 'index_offices_on_team_sequential'
    add_index :offices, :hard_delete_at
  end
end
```

**Document (via work.team_id):**
```bash
rails generate migration AddTeamScopedIdsToDocuments sequential_id:integer display_id:string hard_delete_at:datetime
```

```ruby
# api/db/migrate/XXXXXX_add_team_scoped_ids_to_documents.rb
class AddTeamScopedIdsToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :sequential_id, :integer
    add_column :documents, :display_id, :string
    add_column :documents, :hard_delete_at, :datetime

    add_index :documents, :display_id, unique: true
    # Document é scoped via work.team_id, não tem team_id direto
    add_index :documents, :hard_delete_at
  end
end
```

**Procedure (via work.team_id):**
```bash
rails generate migration AddTeamScopedIdsToProcedures sequential_id:integer display_id:string hard_delete_at:datetime
```

```ruby
# api/db/migrate/XXXXXX_add_team_scoped_ids_to_procedures.rb
class AddTeamScopedIdsToProcedures < ActiveRecord::Migration[7.0]
  def change
    add_column :procedures, :sequential_id, :integer
    add_column :procedures, :display_id, :string
    add_column :procedures, :hard_delete_at, :datetime

    add_index :procedures, :display_id, unique: true
    add_index :procedures, :hard_delete_at
  end
end
```

### 1.3 Executar Migrations

```bash
cd api
rails db:migrate
```

---

## PASSO 2: Concern - TeamScopedIdentifier

Criar concern reutilizável que gerencia IDs team-scoped com hard delete timer.

```ruby
# api/app/models/concerns/team_scoped_identifier.rb
module TeamScopedIdentifier
  extend ActiveSupport::Concern

  # Timer de hard delete (5 minutos)
  HARD_DELETE_GRACE_PERIOD = 5.minutes

  included do
    # Gem sequenced cuida da sequência automática por team
    acts_as_sequenced scope: :team_id, column: :sequential_id

    # Gerar display_id após sequenced atribuir sequential_id
    after_create :generate_display_id

    # Validações
    validates :display_id, presence: true, uniqueness: true, on: :update
    validates :sequential_id, presence: true,
              uniqueness: { scope: :team_id }, on: :update
  end

  # Override to_param para usar display_id em URLs
  def to_param
    display_id
  end

  # Soft delete (já implementado via acts_as_paranoid)
  # Apenas adicionar lógica de timer para hard delete
  def destroy
    if deleted_at.present? && hard_delete_scheduled?
      # Já está soft deleted e timer expirou -> hard delete
      really_destroy!
    elsif deleted_at.present?
      # Já está soft deleted -> cancelar timer ou fazer nada
      Rails.logger.info("Job #{display_id} já está deletado (soft)")
    else
      # Primeira deleção -> soft delete + agendar hard delete
      soft_delete_with_timer
    end
  end

  # Restaurar (desfazer deleção - control-z)
  def restore!
    return unless deleted_at.present?

    # Limpar soft delete e timer
    update_columns(
      deleted_at: nil,
      hard_delete_at: nil
    )

    Rails.logger.info("#{self.class.name} #{display_id} restaurado")
  end

  # Verificar se timer de hard delete expirou
  def hard_delete_scheduled?
    hard_delete_at.present? && Time.current >= hard_delete_at
  end

  # Tempo restante para hard delete
  def hard_delete_countdown
    return nil unless hard_delete_at.present?
    return 0 if hard_delete_scheduled?

    (hard_delete_at - Time.current).to_i # segundos
  end

  private

  def generate_display_id
    # sequential_id já foi atribuído pela gem sequenced
    team_prefix = team_prefix_for_id
    entity_prefix = entity_prefix_for_id
    sequence_str = sequential_id.to_s.rjust(3, '0')

    formatted_id = "#{team_prefix}-#{entity_prefix}-#{sequence_str}"

    update_column(:display_id, formatted_id)
  end

  def team_prefix_for_id
    # Usar subdomain em minúsculas (primeiros 3 caracteres)
    if team.subdomain.present? && team.subdomain.length >= 3
      team.subdomain.downcase[0..2]
    else
      # Fallback: usar "t" + id do team
      "t#{team_id.to_s.rjust(2, '0')}"
    end
  end

  def entity_prefix_for_id
    # Mapear nome do model para prefixo em minúsculas
    case self.class.name
    when 'Job'
      'job'
    when 'Work'
      'wrk'
    when 'Office'
      'off'
    when 'Document'
      'doc'
    when 'Procedure'
      'prc'
    when 'Draft'
      'dft'
    when 'Notification'
      'ntf'
    else
      # Fallback: primeiros 3 caracteres do model name
      self.class.name.downcase[0..2]
    end
  end

  def soft_delete_with_timer
    # Soft delete via acts_as_paranoid
    self.deleted_at = Time.current
    self.hard_delete_at = Time.current + HARD_DELETE_GRACE_PERIOD

    # Salvar sem callbacks (usar update_columns para não triggerar validações)
    if save
      schedule_hard_delete_job
      Rails.logger.info("#{self.class.name} #{display_id} soft deleted. Hard delete agendado para #{hard_delete_at}")
      true
    else
      false
    end
  end

  def schedule_hard_delete_job
    # Agendar job em background para hard delete
    # (se usar Sidekiq ou similar)
    HardDeleteJob.set(wait: HARD_DELETE_GRACE_PERIOD).perform_later(
      self.class.name,
      id
    )
  end

  module ClassMethods
    # Finder que aceita display_id
    def find_by_display_id(identifier)
      find_by(display_id: identifier)
    end

    def find_by_display_id!(identifier)
      find_by!(display_id: identifier)
    end

    # Encontrar registros com hard delete agendado
    def with_pending_hard_delete
      where.not(hard_delete_at: nil).where('hard_delete_at > ?', Time.current)
    end

    # Encontrar registros prontos para hard delete
    def ready_for_hard_delete
      where.not(hard_delete_at: nil).where('hard_delete_at <= ?', Time.current)
    end
  end
end
```

---

## PASSO 3: Background Job - Hard Delete

Criar job que executa hard delete após timer expirar.

```ruby
# api/app/jobs/hard_delete_job.rb
class HardDeleteJob < ApplicationJob
  queue_as :default

  def perform(model_class_name, record_id)
    model_class = model_class_name.constantize
    record = model_class.with_deleted.find_by(id: record_id)

    return unless record
    return unless record.hard_delete_scheduled?

    Rails.logger.info("Hard deleting #{model_class_name} #{record.display_id} (ID: #{record_id})")

    # Hard delete (remove do banco definitivamente)
    record.really_destroy!
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("#{model_class_name} #{record_id} não encontrado para hard delete")
  end
end
```

---

## PASSO 4: Rake Task - Limpeza de Hard Deletes Expirados

Para garantir que hard deletes sejam executados mesmo se job falhar.

```ruby
# api/lib/tasks/cleanup_hard_deletes.rake
namespace :cleanup do
  desc "Executar hard delete em registros com timer expirado"
  task hard_deletes: :environment do
    models_with_hard_delete = [Job, Work, Office, Document, Procedure]

    models_with_hard_delete.each do |model|
      puts "Processando #{model.name}..."

      records = model.ready_for_hard_delete

      records.find_each do |record|
        puts "  Hard deleting #{record.display_id}..."
        record.really_destroy!
      end

      puts "  #{records.count} registros removidos"
    end

    puts "Limpeza concluída!"
  end
end
```

Agendar no cron (exemplo com whenever gem):
```ruby
# config/schedule.rb
every 10.minutes do
  rake "cleanup:hard_deletes"
end
```

---

## PASSO 5: Atualizar Models

### 5.1 Job

```ruby
# api/app/models/job.rb
class Job < ApplicationRecord
  include DeletedFilterConcern
  include Draftable
  include TeamScopedIdentifier  # <-- ADICIONAR

  acts_as_paranoid

  # ... resto do código permanece igual
end
```

### 5.2 Work

```ruby
# api/app/models/work.rb
class Work < ApplicationRecord
  include DeletedFilterConcern
  include Draftable
  include TeamScopedIdentifier  # <-- ADICIONAR

  acts_as_paranoid

  # ... resto do código permanece igual
end
```

### 5.3 Office

```ruby
# api/app/models/office.rb
class Office < ApplicationRecord
  include DeletedFilterConcern
  include CnpjValidatable
  include S3Attachable
  include TeamScopedIdentifier  # <-- ADICIONAR

  acts_as_paranoid

  # ... resto do código permanece igual
end
```

### 5.4 Document

**Atenção:** Document não tem `team_id` direto, pega via `work.team_id`

```ruby
# api/app/models/document.rb
class Document < ApplicationRecord
  include S3PathBuilder
  include TeamScopedIdentifier  # <-- ADICIONAR

  acts_as_paranoid

  belongs_to :profile_customer
  belongs_to :work

  # Delegar team para work (document é scoped via work)
  delegate :team, :team_id, to: :work

  # ... resto do código permanece igual
end
```

**Importante:** Como Document usa `work.team_id` para escopo, a gem sequenced precisa de configuração especial:

```ruby
# No concern TeamScopedIdentifier, adicionar lógica especial para Document
# Ou criar método que retorna o scope correto:

included do
  if name == 'Document' || name == 'Procedure'
    # Scope via work.team_id (não tem team_id próprio)
    # Sequenced não suporta scope via associação diretamente
    # Solução: adicionar callback manual
    before_validation :set_sequential_id_manually, on: :create
  else
    acts_as_sequenced scope: :team_id, column: :sequential_id
  end

  # ... resto
end

def set_sequential_id_manually
  return if sequential_id.present?

  # Para models sem team_id direto
  scope_value = respond_to?(:team_id) ? team_id : work.team_id

  max_seq = self.class
    .joins(:work)
    .where(works: { team_id: scope_value })
    .maximum(:sequential_id) || 0

  self.sequential_id = max_seq + 1
end
```

### 5.5 Procedure

```ruby
# api/app/models/procedure.rb
class Procedure < ApplicationRecord
  include DeletedFilterConcern
  include TeamScopedIdentifier  # <-- ADICIONAR

  acts_as_paranoid

  belongs_to :work
  belongs_to :law_area, optional: true

  # Delegar team para work
  delegate :team, :team_id, to: :work

  # ... resto do código permanece igual
end
```

---

## PASSO 6: Migration de Dados Existentes

Criar migration para popular `sequential_id` e `display_id` nos registros existentes.

```ruby
# api/db/migrate/XXXXXX_populate_team_scoped_ids.rb
class PopulateTeamScopedIds < ActiveRecord::Migration[7.0]
  def up
    say "Populando IDs team-scoped para registros existentes..."

    # Processar cada team
    Team.find_each do |team|
      say "  Team: #{team.name} (#{team.subdomain})"

      populate_for_model(Job, team, 'job')
      populate_for_model(Work, team, 'wrk')
      populate_for_model(Office, team, 'off')
      populate_for_model_via_work(Document, team, 'doc')
      populate_for_model_via_work(Procedure, team, 'prc')
    end

    say "População concluída!"

    # Tornar campos obrigatórios
    change_column_null :jobs, :sequential_id, false
    change_column_null :jobs, :display_id, false

    change_column_null :works, :sequential_id, false
    change_column_null :works, :display_id, false

    change_column_null :offices, :sequential_id, false
    change_column_null :offices, :display_id, false

    change_column_null :documents, :sequential_id, false
    change_column_null :documents, :display_id, false

    change_column_null :procedures, :sequential_id, false
    change_column_null :procedures, :display_id, false
  end

  def down
    change_column_null :jobs, :sequential_id, true
    change_column_null :jobs, :display_id, true

    change_column_null :works, :sequential_id, true
    change_column_null :works, :display_id, true

    change_column_null :offices, :sequential_id, true
    change_column_null :offices, :display_id, true

    change_column_null :documents, :sequential_id, true
    change_column_null :documents, :display_id, true

    change_column_null :procedures, :sequential_id, true
    change_column_null :procedures, :display_id, true
  end

  private

  def populate_for_model(model, team, prefix)
    records = model.with_deleted.where(team_id: team.id).order(:id)

    records.each_with_index do |record, index|
      sequence = index + 1
      display_id = format_display_id(team, prefix, sequence)

      record.update_columns(
        sequential_id: sequence,
        display_id: display_id
      )
    end

    say "    #{model.name}: #{records.count} registros"
  end

  def populate_for_model_via_work(model, team, prefix)
    # Models que pegam team via work (Document, Procedure)
    records = model.with_deleted
      .joins(:work)
      .where(works: { team_id: team.id })
      .order(:id)

    records.each_with_index do |record, index|
      sequence = index + 1
      display_id = format_display_id(team, prefix, sequence)

      record.update_columns(
        sequential_id: sequence,
        display_id: display_id
      )
    end

    say "    #{model.name}: #{records.count} registros"
  end

  def format_display_id(team, entity_prefix, sequence)
    team_prefix = if team.subdomain.present? && team.subdomain.length >= 3
      team.subdomain.downcase[0..2]
    else
      "t#{team.id.to_s.rjust(2, '0')}"
    end

    sequence_str = sequence.to_s.rjust(3, '0')
    "#{team_prefix}-#{entity_prefix}-#{sequence_str}"
  end
end
```

Executar:
```bash
rails db:migrate
```

---

## PASSO 7: Atualizar Controllers

### 7.1 JobsController

```ruby
# api/app/controllers/api/v1/jobs_controller.rb
class Api::V1::JobsController < ApplicationController
  def index
    @jobs = team_scoped(Job)
      .with_full_associations
      .order(sequential_id: :desc)  # <-- Ordenar por sequential_id

    render_jobs
  end

  def show
    # Aceitar display_id na URL
    @job = team_scoped(Job).find_by_display_id!(params[:id])
    render_job
  end

  def destroy
    @job = team_scoped(Job).find_by_display_id!(params[:id])

    if @job.destroy
      render json: {
        message: "Job #{@job.display_id} deletado",
        hard_delete_at: @job.hard_delete_at,
        countdown_seconds: @job.hard_delete_countdown
      }, status: :ok
    else
      render_error(@job.errors, :unprocessable_entity)
    end
  end

  def restore
    @job = team_scoped(Job).with_deleted.find_by_display_id!(params[:id])

    if @job.restore!
      render json: {
        message: "Job #{@job.display_id} restaurado"
      }, status: :ok
    else
      render_error({ base: 'Não foi possível restaurar' }, :unprocessable_entity)
    end
  end

  # ... resto permanece igual
end
```

### 7.2 Adicionar Rota de Restore

```ruby
# api/config/routes.rb
namespace :api do
  namespace :v1 do
    resources :jobs do
      member do
        post :restore  # POST /api/v1/jobs/:id/restore
      end
    end

    resources :works do
      member do
        post :restore
      end
    end

    resources :offices do
      member do
        post :restore
      end
    end

    # ... outros resources
  end
end
```

---

## PASSO 8: Atualizar Serializers

### 8.1 JobSerializer

```ruby
# api/app/serializers/job_serializer.rb
class JobSerializer
  include JSONAPI::Serializer

  # display_id como ID principal
  attribute :id do |job|
    job.display_id  # <-- Retornar display_id como id
  end

  # Campos adicionais
  attribute :sequential_id
  attribute :display_id

  # Informações de deleção
  attribute :deleted_at
  attribute :hard_delete_at
  attribute :hard_delete_countdown do |job|
    job.hard_delete_countdown if job.deleted_at.present?
  end

  # Outros atributos
  attributes :title, :description, :status, :priority, :deadline

  belongs_to :team
  belongs_to :work
  belongs_to :profile_customer
  belongs_to :created_by
end
```

### 8.2 Aplicar para Outros Serializers

- `WorkSerializer`
- `OfficeSerializer`
- `DocumentSerializer`
- `ProcedureSerializer`

Mesmo padrão: retornar `display_id` como `id` e adicionar campos de deleção.

---

## PASSO 9: Frontend - Types

### 9.1 Atualizar Types

```typescript
// frontend/src/lib/api/types/job.types.ts
export interface Job {
  id: string;                 // MUDANÇA: number → string (display_id)
  sequentialId: number;       // NOVO: para ordenação/display
  displayId: string;          // NOVO: ID formatado completo

  // Campos de deleção
  deletedAt?: string | null;
  hardDeleteAt?: string | null;
  hardDeleteCountdown?: number;  // Segundos restantes

  // Outros campos
  title: string;
  description?: string;
  status: JobStatus;
  priority: JobPriority;
  deadline: string;

  // Relacionamentos (também mudam para string)
  teamId: string;
  workId?: string;
  customerId?: string;
  createdById: string;
}

export enum JobStatus {
  Pending = 'pending',
  InProgress = 'in_progress',
  Completed = 'completed',
  Cancelled = 'cancelled'
}

export enum JobPriority {
  Low = 'low',
  Medium = 'medium',
  High = 'high',
  Urgent = 'urgent'
}
```

Aplicar para: `Work`, `Office`, `Document`, `Procedure`

---

## PASSO 10: Frontend - Services

### 10.1 JobService

```typescript
// frontend/src/lib/api/services/job.service.ts
export class JobService extends BaseService {
  async getJob(id: string): Promise<Job> {  // string em vez de number
    const response = await this.httpClient.get(`/jobs/${id}`);
    return this.parseJob(response.data.data);
  }

  async listJobs(filters?: JobFilters): Promise<Job[]> {
    const response = await this.httpClient.get('/jobs', { params: filters });
    return response.data.data.map(this.parseJob);
  }

  async deleteJob(id: string): Promise<DeleteResponse> {
    const response = await this.httpClient.delete(`/jobs/${id}`);
    return response.data;
  }

  async restoreJob(id: string): Promise<RestoreResponse> {
    const response = await this.httpClient.post(`/jobs/${id}/restore`);
    return response.data;
  }

  private parseJob(jsonApiData: any): Job {
    return {
      id: jsonApiData.id,  // Já vem como string "abc-job-001"
      displayId: jsonApiData.attributes.display_id,
      sequentialId: jsonApiData.attributes.sequential_id,

      // Campos de deleção
      deletedAt: jsonApiData.attributes.deleted_at,
      hardDeleteAt: jsonApiData.attributes.hard_delete_at,
      hardDeleteCountdown: jsonApiData.attributes.hard_delete_countdown,

      // Outros campos
      title: jsonApiData.attributes.title,
      description: jsonApiData.attributes.description,
      status: jsonApiData.attributes.status as JobStatus,
      priority: jsonApiData.attributes.priority as JobPriority,
      deadline: jsonApiData.attributes.deadline,

      // Relacionamentos
      teamId: jsonApiData.relationships?.team?.data?.id,
      workId: jsonApiData.relationships?.work?.data?.id,
      // ... outros
    };
  }
}

export interface DeleteResponse {
  message: string;
  hard_delete_at: string;
  countdown_seconds: number;
}

export interface RestoreResponse {
  message: string;
}
```

---

## PASSO 11: Frontend - UI Components

### 11.1 JobList Component

```svelte
<!-- frontend/src/lib/components/jobs/JobList.svelte -->
<script lang="ts">
  import type { Job } from '$lib/api/types/job.types';
  import { jobService } from '$lib/api/services';
  import { goto } from '$app/navigation';

  export let jobs: Job[];

  // Ordenar por sequential_id decrescente
  $: sortedJobs = [...jobs].sort((a, b) => b.sequentialId - a.sequentialId);

  // Filtro de busca
  let searchTerm = '';
  $: filteredJobs = sortedJobs.filter(job =>
    job.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
    job.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    job.sequentialId.toString().includes(searchTerm)
  );

  async function handleDelete(job: Job) {
    if (!confirm(`Deletar job ${job.id}?`)) return;

    try {
      const response = await jobService.deleteJob(job.id);
      alert(`Job deletado! Será removido permanentemente em ${response.countdown_seconds}s`);
      // Recarregar lista
      window.location.reload();
    } catch (error) {
      alert('Erro ao deletar job');
    }
  }

  async function handleRestore(job: Job) {
    try {
      await jobService.restoreJob(job.id);
      alert('Job restaurado!');
      window.location.reload();
    } catch (error) {
      alert('Erro ao restaurar job');
    }
  }
</script>

<div class="job-list">
  <input
    type="text"
    placeholder="Buscar jobs..."
    bind:value={searchTerm}
    class="search-input"
  />

  <table>
    <thead>
      <tr>
        <th>#</th>
        <th>ID</th>
        <th>Título</th>
        <th>Status</th>
        <th>Prioridade</th>
        <th>Ações</th>
      </tr>
    </thead>
    <tbody>
      {#each filteredJobs as job}
        <tr class:deleted={job.deletedAt}>
          <td>#{job.sequentialId}</td>
          <td>
            <code class="job-id">{job.id}</code>
          </td>
          <td>
            <a href="/jobs/{job.id}">{job.title}</a>
          </td>
          <td>
            <span class="badge status-{job.status}">
              {job.status}
            </span>
          </td>
          <td>
            <span class="badge priority-{job.priority}">
              {job.priority}
            </span>
          </td>
          <td>
            {#if job.deletedAt}
              <button on:click={() => handleRestore(job)} class="btn-restore">
                Restaurar ({job.hardDeleteCountdown}s)
              </button>
            {:else}
              <button on:click={() => handleDelete(job)} class="btn-delete">
                Deletar
              </button>
            {/if}
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
</div>

<style>
  .job-id {
    font-family: 'Fira Code', monospace;
    font-size: 0.85rem;
    background: var(--color-bg-code);
    padding: 2px 6px;
    border-radius: 3px;
  }

  .deleted {
    opacity: 0.6;
    background: #ffebee;
  }

  .btn-restore {
    background: #4caf50;
    color: white;
    padding: 4px 8px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }

  .btn-delete {
    background: #f44336;
    color: white;
    padding: 4px 8px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
</style>
```

---

## PASSO 12: Testes

### 12.1 Model Tests

```ruby
# api/spec/models/job_spec.rb
require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:team) { create(:team, subdomain: 'acme') }

  describe 'team scoped identifiers' do
    it 'generates display_id on create' do
      job = create(:job, team: team)
      expect(job.display_id).to eq('acm-job-001')
      expect(job.sequential_id).to eq(1)
    end

    it 'increments sequential_id per team' do
      job1 = create(:job, team: team)
      job2 = create(:job, team: team)

      expect(job1.sequential_id).to eq(1)
      expect(job2.sequential_id).to eq(2)
      expect(job1.display_id).to eq('acm-job-001')
      expect(job2.display_id).to eq('acm-job-002')
    end

    it 'allows same sequential_id for different teams' do
      team2 = create(:team, subdomain: 'other')

      job1 = create(:job, team: team)
      job2 = create(:job, team: team2)

      expect(job1.sequential_id).to eq(1)
      expect(job2.sequential_id).to eq(1)
      expect(job1.display_id).to eq('acm-job-001')
      expect(job2.display_id).to eq('oth-job-001')
    end
  end

  describe 'soft delete with timer' do
    let(:job) { create(:job, team: team) }

    it 'soft deletes and schedules hard delete' do
      expect {
        job.destroy
      }.to change { job.reload.deleted_at }.from(nil)
       .and change { job.reload.hard_delete_at }.from(nil)

      expect(job.hard_delete_countdown).to be > 0
    end

    it 'allows restore before hard delete' do
      job.destroy
      expect(job.deleted_at).to be_present

      job.restore!
      expect(job.deleted_at).to be_nil
      expect(job.hard_delete_at).to be_nil
    end
  end
end
```

### 12.2 Controller Tests

```ruby
# api/spec/controllers/api/v1/jobs_controller_spec.rb
require 'rails_helper'

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
  end

  describe 'DELETE #destroy' do
    it 'soft deletes job and returns countdown' do
      delete :destroy, params: { id: job.display_id }

      expect(response).to have_http_status(:ok)
      expect(json_response['countdown_seconds']).to be > 0

      job.reload
      expect(job.deleted_at).to be_present
      expect(job.hard_delete_at).to be_present
    end
  end

  describe 'POST #restore' do
    before { job.destroy }

    it 'restores deleted job' do
      post :restore, params: { id: job.display_id }

      expect(response).to have_http_status(:ok)

      job.reload
      expect(job.deleted_at).to be_nil
      expect(job.hard_delete_at).to be_nil
    end
  end
end
```

---

## 📋 Checklist de Implementação

### Backend

- [ ] Adicionar gem `sequenced` no Gemfile
- [ ] Bundle install
- [ ] Criar migrations para adicionar campos (sequential_id, display_id, hard_delete_at)
- [ ] Executar migrations
- [ ] Criar concern `TeamScopedIdentifier`
- [ ] Criar job `HardDeleteJob`
- [ ] Criar rake task `cleanup:hard_deletes`
- [ ] Incluir concern nos models (Job, Work, Office, Document, Procedure)
- [ ] Criar migration de população de dados existentes
- [ ] Executar migration de população
- [ ] Atualizar controllers para usar `find_by_display_id!`
- [ ] Adicionar action `restore` nos controllers
- [ ] Adicionar rotas de restore
- [ ] Atualizar serializers para retornar display_id como id
- [ ] Escrever testes de model
- [ ] Escrever testes de controller
- [ ] Validar em desenvolvimento

### Frontend

- [ ] Atualizar types: `id: string`
- [ ] Adicionar campos de deleção nos types
- [ ] Atualizar services para aceitar string IDs
- [ ] Adicionar método `restoreJob` nos services
- [ ] Atualizar componentes de listagem
- [ ] Adicionar botão "Restaurar" para items deletados
- [ ] Mostrar countdown de hard delete
- [ ] Atualizar lógica de busca/filtro
- [ ] Escrever testes de services
- [ ] Escrever testes E2E
- [ ] Validar em desenvolvimento

### Deployment

- [ ] Testar migrations em staging
- [ ] Validar população de dados em staging
- [ ] Executar testes completos
- [ ] Configurar cron para cleanup task
- [ ] Deploy em produção
- [ ] Monitorar logs
- [ ] Validar funcionalidades

---

## 📊 Resumo de IDs Formatados

| Entidade | Team | Seq | Display ID | URL |
|----------|------|-----|------------|-----|
| Job | acme | 1 | `acm-job-001` | `/jobs/acm-job-001` |
| Job | acme | 42 | `acm-job-042` | `/jobs/acm-job-042` |
| Work | silva | 1 | `sil-wrk-001` | `/works/sil-wrk-001` |
| Office | xyz | 5 | `xyz-off-005` | `/offices/xyz-off-005` |
| Document | acme | 100 | `acm-doc-100` | `/documents/acm-doc-100` |

**Formato geral (minúsculas):**
```
{team_prefix}-{entity_prefix}-{sequential_id}

team_prefix: 3 primeiros caracteres do subdomain (minúsculas)
entity_prefix: prefixo fixo do tipo (job, wrk, off, doc, prc)
sequential_id: número com zero-padding (001, 002, ..., 100)
```

---

## 🔧 Comportamento de Deleção

### Fluxo Completo

```
1. Usuário clica "Deletar Job #5"
   ↓
2. Backend: soft delete (marca deleted_at + hard_delete_at = now + 5min)
   ↓
3. Job em background é agendado para 5 minutos depois
   ↓
4. Usuário vê: "Job deletado! Será removido em 300s"
   ↓
5a. Se usuário clicar "Restaurar" (control-z):
       → deleted_at = null
       → hard_delete_at = null
       → Job restaurado! ✅
   ↓
5b. Se 5 minutos passarem sem restaurar:
       → HardDeleteJob executa
       → really_destroy! (remove do banco)
       → ID abc-job-005 fica reservado para sempre
```

### Timeline Visual

```
0:00   Usuário deleta job
       ├─ deleted_at = agora
       └─ hard_delete_at = agora + 5min

0:00 - 4:59   Janela de "control-z"
              └─ Usuário pode restaurar

5:00   Timer expira
       └─ HardDeleteJob executa
          └─ really_destroy! (hard delete)

Resultado: Job removido do banco
          ID "abc-job-005" nunca é reutilizado
```

---

## ⚠️ Pontos de Atenção

### 1. Document e Procedure (sem team_id direto)
- Pegam team via `work.team_id`
- Gem sequenced não suporta scope via associação
- **Solução:** callback manual `set_sequential_id_manually`

### 2. Thread Safety
- Gem sequenced é thread-safe **apenas para PostgreSQL**
- MySQL/SQLite podem ter race conditions

### 3. Hard Delete Permanente
- Após hard delete, ID é perdido para sempre
- Não há como recuperar
- **Garantir que timer de 5min é suficiente**

### 4. Background Jobs
- Requer Sidekiq, Resque ou similar
- Se não tiver: usar apenas rake task com cron

### 5. IDs em Minúsculas
- Garante consistência visual
- URLs ficam mais limpas
- Fácil digitar/copiar

---

## 🚀 Ordem de Execução

```
1. Backend Setup (2h)
   ├─ Adicionar gem sequenced
   ├─ Criar migrations
   └─ Executar migrations

2. Backend Core (4h)
   ├─ Criar concern TeamScopedIdentifier
   ├─ Criar HardDeleteJob
   ├─ Criar rake task
   └─ Incluir concern nos models

3. Backend Data (1h)
   ├─ Criar migration de população
   └─ Executar população

4. Backend APIs (3h)
   ├─ Atualizar controllers
   ├─ Adicionar rotas restore
   └─ Atualizar serializers

5. Backend Tests (2h)
   ├─ Testes de model
   └─ Testes de controller

6. Frontend Types & Services (2h)
   ├─ Atualizar types
   └─ Atualizar services

7. Frontend UI (3h)
   ├─ Atualizar componentes
   └─ Adicionar funcionalidade restore

8. Frontend Tests (2h)
   ├─ Testes de services
   └─ Testes E2E

9. Deploy & Monitoring (2h)
   └─ Deploy + validação

TOTAL: ~21 horas (~3 dias)
```

---

## 📖 Referências

- Gem Sequenced: https://github.com/derrickreimer/sequenced
- Gem Paranoia: https://github.com/rubysherpas/paranoia
- Rails Callbacks: https://guides.rubyonrails.org/active_record_callbacks.html
- ActiveJob: https://guides.rubyonrails.org/active_job_basics.html

---

**Versão:** 1.0
**Data:** 2025-11-13
**Autor:** Claude Code
**Status:** 📝 Pronto para Implementação
