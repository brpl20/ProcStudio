<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CustomerList from '../components/customers/CustomerList.svelte';
  import { customerStore } from '../stores/customerStore';
  import { router } from '../stores/routerStore.js';
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
</script>

<AuthSidebar>
  <div class="container mx-auto py-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">👥 Clientes</h2>
          <button
            class="btn btn-primary"
            on:click={handleNewCustomer}
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

        <!-- Customers List -->
        <CustomerList
          customers={$customerStore.customers}
          isLoading={$customerStore.isLoading}
          on:edit={handleEditCustomer}
          on:delete={handleDeleteCustomer}
          on:updateStatus={handleUpdateStatus}
          on:resendConfirmation={handleResendConfirmation}
        />

        <!-- Refresh Button -->
        <div class="card-actions justify-end mt-6">
          <button
            class="btn btn-outline"
            class:loading={$customerStore.isLoading}
            on:click={() => customerStore.loadCustomers()}
            disabled={$customerStore.isLoading}
          >
            🔄 Atualizar
          </button>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>