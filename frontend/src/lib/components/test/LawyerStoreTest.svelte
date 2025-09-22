<script>
  import { lawyerStore } from '../../stores/lawyerStore.svelte.ts';
  import { onMount, onDestroy } from 'svelte';

  let logs = [];
  let autoRefresh = false;
  let refreshInterval;

  function addLog(message, type = 'info') {
    const timestamp = new Date().toLocaleTimeString();
    logs = [...logs, { timestamp, message, type }];
  }

  onMount(() => {
    addLog('LawyerStore test component mounted', 'success');
  });

  onDestroy(() => {
    if (refreshInterval) {
      clearInterval(refreshInterval);
    }
    addLog('LawyerStore test component destroyed', 'info');
  });

  async function testFetchLawyers() {
    addLog('Testing fetchLawyers()...', 'loading');
    try {
      await lawyerStore.fetchLawyers();
      addLog('fetchLawyers() completed successfully', 'success');
    } catch (error) {
      addLog(`fetchLawyers() error: ${error.message}`, 'error');
    }
  }

  async function testRefresh() {
    addLog('Testing refresh()...', 'loading');
    try {
      await lawyerStore.refresh();
      addLog('refresh() completed successfully', 'success');
    } catch (error) {
      addLog(`refresh() error: ${error.message}`, 'error');
    }
  }

  async function testInit() {
    addLog('Testing init()...', 'loading');
    try {
      await lawyerStore.init();
      addLog('init() completed successfully', 'success');
    } catch (error) {
      addLog(`init() error: ${error.message}`, 'error');
    }
  }

  function testCancel() {
    addLog('Testing cancel()...');
    lawyerStore.cancel();
    addLog('cancel() completed', 'success');
  }

  function testDispose() {
    addLog('Testing dispose()...');
    lawyerStore.dispose();
    addLog('dispose() completed', 'success');
  }

  function selectFirstLawyer() {
    if (lawyerStore.lawyers.length === 0) {
      addLog('No lawyers available to select', 'error');
      return;
    }
    const firstLawyer = lawyerStore.lawyers[0];
    lawyerStore.selectLawyer(firstLawyer);
    addLog(`Selected lawyer: ${firstLawyer.attributes.name}`, 'success');
  }

  function clearSelection() {
    lawyerStore.clearSelectedLawyers();
    addLog('Selection cleared', 'success');
  }

  function clearLogs() {
    logs = [];
  }

  function toggleAutoRefresh() {
    autoRefresh = !autoRefresh;
    if (autoRefresh) {
      refreshInterval = setInterval(() => {
        // Force reactivity update
        lawyerStore.lawyers;
      }, 1000);
      addLog('Auto-refresh enabled', 'info');
    } else {
      if (refreshInterval) {
        clearInterval(refreshInterval);
        refreshInterval = null;
      }
      addLog('Auto-refresh disabled', 'info');
    }
  }
</script>

