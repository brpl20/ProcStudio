<!-- components/jobs/JobList.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import api, { type Job } from '../../api';
  import { getJobStatusInfo, getJobPriorityInfo } from '../../constants/formOptions';
  import { truncateDescription } from '../../utils/text';
  import Icon from '../../icons/icons.svelte';
  import SearchInput from '../ui/SearchInput.svelte';

  let jobs: Job[] = $state([]);
  let loading = $state(true);
  let error = $state<string | null>(null);
  let searchTerm = $state('');

  let filteredJobs = $state([]);

  // Update filteredJobs whenever jobs or searchTerm changes
  $effect(() => {
    if (!searchTerm || !searchTerm.trim()) {
      filteredJobs = jobs;
      return;
    }

    const term = searchTerm.toLowerCase();
    filteredJobs = jobs.filter((job) => {
      return (
        job.description?.toLowerCase().includes(term) ||
        job.latest_comment?.content?.toLowerCase().includes(term) ||
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
  });

  // Helper function to get initials from user name
  function getInitials(user: { name: string; last_name?: string }): string {
    const firstName = user.name?.charAt(0) || '';
    const lastName = user.last_name?.charAt(0) || '';
    return (firstName + lastName).toUpperCase();
  }

  // Helper function to get initials from full name (for comment authors)
  function getInitialsFromFullName(fullName: string): string {
    const names = fullName.trim().split(' ');
    const firstName = names[0]?.charAt(0) || '';
    const lastName = names.length > 1 ? names[names.length - 1]?.charAt(0) || '' : '';
    return (firstName + lastName).toUpperCase();
  }

  async function fetchJobs() {
    try {
      loading = true;
      error = null;

      const response = await api.jobs.getJobs();

      if (response.success && response.data) {
        jobs = response.data;
      } else {
        throw new Error(response.message || 'Failed to fetch jobs');
      }
    } catch (err) {
      error = err instanceof Error ? err.message : 'An error occurred while fetching jobs';
    } finally {
      loading = false;
    }
  }

  onMount(() => {
    // For development: use a test token if no auth token exists
    // TODO: Remove this when proper login flow is implemented in frontend
    if (!api.getAuthToken() && import.meta.env.DEV) {
      const testToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo4Mywic3ViIjo4MywiZXhwIjoxNzI1OTkxNjEzfQ.bfqKF9Kzwquj7m7o6_UJ9wLzDdPRYwNpCG6FMKqJ_ow';
      api.setAuthToken(testToken);
    }
    fetchJobs();
  });
</script>

{#if loading}
  <div class="text-center py-8">
    <div class="loading loading-spinner loading-md text-primary"></div>
    <p class="text-base-content/70 mt-4">Carregando jobs...</p>
  </div>
{:else if error}
  <div class="alert alert-error">
    <svg class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      ></path>
    </svg>
    <div>
      <h3 class="font-bold">Erro ao carregar jobs</h3>
      <div class="text-xs">{error}</div>
    </div>
    <button onclick={fetchJobs} class="btn btn-sm">Tentar novamente</button>
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
  <div class="mb-4">
    <SearchInput
      bind:value={searchTerm}
      placeholder="Pesquisar por descrição, comentário, trabalho, status..."
    />
  </div>

  {#if filteredJobs.length === 0}
    <div class="alert alert-info">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        class="stroke-current shrink-0 w-6 h-6"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
        ></path>
      </svg>
      <span>Nenhum job encontrado para "{searchTerm}"</span>
    </div>
  {:else}
    <div class="text-sm text-base-content/60 mb-2">
      Mostrando {filteredJobs.length} de {jobs.length} jobs
    </div>
  {/if}

  <div class="overflow-x-auto">
    <table class="table table-zebra">
      <thead>
        <tr>
          <th>#</th>
          <th>Descrição</th>
          <th>Comentários</th>
          <th>Status / Prazo</th>
          <th>Prioridade</th>
          <th>Equipe</th>
          <th>Trabalho</th>
          <th>Cliente</th>
        </tr>
      </thead>
      <tbody>
        {#each filteredJobs as job}
          <tr class="hover">
            <td class="font-mono text-sm">
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
            <td class="w-12 text-center">
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
                  <span class="{getJobStatusInfo(job.status).badgeClass} badge-sm">
                    {getJobStatusInfo(job.status).label}
                  </span>
                </div>
                <div class="text-xs text-base-content/60">
                  {#if job.deadline}
                    {new Date(job.deadline).toLocaleDateString('pt-BR')}
                  {:else}
                    Sem prazo
                  {/if}
                </div>
              </div>
            </td>
            <td>
              <span class="{getJobPriorityInfo(job.priority).badgeClass} badge-sm">
                {getJobPriorityInfo(job.priority).label}
              </span>
            </td>
            <td>
              {#if job.assignees_summary && job.assignees_summary.length > 0}
                {#if job.assignees_summary.length === 1}
                  <!-- Single member -->
                  <div class="avatar placeholder">
                    <div class="bg-primary text-primary-content rounded-full w-8 h-8">
                      <span class="text-xs font-medium">
                        {getInitials(job.assignees_summary[0])}
                      </span>
                    </div>
                  </div>
                {:else if job.assignees_summary.length === 2}
                  <!-- Two members -->
                  <div class="avatar-group -space-x-4">
                    <div class="avatar placeholder">
                      <div class="bg-primary text-primary-content rounded-full w-8 h-8">
                        <span class="text-xs font-medium">
                          {getInitials(job.assignees_summary[0])}
                        </span>
                      </div>
                    </div>
                    <div class="avatar placeholder">
                      <div class="bg-secondary text-secondary-content rounded-full w-8 h-8">
                        <span class="text-xs font-medium">
                          {getInitials(job.assignees_summary[1])}
                        </span>
                      </div>
                    </div>
                  </div>
                {:else}
                  <!-- Three or more members -->
                  <div class="avatar-group -space-x-4">
                    <div class="avatar placeholder">
                      <div class="bg-primary text-primary-content rounded-full w-8 h-8">
                        <span class="text-xs font-medium">
                          {getInitials(job.assignees_summary[0])}
                        </span>
                      </div>
                    </div>
                    <div class="avatar placeholder">
                      <div class="bg-secondary text-secondary-content rounded-full w-8 h-8">
                        <span class="text-xs font-medium">
                          {getInitials(job.assignees_summary[1])}
                        </span>
                      </div>
                    </div>
                    <div class="avatar placeholder">
                      <div class="bg-accent text-accent-content rounded-full w-8 h-8">
                        <span class="text-xs font-bold">
                          +{job.assignees_summary.length - 2}
                        </span>
                      </div>
                    </div>
                  </div>
                {/if}
              {:else}
                <span class="text-base-content/30">-</span>
              {/if}
            </td>
            <td>
              {#if job.work_number}
                <div class="font-medium">{job.work_number}</div>
              {:else}
                <div class="font-medium text-base-content/60">Sem trabalho</div>
              {/if}
            </td>
            <td>
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
