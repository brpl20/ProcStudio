<!-- components/jobs/JobList.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import api, { type Job } from '../../api';
  import { getJobStatusInfo, getJobPriorityInfo } from '../../constants/formOptions';

  let jobs: Job[] = $state([]);
  let loading = $state(true);
  let error = $state<string | null>(null);

  async function fetchJobs() {
    try {
      loading = true;
      error = null;

      // Use the proper API service method
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
  <div class="overflow-x-auto">
    <table class="table table-zebra">
      <thead>
        <tr>
          <th>#</th>
          <th>Descrição</th>
          <th>Status</th>
          <th>Prioridade</th>
          <th>Responsável</th>
          <th>Prazo</th>
        </tr>
      </thead>
      <tbody>
        {#each jobs as job}
          <tr class="hover">
            <td class="font-mono text-sm">
              {job.id}
            </td>
            <td>
              {#if job.description}
                <div class="font-medium">{job.description}</div>
              {:else}
                <div class="font-medium text-base-content/60">Sem descrição</div>
              {/if}
              {#if job.comment}
                <div class="text-sm text-base-content/60 mt-1">{job.comment}</div>
              {/if}
            </td>
            <td>
              <span class="{getJobStatusInfo(job.status).badgeClass} badge-sm">
                {getJobStatusInfo(job.status).label}
              </span>
            </td>
            <td>
              <span class="{getJobPriorityInfo(job.priority).badgeClass} badge-sm">
                {getJobPriorityInfo(job.priority).label}
              </span>
            </td>
            <td>
              {#if job.responsible_id}
                ID: {job.responsible_id}
              {:else}
                -
              {/if}
            </td>
            <td>
              {#if job.deadline}
                {new Date(job.deadline).toLocaleDateString('pt-BR')}
              {:else}
                -
              {/if}
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
{/if}