<div class="p-4 bg-base-100 rounded-lg shadow">
  <h2 class="text-xl font-bold mb-4">LawyerStore Debug Tool</h2>
  
  <!-- Store State Display -->
  <div class="mb-6">
    <h3 class="text-lg font-semibold mb-2">Store State</h3>
    <div class="bg-base-200 p-4 rounded">
      <div class="grid grid-cols-2 gap-4 text-sm">
        <div>
          <strong>Status:</strong> 
          <span class="badge badge-{lawyerStore.status === 'success' ? 'success' : lawyerStore.status === 'error' ? 'error' : lawyerStore.status === 'loading' ? 'warning' : 'ghost'}">
            {lawyerStore.status}
          </span>
        </div>
        <div><strong>Loading:</strong> {lawyerStore.loading}</div>
        <div><strong>Initialized:</strong> {lawyerStore.initialized}</div>
        <div><strong>Disposed:</strong> {lawyerStore.isDisposed}</div>
        <div><strong>Total Lawyers:</strong> {lawyerStore.lawyersCount}</div>
        <div><strong>Active Lawyers:</strong> {lawyerStore.activeLawyers.length}</div>
        <div><strong>Available Lawyers:</strong> {lawyerStore.availableLawyers.length}</div>
        <div><strong>Selected Count:</strong> {lawyerStore.selectedLawyersCount}</div>
        <div><strong>Remaining Count:</strong> {lawyerStore.remainingLawyersCount}</div>
        <div><strong>Error:</strong> {lawyerStore.error || 'None'}</div>
      </div>
    </div>
  </div>

  <!-- Action Buttons -->
  <div class="mb-6">
    <h3 class="text-lg font-semibold mb-2">Store Actions</h3>
    <div class="flex flex-wrap gap-2">
      <button class="btn btn-primary btn-sm" onclick={testFetchLawyers}>Fetch Lawyers</button>
      <button class="btn btn-secondary btn-sm" onclick={testRefresh}>Refresh</button>
      <button class="btn btn-accent btn-sm" onclick={testInit}>Initialize</button>
      <button class="btn btn-warning btn-sm" onclick={testCancel}>Cancel</button>
      <button class="btn btn-error btn-sm" onclick={testDispose}>Dispose</button>
    </div>
  </div>

  <!-- Selection Actions -->
  <div class="mb-6">
    <h3 class="text-lg font-semibold mb-2">Selection Actions</h3>
    <div class="flex flex-wrap gap-2">
      <button class="btn btn-outline btn-sm" onclick={selectFirstLawyer}>Select First</button>
      <button class="btn btn-outline btn-sm" onclick={clearSelection}>Clear Selection</button>
      <button class="btn btn-outline btn-sm" onclick={toggleAutoRefresh}>
        {autoRefresh ? 'Disable' : 'Enable'} Auto-refresh
      </button>
    </div>
  </div>

  <!-- All Lawyers List -->
  {#if lawyerStore.lawyers.length > 0}
    <div class="mb-6">
      <h3 class="text-lg font-semibold mb-2">All Lawyers ({lawyerStore.lawyersCount})</h3>
      <div class="max-h-40 overflow-y-auto bg-base-200 p-2 rounded">
        {#each lawyerStore.lawyers as lawyer}
          <div class="flex justify-between items-center p-2 border-b border-base-300 last:border-b-0">
            <span class="text-sm">
              {lawyer.attributes.name} {lawyer.attributes.last_name}
              <span class="text-xs text-gray-500">({lawyer.attributes.status})</span>
              {#if lawyer.attributes.deleted}
                <span class="text-xs text-red-500">[DELETED]</span>
              {/if}
            </span>
            <button 
              class="btn btn-xs {lawyerStore.selectedLawyers.some(s => s.id === lawyer.id) ? 'btn-error' : 'btn-success'}"
              onclick={() => {
                if (lawyerStore.selectedLawyers.some(s => s.id === lawyer.id)) {
                  lawyerStore.unselectLawyer(lawyer.id);
                  addLog(`Unselected ${lawyer.attributes.name}`, 'info');
                } else {
                  lawyerStore.selectLawyer(lawyer);
                  addLog(`Selected ${lawyer.attributes.name}`, 'success');
                }
              }}
            >
              {lawyerStore.selectedLawyers.some(s => s.id === lawyer.id) ? 'Unselect' : 'Select'}
            </button>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Active Lawyers List -->
  {#if lawyerStore.activeLawyers.length > 0}
    <div class="mb-6">
      <h3 class="text-lg font-semibold mb-2">Active Lawyers ({lawyerStore.activeLawyers.length})</h3>
      <div class="max-h-40 overflow-y-auto bg-green-50 p-2 rounded border border-green-200">
        {#each lawyerStore.activeLawyers as lawyer}
          <div class="flex justify-between items-center p-2 border-b border-green-200 last:border-b-0">
            <span class="text-sm text-green-800">
              {lawyer.attributes.name} {lawyer.attributes.last_name}
              <span class="text-xs text-green-600">({lawyer.attributes.status})</span>
              {#if lawyer.attributes.oab}
                <span class="text-xs text-green-600">[OAB: {lawyer.attributes.oab}]</span>
              {/if}
            </span>
            <button 
              class="btn btn-xs {lawyerStore.selectedLawyers.some(s => s.id === lawyer.id) ? 'btn-error' : 'btn-success'}"
              onclick={() => {
                if (lawyerStore.selectedLawyers.some(s => s.id === lawyer.id)) {
                  lawyerStore.unselectLawyer(lawyer.id);
                  addLog(`Unselected active lawyer ${lawyer.attributes.name}`, 'info');
                } else {
                  lawyerStore.selectLawyer(lawyer);
                  addLog(`Selected active lawyer ${lawyer.attributes.name}`, 'success');
                }
              }}
            >
              {lawyerStore.selectedLawyers.some(s => s.id === lawyer.id) ? 'Unselect' : 'Select'}
            </button>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Available Lawyers List -->
  {#if lawyerStore.availableLawyers.length > 0}
    <div class="mb-6">
      <h3 class="text-lg font-semibold mb-2">Available Lawyers ({lawyerStore.availableLawyers.length})</h3>
      <div class="max-h-40 overflow-y-auto bg-blue-50 p-2 rounded border border-blue-200">
        {#each lawyerStore.availableLawyers as lawyer}
          <div class="flex justify-between items-center p-2 border-b border-blue-200 last:border-b-0">
            <span class="text-sm text-blue-800">
              {lawyer.attributes.name} {lawyer.attributes.last_name}
              <span class="text-xs text-blue-600">({lawyer.attributes.status})</span>
              {#if lawyer.attributes.oab}
                <span class="text-xs text-blue-600">[OAB: {lawyer.attributes.oab}]</span>
              {/if}
            </span>
            <button 
              class="btn btn-xs btn-success"
              onclick={() => {
                lawyerStore.selectLawyer(lawyer);
                addLog(`Selected available lawyer ${lawyer.attributes.name}`, 'success');
              }}
            >
              Select
            </button>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Selected Lawyers -->
  {#if lawyerStore.selectedLawyers.length > 0}
    <div class="mb-6">
      <h3 class="text-lg font-semibold mb-2">Selected Lawyers ({lawyerStore.selectedLawyersCount})</h3>
      <div class="bg-green-50 p-2 rounded">
        {#each lawyerStore.selectedLawyers as lawyer}
          <div class="text-sm p-1">
            {lawyer.attributes.name} {lawyer.attributes.last_name}
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <!-- Logs -->
  <div class="mb-4">
    <h3 class="text-lg font-semibold mb-2">Logs</h3>
    <div class="flex gap-2 mb-2">
      <button class="btn btn-outline btn-xs" onclick={clearLogs}>Clear Logs</button>
    </div>
    <div class="max-h-60 overflow-y-auto bg-base-200 p-2 rounded text-xs">
      {#each logs as log}
        <div class="text-{log.type === 'error' ? 'red-600' : log.type === 'success' ? 'green-600' : log.type === 'loading' ? 'orange-600' : 'gray-700'}">
          [{log.timestamp}] {log.message}
        </div>
      {/each}
    </div>
  </div>
</div>