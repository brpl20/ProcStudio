<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CustomerList from '../components/customers/CustomerList.svelte';
  import CustomerFilters from '../components/customers/CustomerFilters.svelte';
  import Pagination from '../components/ui/Pagination.svelte';
  import { customerStore } from '../stores/customerStore';
  import { router } from '../stores/routerStore';
  import type { Customer, CustomerStatus } from '../api/types/customer.types';

  onMount(() => {
    customerStore.loadCustomers();
  });

  function handleNewCustomer() {
    router.navigate('/customers/new');
  }

  async function handleUpdateStatus(event: CustomEvent<{ id: number; status: CustomerStatus }>) {
    const { id, status } = event.detail;
    await customerStore.updateStatus(id, status);
  }

  async function handleDeleteCustomer(event: CustomEvent<number>) {
    await customerStore.deleteCustomer(event.detail);
  }

  async function handleResendConfirmation(event: CustomEvent<number>) {
    await customerStore.resendConfirmation(event.detail);
  }

  async function handleEditCustomer(event: CustomEvent<Customer>) {
    router.navigate(`/customers/edit/${event.detail.id}`);
  }

  async function handleViewProfile(event: CustomEvent<Customer>) {
    router.navigate(`/customers/profile/${event.detail.id}`);
  }

  function handleSearch(event: CustomEvent<{ term: string }>) {
    customerStore.setSearch(event.detail.term);
  }

  function handleFilterChange(
    event: CustomEvent<{
      status: string;
      capacity: string;
      customerType: string;
    }>
  ) {
    customerStore.setFilters(event.detail);
  }

  function handleClearFilters() {
    customerStore.clearFilters();
  }

  function handlePageChange(event: CustomEvent<{ page: number }>) {
    customerStore.setPage(event.detail.page);
  }

  function handlePerPageChange(event: CustomEvent<{ perPage: number }>) {
    customerStore.setPerPage(event.detail.perPage);
  }
</script>

<AuthSidebar>
  <div class="min-h-screen bg-gradient-to-br from-[#eef0ef] to-white p-4 md:p-8">
    <div class="max-w-7xl mx-auto">

      {#if $customerStore.isLoading && $customerStore.paginatedCustomers.length === 0}
        <div class="flex items-center justify-center min-h-[400px]">
          <div class="flex flex-col items-center gap-4">
            <div class="w-16 h-16 border-4 border-[#0277EE] border-t-transparent rounded-full animate-spin"></div>
            <p class="text-[#01013D] font-medium">Carregando clientes...</p>
          </div>
        </div>
      {:else}

        <div class="mb-8">
          <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <h1 class="text-4xl font-bold text-[#01013D] mb-1">Clientes</h1>
              <p class="text-gray-600">Gerenciar e visualizar todos os clientes</p>
            </div>
            <button
              class="inline-flex items-center gap-2 bg-[#0277EE] hover:bg-[#01013D] text-white px-6 py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-xl transform hover:-translate-y-0.5 disabled:opacity-50 disabled:cursor-not-allowed"
              on:click={handleNewCustomer}
              disabled={$customerStore.isLoading}
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
              Novo Cliente
            </button>
          </div>
        </div>

        {#if $customerStore.error}
          <div class="bg-red-50 border-l-4 border-red-500 p-6 rounded-lg shadow-sm mb-6 animate-[fadeIn_0.3s_ease-in]">
            <div class="flex items-center gap-3">
              <svg class="w-6 h-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span class="text-red-800 font-medium">{$customerStore.error}</span>
            </div>
          </div>
        {/if}

        {#if $customerStore.success}
          <div class="bg-green-50 border-l-4 border-green-500 p-6 rounded-lg shadow-sm mb-6 animate-[fadeIn_0.3s_ease-in]">
            <div class="flex items-center gap-3">
              <svg class="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span class="text-green-800 font-medium">{$customerStore.success}</span>
            </div>
          </div>
        {/if}

        <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 mb-6">
          <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
            <h2 class="text-xl font-bold text-white flex items-center gap-2">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
              </svg>
              Filtros e Busca
            </h2>
          </div>
          <div class="p-6">
            <CustomerFilters
              searchTerm={$customerStore.filters.search}
              statusFilter={$customerStore.filters.status}
              capacityFilter={$customerStore.filters.capacity}
              customerTypeFilter={$customerStore.filters.customerType}
              isLoading={$customerStore.isLoading}
              on:search={handleSearch}
              on:filterChange={handleFilterChange}
              on:clearFilters={handleClearFilters}
            />
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100">
          <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
            <h2 class="text-xl font-bold text-white flex items-center gap-2">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              Clientes
              {#if $customerStore.pagination.totalRecords > 0}
                <span class="ml-auto text-sm font-normal bg-white/20 px-3 py-1 rounded-full">
                  {$customerStore.pagination.totalRecords} total
                </span>
              {/if}
            </h2>
          </div>
          <div class="overflow-x-auto">
            {#if $customerStore.isLoading && $customerStore.paginatedCustomers.length === 0}
              <div class="flex justify-center p-12">
                <div class="text-center">
                  <div class="w-12 h-12 border-4 border-[#0277EE] border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                  <p class="text-gray-500 font-medium">Carregando clientes...</p>
                </div>
              </div>
            {:else if $customerStore.paginatedCustomers.length === 0}
              <div class="flex justify-center p-12">
                <div class="text-center">
                  <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3a2 2 0 01-2-2V7a2 2 0 012-2h12a2 2 0 012 2v12a2 2 0 01-2 2z" />
                  </svg>
                  <p class="text-gray-500 font-medium mb-1">Nenhum cliente encontrado</p>
                  <p class="text-gray-400 text-sm">Comece adicionando um novo cliente</p>
                </div>
              </div>
            {:else}
              <CustomerList
                customers={$customerStore.paginatedCustomers}
                isLoading={$customerStore.isLoading}
                on:edit={handleEditCustomer}
                on:viewProfile={handleViewProfile}
                on:delete={handleDeleteCustomer}
                on:updateStatus={handleUpdateStatus}
                on:resendConfirmation={handleResendConfirmation}
              />
            {/if}
          </div>
        </div>

        {#if $customerStore.pagination.totalPages > 1}
          <div class="mt-6">
            <Pagination
              currentPage={$customerStore.pagination.currentPage}
              totalPages={$customerStore.pagination.totalPages}
              totalRecords={$customerStore.pagination.totalRecords}
              perPage={$customerStore.pagination.perPage}
              isLoading={$customerStore.isLoading}
              on:pageChange={handlePageChange}
              on:perPageChange={handlePerPageChange}
            />
          </div>
        {/if}

        <div class="mt-6 flex justify-center">
          <button
            class="inline-flex items-center gap-2 bg-gradient-to-r from-[#0277EE] to-[#01013D] hover:shadow-lg text-white px-8 py-3 rounded-lg font-semibold transition-all duration-300 shadow-md transform hover:-translate-y-0.5 disabled:opacity-50 disabled:cursor-not-allowed"
            on:click={() => customerStore.loadCustomers()}
            disabled={$customerStore.isLoading}
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            {$customerStore.isLoading ? 'Atualizando...' : 'Atualizar'}
          </button>
        </div>

      {/if}
    </div>
  </div>
</AuthSidebar>

<style>
  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }
</style>
