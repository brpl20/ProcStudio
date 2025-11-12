<script lang="ts">
  import { type Job } from '../../api';
  import JobsTableFilters from './jobsFilter/JobsTableFilters.svelte';
  import JobsTableStates from './JobsTableStates.svelte';
  import JobsTableRow from './JobsTableRow.svelte';
  import JobCreateDrawer from './JobCreateDrawer.svelte';
  import JobEditDrawer from './JobEditDrawer.svelte';
  import Icon from '../../icons/icons.svelte';

  interface Props {
    jobs?: Job[];
    loading?: boolean;
    error?: string | null;
    onRetry?: () => void;
  }

  const { jobs = [], loading = false, error = null, onRetry = () => {} }: Props = $props();

  let searchTerm = $state('');
  let priorityFilter = $state<string>('all');
  let showCreateDrawer = $state(false);
  let showEditDrawer = $state(false);
  let selectedJob = $state<Job | null>(null);
  let editingJobId = $state<string | number | null>(null);

  const filteredJobs = $derived.by(() => {
    let result = [...jobs];

    if (priorityFilter !== 'all') {
      result = result.filter((job) => job.priority === priorityFilter);
    }

    if (searchTerm && searchTerm.trim()) {
      const term = searchTerm.toLowerCase();
      result = result.filter((job) => {
        return (
          job.description?.toLowerCase().includes(term) ||
          job.latest_comment?.author?.name?.toLowerCase().includes(term) ||
          job.work_number?.toLowerCase().includes(term) ||
          job.status?.toLowerCase().includes(term) ||
          job.priority?.toLowerCase().includes(term) ||
          job.id?.toString().includes(term) ||
          job.assignees_summary?.some(
            (u) => u.name?.toLowerCase().includes(term) || u.last_name?.toLowerCase().includes(term)
          )
        );
      });
    }

    return result;
  });

  function handleCreateJob(jobData: any) {
    console.log('Creating job:', jobData);
    // Chamada API aqui
  }

  function handleEditJob(job: Job) {
    selectedJob = job;
    showEditDrawer = true;
  }

  function handleSaveJob(updatedData: Partial<Job>) {
    console.log('Saving job:', selectedJob?.id, updatedData);
    // Chamada API aqui
  }

  function handleSaveInline(jobId: string | number, updates: Partial<Job>) {
    console.log('Saving inline edits for job:', jobId, updates);
    // Aqui você fará a chamada API para atualizar
    editingJobId = null;
  }
</script>

{#if loading}
  <JobsTableStates type="loading" />
{:else if error}
  <JobsTableStates type="error" {error} {onRetry} />
{:else if jobs.length === 0}
  <JobsTableStates type="empty" />
{:else}
  <!-- Filtros e Botão -->
  <div class="mb-4 flex flex-col sm:flex-row gap-2">
    <div class="flex-1">
      <JobsTableFilters bind:searchTerm bind:priorityFilter />
    </div>
    <button class="btn btn-primary w-full sm:w-auto" onclick={() => (showCreateDrawer = true)}>
      <Icon name="plus" className="h-4 w-4" />
      <span class="hidden sm:inline">Nova Tarefa</span>
      <span class="sm:hidden">Novo</span>
    </button>
  </div>

  {#if filteredJobs.length === 0}
    <JobsTableStates type="no-results" {searchTerm} />
  {:else}
    <div class="text-sm text-base-content/60 mb-2">
      Mostrando {filteredJobs.length} de {jobs.length} jobs
    </div>

    <!-- Tabela com scroll horizontal - TODAS as colunas visíveis -->
    <div class="overflow-x-auto w-full">
      <table class="table table-xs sm:table-sm text-center w-full">
        <thead>
          <tr class="bg-base-100">
            <th
              class="py-3 text-[18px] font-semibold text-base-content/60 text-center"
              >#</th
            >
            <th
              class="py-3 text-[15px] font-semibold text-base-content/60 text-center min-w-[180px]"
              >Tarefas</th
            >
            <th
              class="py-3 text-[15px] font-semibold"
            ></th>
            <th
              class="py-3 text-[15px] font-semibold text-base-content/60 text-center min-w-[130px]"
              >Status</th
            >
            <th
              class="py-3 text-[15px] font-semibold text-base-content/60 text-center min-w-[100px]"
              >Prioridade</th
            >
            <th
              class="py-3 text-[15px] font-semibold text-base-content/60 text-center min-w-[140px]"
              >Equipe</th
            >
            <th
              class="py-3 text-[15px] font-semibold text-base-content/60 text-center min-w-[120px]"
              >Trabalho</th
            >
            <th class="py-3 text-[15px] font-semibold text-base-content/60 text-center min-w-[120px]"
              >Cliente</th
            >
            {#if editingJobId !== null}
              <th class="py-3 text-[15px] font-semibold text-base-content/60 text-center min-w-[100px]"
                >Ações</th
              >
            {/if}
          </tr>
        </thead>
        <tbody>
          {#each filteredJobs as job (job.id)}
            <JobsTableRow
              {job}
              isEditing={editingJobId === job.id}
              onEdit={() => handleEditJob(job)}
              onStartEdit={() => (editingJobId = job.id)}
              onCancelEdit={() => (editingJobId = null)}
              onSaveInline={(updates) => handleSaveInline(job.id, updates)}
            />
          {/each}
        </tbody>
      </table>
    </div>

    <!-- Dica de scroll em mobile -->
    <div class="text-xs text-base-content/60 mt-2 sm:hidden text-center">
      ← Arraste para ver mais colunas →
    </div>
  {/if}
{/if}

<JobCreateDrawer
  bind:isOpen={showCreateDrawer}
  onClose={() => (showCreateDrawer = false)}
  onCreate={handleCreateJob}
/>

<JobEditDrawer
  bind:isOpen={showEditDrawer}
  job={selectedJob}
  onClose={() => (showEditDrawer = false)}
  onSave={handleSaveJob}
/>
