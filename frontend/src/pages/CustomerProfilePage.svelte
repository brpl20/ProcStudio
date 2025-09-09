<!-- pages/CustomerProfilePage.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../lib/components/AuthSidebar.svelte';
  import CustomerProfileView from '../lib/components/customers/CustomerProfileView.svelte';
  import type { Customer } from '../lib/api/types/customer.types';
  import { api } from '../lib/api';

  export let customerId: number;

  let customer: Customer | null = null;
  let isLoading = true;
  let error: string | null = null;

  onMount(async () => {
    await loadCustomer();
  });

  async function loadCustomer() {
    if (!customerId) {
      error = 'ID do cliente não fornecido';
      isLoading = false;
      return;
    }

    try {
      isLoading = true;
      error = null;

      const response = await api.customers.getCustomer(customerId);

      if (response.success && response.data) {
        customer = response.data;
      } else {
        error = response.message || 'Erro ao carregar cliente';
      }
    } catch (err: any) {
      // Error loading customer
      error = err.message || 'Erro inesperado ao carregar cliente';
    } finally {
      isLoading = false;
    }
  }

  function handleEdit(event: CustomEvent<Customer>) {
    // Navigate to edit page
    window.location.href = `/customers/edit/${event.detail.id}`;
  }

  function handleClose() {
    // Navigate back to customers list
    window.location.href = '/customers';
  }
</script>

<svelte:head>
  <title>
    {customer
      ? `Perfil - ${customer.profile_customer?.attributes?.name || 'Cliente'}`
      : 'Carregando...'}
  </title>
</svelte:head>

<AuthSidebar>
  {#if isLoading}
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-center items-center h-64">
        <div class="flex flex-col items-center gap-4">
          <span class="loading loading-spinner loading-lg"></span>
          <p class="text-lg">Carregando perfil do cliente...</p>
        </div>
      </div>
    </div>
  {:else if error}
    <div class="container mx-auto px-4 py-8">
      <div class="alert alert-error max-w-md mx-auto">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="stroke-current shrink-0 h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
        <div>
          <h3 class="font-bold">Erro ao carregar cliente</h3>
          <div class="text-xs">{error}</div>
        </div>
      </div>

      <div class="text-center mt-6">
        <button class="btn btn-primary" on:click={handleClose}>
          ← Voltar à lista de clientes
        </button>
      </div>
    </div>
  {:else if customer}
    <CustomerProfileView {customer} {isLoading} on:edit={handleEdit} on:close={handleClose} />
  {:else}
    <div class="container mx-auto px-4 py-8">
      <div class="alert alert-warning max-w-md mx-auto">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="stroke-current shrink-0 h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
          />
        </svg>
        <div>
          <h3 class="font-bold">Cliente não encontrado</h3>
          <div class="text-xs">Não foi possível encontrar o cliente solicitado.</div>
        </div>
      </div>

      <div class="text-center mt-6">
        <button class="btn btn-primary" on:click={handleClose}>
          ← Voltar à lista de clientes
        </button>
      </div>
    </div>
  {/if}
</AuthSidebar>
