<!-- components/ui/Pagination.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let currentPage: number = 1;
  export let totalPages: number = 1;
  export let totalRecords: number = 0;
  export let perPage: number = 50;
  export let isLoading: boolean = false;

  const dispatch = createEventDispatcher<{
    pageChange: { page: number };
    perPageChange: { perPage: number };
  }>();

  $: startRecord = totalRecords > 0 ? (currentPage - 1) * perPage + 1 : 0;
  $: endRecord = Math.min(currentPage * perPage, totalRecords);

  // Generate page numbers to display
  $: visiblePages = generateVisiblePages(currentPage, totalPages);

  function generateVisiblePages(current: number, total: number): number[] {
    if (total <= 7) {
      return Array.from({ length: total }, (_, i) => i + 1);
    }

    if (current <= 4) {
      return [1, 2, 3, 4, 5, -1, total];
    }

    if (current >= total - 3) {
      return [1, -1, total - 4, total - 3, total - 2, total - 1, total];
    }

    return [1, -1, current - 1, current, current + 1, -1, total];
  }

  function handlePageChange(page: number): void {
    if (page !== currentPage && page >= 1 && page <= totalPages && !isLoading) {
      dispatch('pageChange', { page });
    }
  }

  function handlePerPageChange(event: Event): void {
    const target = event.target as HTMLSelectElement;
    const newPerPage = parseInt(target.value);
    if (newPerPage !== perPage) {
      dispatch('perPageChange', { perPage: newPerPage });
    }
  }

  function handlePreviousPage(): void {
    if (currentPage > 1) {
      handlePageChange(currentPage - 1);
    }
  }

  function handleNextPage(): void {
    if (currentPage < totalPages) {
      handlePageChange(currentPage + 1);
    }
  }
</script>

{#if totalPages > 1}
  <div class="flex flex-col sm:flex-row items-center justify-between gap-4 mt-6">
    <!-- Records info -->
    <div class="text-sm text-base-content/70">
      {#if totalRecords > 0}
        Mostrando <span class="font-medium">{startRecord}</span> a
        <span class="font-medium">{endRecord}</span>
        de <span class="font-medium">{totalRecords}</span> registros
      {:else}
        Nenhum registro encontrado
      {/if}
    </div>

    <!-- Pagination controls -->
    <div class="flex items-center gap-2">
      <!-- Per page selector -->
      <div class="flex items-center gap-2 mr-4">
        <span class="text-sm text-base-content/70">Por página:</span>
        <select
          class="select select-sm select-bordered"
          value={perPage}
          on:change={handlePerPageChange}
          disabled={isLoading}
        >
          <option value="10">10</option>
          <option value="25">25</option>
          <option value="50">50</option>
        </select>
      </div>

      <!-- Previous button -->
      <button
        class="btn btn-sm btn-outline"
        class:btn-disabled={currentPage <= 1 || isLoading}
        on:click={handlePreviousPage}
        disabled={currentPage <= 1 || isLoading}
        aria-label="Página anterior"
      >
        ←
      </button>

      <!-- Page numbers -->
      <div class="join">
        {#each visiblePages as page}
          {#if page === -1}
            <span class="join-item btn btn-sm btn-disabled">...</span>
          {:else}
            <button
              class="join-item btn btn-sm"
              class:btn-active={page === currentPage}
              class:btn-disabled={isLoading}
              on:click={() => handlePageChange(page)}
              disabled={isLoading}
              aria-label="Página {page}"
              aria-current={page === currentPage ? 'page' : undefined}
            >
              {page}
            </button>
          {/if}
        {/each}
      </div>

      <!-- Next button -->
      <button
        class="btn btn-sm btn-outline"
        class:btn-disabled={currentPage >= totalPages || isLoading}
        on:click={handleNextPage}
        disabled={currentPage >= totalPages || isLoading}
        aria-label="Próxima página"
      >
        →
      </button>
    </div>
  </div>
{:else if totalRecords > 0}
  <!-- Show record count when there's only one page -->
  <div class="flex justify-center mt-6">
    <div class="text-sm text-base-content/70">
      Total: <span class="font-medium">{totalRecords}</span> registros
    </div>
  </div>
{/if}

{#if isLoading}
  <div class="flex justify-center mt-4">
    <span class="loading loading-spinner loading-sm"></span>
  </div>
{/if}
