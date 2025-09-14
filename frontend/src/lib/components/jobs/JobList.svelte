<!-- components/jobs/JobList.svelte -->
<script lang="ts">
  import { type Job } from '../../api';
  import { getJobStatusInfo, getJobPriorityInfo } from '../../constants/formOptions';
  import { truncateDescription } from '../../utils/text';
  import Icon from '../../icons/icons.svelte';
  import SearchInput from '../ui/SearchInput.svelte';
  import FilterButton, { type FilterOption } from '../ui/FilterButton.svelte';
  import AvatarGroup from '../ui/AvatarGroup.svelte';
  import { JOBPRIORITY } from '../../constants/formOptions';

  interface Props {
    jobs?: Job[];
    loading?: boolean;
    error?: string | null;
    onRetry?: () => void;
  }

  const {
    jobs = [],
    loading = false,
    error = null,
    onRetry = () => {}
  }: Props = $props();

  let searchTerm = $state('');
  let priorityFilter = $state<string>('all');

  let filteredJobs = $state([]);

  // Create filter options from JOBPRIORITY
  const priorityOptions: FilterOption<string>[] = JOBPRIORITY.map((item) => ({
    value: item.value,
    label: item.label,
    badgeClass: item.badgeClass
  }));

  // Update filteredJobs whenever jobs, searchTerm, or priorityFilter changes
  $effect(() => {
    let result = [...jobs];

    // Apply priority filter
    if (priorityFilter !== 'all') {
      result = result.filter((job) => job.priority === priorityFilter);
    }

    // Apply search filter
    if (searchTerm && searchTerm.trim()) {
      const term = searchTerm.toLowerCase();
      result = result.filter((job) => {
        return (
          job.description?.toLowerCase().includes(term) ||
          // job.latest_comment?.content?.toLowerCase().includes(term) ||
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

    filteredJobs = result;
  });
</script>

{#if loading}
  <div class="text-center py-8">
    <div class="loading loading-spinner loading-md text-primary"></div>
    <p class="text-base-content/70 mt-4">Carregando jobs...</p>
  </div>
{:else if error}
  <div class="alert alert-error">
    <Icon name="error" className="h-6 w-6" />
    <div>
      <h3 class="font-bold">Erro ao carregar jobs</h3>
      <div class="text-xs">{error}</div>
    </div>
    <button onclick={onRetry} class="btn btn-sm">Tentar novamente</button>
  </div>
{:else if jobs.length === 0}
  <div class="hero bg-base-200 rounded-lg py-8">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <p class="py-6 text-lg">Nenhum job encontrado</p>
        <p class="text-base-content/60">Os jobs aparecerão aqui quando forem criados.</p>
      </div>
    </div>
  </div>
{:else}
  <div class="mb-4 flex gap-2">
    <SearchInput
      bind:value={searchTerm}
      placeholder="Pesquisar por descrição, comentário, trabalho, status..."
      onSearchChange={(value) => searchTerm = value}
    />
    <FilterButton
      bind:value={priorityFilter}
      options={priorityOptions}
      placeholder="Prioridade"
      allOptionLabel="Todas"
      onFilterChange={(value) => priorityFilter = value}
    />
  </div>

  {#if filteredJobs.length === 0}
    <div class="alert alert-info">
      <Icon name="info" className="h-6 w-6" />
      <span>Nenhum job encontrado para "{searchTerm}"</span>
    </div>
  {:else}
    <div class="text-sm text-base-content/60 mb-2">
      Mostrando {filteredJobs.length} de {jobs.length} jobs
    </div>
  {/if}

  <div class="overflow-x-auto">
    <table class="table table-zebra table-xs sm:table-sm">
      <thead>
        <tr>
          <th class="hidden sm:table-cell">#</th>
          <th>Descrição</th>
          <th class="hidden lg:table-cell">Comentários</th>
          <th>Status</th>
          <th class="hidden md:table-cell">Prioridade</th>
          <th class="hidden md:table-cell">Equipe</th>
          <th class="hidden lg:table-cell">Trabalho</th>
          <th class="hidden xl:table-cell">Cliente</th>
        </tr>
      </thead>
      <tbody>
        {#each filteredJobs as job}
          <tr class="hover">
            <td class="font-mono text-sm hidden sm:table-cell">
              {job.id}
            </td>
            <td>
              {#if job.description}
                <div class="font-medium tooltip" data-tip={job.description}>
                  {truncateDescription(job.description)}
                </div>
              {:else}
                <div class="font-medium text-base-content/60">Sem descrição</div>
              {/if}
            </td>
            <td class="w-12 text-center hidden lg:table-cell">
              {#if job.latest_comment}
                <div class="tooltip tooltip-left" data-tip={job.latest_comment.content}>
                  <div class="flex items-center gap-1">
                    <Icon
                      name="comment"
                      className="h-4 w-4 text-primary hover:text-primary-focus cursor-help"
                    />
                    {#if job.comments_count && job.comments_count > 1}
                      <span class="badge badge-xs badge-primary">{job.comments_count}</span>
                    {/if}
                  </div>
                </div>
              {:else}
                <span class="text-base-content/30">-</span>
              {/if}
            </td>
            <td>
              <div class="flex flex-col gap-1">
                <div>
                  <span class="{getJobStatusInfo(job.status).badgeClass} badge-xs sm:badge-sm">
                    {getJobStatusInfo(job.status).label}
                  </span>
                </div>
                <div class="text-xs text-base-content/60 hidden sm:block">
                  {#if job.deadline}
                    {new Date(job.deadline).toLocaleDateString('pt-BR')}
                  {:else}
                    Sem prazo
                  {/if}
                </div>
              </div>
            </td>
            <td class="hidden md:table-cell">
              <span class="{getJobPriorityInfo(job.priority).badgeClass} badge-sm">
                {getJobPriorityInfo(job.priority).label}
              </span>
            </td>
            <td class="hidden md:table-cell">
              <AvatarGroup users={job.assignees_summary || []} size="sm" />
            </td>
            <td class="hidden lg:table-cell">
              {#if job.work_number}
                <div class="font-medium">{job.work_number}</div>
              {:else}
                <div class="font-medium text-base-content/60">Sem trabalho</div>
              {/if}
            </td>
            <td class="hidden xl:table-cell">
              {#if job.customer_id}
                <div class="font-medium">ID: {job.customer_id}</div>
              {:else}
                <div class="font-medium text-base-content/60">Sem cliente</div>
              {/if}
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
{/if}
