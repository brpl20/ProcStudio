<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import Icon from '../icons.svelte';
  import { authStore } from '../stores/authStore.js';
  import JobList from '../components/jobs/JobList.svelte';
</script>

<AuthSidebar>
  <div class="container mx-auto py-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">📋 Jobs</h2>
        </div>

        <JobList />
      </div>
    </div>
  </div>
</AuthSidebar>
