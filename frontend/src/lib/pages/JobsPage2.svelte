<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import JobsTable from '../components/jobs2/JobsTable.svelte';
  import api, { type Job } from '../api';

  let jobs: Job[] = $state([]);
  let loading = $state(true);
  let error = $state<string | null>(null);

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
    fetchJobs();
  });
</script>

<AuthSidebar>
  <div class="container mx-auto py-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">📋 Jobs 2</h2>
        </div>

        <JobsTable {jobs} {loading} {error} onRetry={fetchJobs} />
      </div>
    </div>
  </div>
</AuthSidebar>
