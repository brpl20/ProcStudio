<!-- components/customers/CustomerFilters.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let searchTerm: string = '';
  export let statusFilter: string = '';
  export let capacityFilter: string = '';
  export let customerTypeFilter: string = '';
  export let isLoading: boolean = false;

  const dispatch = createEventDispatcher<{
    search: { term: string };
    filterChange: {
      status: string;
      capacity: string;
      customerType: string;
    };
    clearFilters: void;
  }>();

  let searchInput: HTMLInputElement;
  let searchTimeout: ReturnType<typeof setTimeout>;

  // Handle search with debounce
  function handleSearchInput(): void {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      dispatch('search', { term: searchTerm });
    }, 500);
  }

  function handleFilterChange(): void {
    dispatch('filterChange', {
      status: statusFilter,
      capacity: capacityFilter,
      customerType: customerTypeFilter
    });
  }

  function clearAllFilters(): void {
    searchTerm = '';
    statusFilter = '';
    capacityFilter = '';
    customerTypeFilter = '';
    dispatch('clearFilters');
  }

  // Check if any filters are active
  $: hasActiveFilters = searchTerm || statusFilter || capacityFilter || customerTypeFilter;
</script>

<div class="card bg-base-200 shadow-sm mb-6">
  <div class="card-body p-4">
    <div class="flex flex-col lg:flex-row gap-4">
      <!-- Search Input -->
      <div class="flex-1">
        <div class="form-control">
          <label class="label" for="customer-search">
            <span class="label-text font-medium">Buscar clientes</span>
          </label>
          <div class="relative">
            <input
              id="customer-search"
              bind:this={searchInput}
              bind:value={searchTerm}
              on:input={handleSearchInput}
              type="text"
              placeholder="Nome, CPF, CNPJ ou email..."
              class="input input-bordered w-full pr-10"
              class:input-disabled={isLoading}
              disabled={isLoading}
            />
            {#if searchTerm}
              <button
                class="absolute right-3 top-1/2 transform -translate-y-1/2 btn btn-ghost btn-xs"
                on:click={() => {
                  searchTerm = '';
                  handleSearchInput();
                }}
                disabled={isLoading}
                aria-label="Limpar busca"
              >
                ✕
              </button>
            {/if}
          </div>
        </div>
      </div>

      <!-- Filters -->
      <div class="flex flex-col sm:flex-row gap-4 lg:flex-none lg:w-auto">
        <!-- Status Filter -->
        <div class="form-control">
          <label class="label" for="status-filter">
            <span class="label-text font-medium">Status</span>
          </label>
          <select
            id="status-filter"
            bind:value={statusFilter}
            on:change={handleFilterChange}
            class="select select-bordered select-sm"
            class:select-disabled={isLoading}
            disabled={isLoading}
          >
            <option value="">Todos</option>
            <option value="active">Ativo</option>
            <option value="inactive">Inativo</option>
            <option value="deceased">Falecido</option>
          </select>
        </div>

        <!-- Capacity Filter -->
        <div class="form-control">
          <label class="label" for="capacity-filter">
            <span class="label-text font-medium">Capacidade</span>
          </label>
          <select
            id="capacity-filter"
            bind:value={capacityFilter}
            on:change={handleFilterChange}
            class="select select-bordered select-sm"
            class:select-disabled={isLoading}
            disabled={isLoading}
          >
            <option value="">Todas</option>
            <option value="able">Capaz</option>
            <option value="relatively">Relativamente Incapaz</option>
            <option value="unable">Incapaz</option>
          </select>
        </div>

        <!-- Customer Type Filter -->
        <div class="form-control">
          <label class="label" for="type-filter">
            <span class="label-text font-medium">Tipo</span>
          </label>
          <select
            id="type-filter"
            bind:value={customerTypeFilter}
            on:change={handleFilterChange}
            class="select select-bordered select-sm"
            class:select-disabled={isLoading}
            disabled={isLoading}
          >
            <option value="">Todos</option>
            <option value="physical_person">Pessoa Física</option>
            <option value="legal_person">Pessoa Jurídica</option>
            <option value="representative">Representante Legal</option>
            <option value="counter">Contador</option>
          </select>
        </div>

        <!-- Clear Filters Button -->
        {#if hasActiveFilters}
          <div class="form-control">
            <div class="label">
              <span class="label-text opacity-0">Clear</span>
            </div>
            <button
              class="btn btn-outline btn-sm"
              on:click={clearAllFilters}
              disabled={isLoading}
              title="Limpar todos os filtros"
            >
              🗑️ Limpar
            </button>
          </div>
        {/if}
      </div>
    </div>

    <!-- Active Filters Summary -->
    {#if hasActiveFilters}
      <div class="mt-4 flex flex-wrap gap-2">
        <span class="text-sm font-medium text-base-content/70">Filtros ativos:</span>

        {#if searchTerm}
          <div class="badge badge-primary gap-1">
            🔍 "{searchTerm}"
            <button
              class="btn btn-ghost btn-xs p-0 min-h-0 h-auto"
              on:click={() => {
                searchTerm = '';
                handleSearchInput();
              }}
              disabled={isLoading}
            >
              ✕
            </button>
          </div>
        {/if}

        {#if statusFilter}
          <div class="badge badge-secondary gap-1">
            Status: {statusFilter === 'active'
              ? 'Ativo'
              : statusFilter === 'inactive'
                ? 'Inativo'
                : 'Falecido'}
            <button
              class="btn btn-ghost btn-xs p-0 min-h-0 h-auto"
              on:click={() => {
                statusFilter = '';
                handleFilterChange();
              }}
              disabled={isLoading}
            >
              ✕
            </button>
          </div>
        {/if}

        {#if capacityFilter}
          <div class="badge badge-accent gap-1">
            Capacidade: {capacityFilter === 'able'
              ? 'Capaz'
              : capacityFilter === 'relatively'
                ? 'Relativamente Incapaz'
                : 'Incapaz'}
            <button
              class="btn btn-ghost btn-xs p-0 min-h-0 h-auto"
              on:click={() => {
                capacityFilter = '';
                handleFilterChange();
              }}
              disabled={isLoading}
            >
              ✕
            </button>
          </div>
        {/if}

        {#if customerTypeFilter}
          <div class="badge badge-info gap-1">
            Tipo: {customerTypeFilter === 'physical_person'
              ? 'Pessoa Física'
              : customerTypeFilter === 'legal_person'
                ? 'Pessoa Jurídica'
                : customerTypeFilter === 'representative'
                  ? 'Representante Legal'
                  : 'Contador'}
            <button
              class="btn btn-ghost btn-xs p-0 min-h-0 h-auto"
              on:click={() => {
                customerTypeFilter = '';
                handleFilterChange();
              }}
              disabled={isLoading}
            >
              ✕
            </button>
          </div>
        {/if}
      </div>
    {/if}
  </div>
</div>
