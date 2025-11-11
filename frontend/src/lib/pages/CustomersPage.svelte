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
    // Navigate to edit page
    router.navigate(`/customers/edit/${event.detail.id}`);
  }

  async function handleViewProfile(event: CustomEvent<Customer>) {
    // Navigate to profile view page
    router.navigate(`/customers/profile/${event.detail.id}`);
  }

  // Search and filtering handlers (no API calls needed)
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

  // Pagination handlers (no API calls needed)
  function handlePageChange(event: CustomEvent<{ page: number }>) {
    customerStore.setPage(event.detail.page);
  }

  function handlePerPageChange(event: CustomEvent<{ perPage: number }>) {
    customerStore.setPerPage(event.detail.perPage);
  }
</script>

<AuthSidebar>
  <div class="container mx-auto py-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">👥 Clientes</h2>
          <button
            class="btn btn-primary"
            onclick={handleNewCustomer}
            disabled={$customerStore.isLoading}
          >
            + Novo Cliente
          </button>
        </div>

        <!-- Messages -->
        {#if $customerStore.error}
          <div class="alert alert-error mb-4">
            <span>{$customerStore.error}</span>
          </div>
        {/if}

        {#if $customerStore.success}
          <div class="alert alert-success mb-4">
            <span>{$customerStore.success}</span>
          </div>
        {/if}

        <!-- Search and Filters -->
        <CustomerFilters
          searchTerm={$customerStore.filters.search}
          statusFilter={$customerStore.filters.status}
          capacityFilter={$customerStore.filters.capacity}
          customerTypeFilter={$customerStore.filters.customerType}
          isLoading={$customerStore.isLoading}
          onSearch={handleSearch}
          onFilterChange={handleFilterChange}
          onClearFilters={handleClearFilters}
        />

        <!-- Customers List -->
        <CustomerList
          customers={$customerStore.paginatedCustomers}
          isLoading={$customerStore.isLoading}
          onEdit={handleEditCustomer}
          onViewProfile={handleViewProfile}
          onDelete={handleDeleteCustomer}
          onUpdateStatus={handleUpdateStatus}
          onResendConfirmation={handleResendConfirmation}
        />

        <!-- Pagination -->
        <Pagination
          currentPage={$customerStore.pagination.currentPage}
          totalPages={$customerStore.pagination.totalPages}
          totalRecords={$customerStore.pagination.totalRecords}
          perPage={$customerStore.pagination.perPage}
          isLoading={$customerStore.isLoading}
          onPageChange={handlePageChange}
          onPerPageChange={handlePerPageChange}
        />

        <!-- Refresh Button -->
        <div class="card-actions justify-end mt-6">
          <button
            class="btn btn-outline"
            class:loading={$customerStore.isLoading}
            onclick={() => customerStore.loadCustomers()}
            disabled={$customerStore.isLoading}
          >
            🔄 Atualizar
          </button>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
