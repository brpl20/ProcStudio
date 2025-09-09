<!-- components/jobs/JobList.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import api, { type Job } from '../../api';
  import { getJobStatusInfo, getJobPriorityInfo } from '../../constants/formOptions';
  import { truncateDescription } from '../../utils/text';
  import Icon from '../../icons.svelte';

  let jobs: Job[] = $state([]);
  let loading = $state(true);
  let error = $state<string | null>(null);

  // Helper function to render team avatars based on team size
  function getTeamAvatars(job: Job) {
    const members = [];

    // Add responsible person if exists
    if (job.responsible_id) {
      members.push({ id: job.responsible_id, isPrimary: true });
    }

    // TODO: Add assignee_ids when available from API
    // if (job.assignee_ids) {
    //   job.assignee_ids.forEach(id => members.push({ id, isPrimary: false }));
    // }

    return members;
  }

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
          <th>Comentários</th>
          <th>Status / Prazo</th>
          <th>Prioridade</th>
          <th>Equipe</th>
          <th>Trabalho</th>
          <th>Cliente</th>
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
                <div class="font-medium tooltip" data-tip={job.description}>
                  {truncateDescription(job.description)}
                </div>
              {:else}
                <div class="font-medium text-base-content/60">Sem descrição</div>
              {/if}
            </td>
            <td class="w-12 text-center">
              {#if job.comment}
                <div class="tooltip" data-tip={job.comment}>
                  <Icon
                    name="comment"
                    className="h-4 w-4 text-primary hover:text-primary-focus cursor-help"
                  />
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
              {#if getTeamAvatars(job).length > 0}
                {@const teamMembers = getTeamAvatars(job)}
                {#if teamMembers.length === 1}
                  <!-- Single member -->
                  <div class="avatar placeholder">
                    <div class="bg-primary text-primary-content rounded-full w-8 h-8">
                      <span class="text-xs font-medium">
                        {teamMembers[0].id.toString().slice(-2)}
                      </span>
                    </div>
                  </div>
                {:else if teamMembers.length === 2}
                  <!-- Two members -->
                  <div class="avatar-group -space-x-4">
                    <div class="avatar placeholder">
                      <div class="bg-primary text-primary-content rounded-full w-8 h-8">
                        <span class="text-xs font-medium">
                          {teamMembers[0].id.toString().slice(-2)}
                        </span>
                      </div>
                    </div>
                    <div class="avatar placeholder">
                      <div class="bg-secondary text-secondary-content rounded-full w-8 h-8">
                        <span class="text-xs font-medium">
                          {teamMembers[1].id.toString().slice(-2)}
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
                          {teamMembers[0].id.toString().slice(-2)}
                        </span>
                      </div>
                    </div>
                    <div class="avatar placeholder">
                      <div class="bg-secondary text-secondary-content rounded-full w-8 h-8">
                        <span class="text-xs font-medium">
                          {teamMembers[1].id.toString().slice(-2)}
                        </span>
                      </div>
                    </div>
                    <div class="avatar placeholder">
                      <div class="bg-accent text-accent-content rounded-full w-8 h-8">
                        <span class="text-xs font-bold">
                          +{teamMembers.length - 2}
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
