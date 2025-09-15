<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import Icon from '../icons/icons.svelte';
  import { authStore } from '../stores/authStore';
  import JobList from '../components/jobs/JobList.svelte';
  import JobDrawer from '../components/jobs/JobDrawer.svelte';
  import api, { type Job } from '../api';

  let jobs: Job[] = $state([]);
  let loading = $state(true);
  let error = $state<string | null>(null);
  let isDrawerOpen = $state(false);

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

  function toggleDrawer() {
    isDrawerOpen = !isDrawerOpen;
  }
</script>

<AuthSidebar>
  <div class="container mx-auto py-6 relative">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">📋 Jobs</h2>
        </div>

        <JobList {jobs} {loading} {error} onRetry={fetchJobs} />
      </div>
    </div>

    <button
      class="btn btn-primary btn-circle fixed bottom-8 right-8 shadow-lg z-40"
      onclick={toggleDrawer}
      title="Abrir anotações"
      aria-label="Abrir anotações"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-6 w-6"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
        />
      </svg>
    </button>
  </div>

  <JobDrawer bind:isOpen={isDrawerOpen} />
</AuthSidebar>
