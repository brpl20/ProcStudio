<script lang="ts">
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CustomerForm from '../components/customers/CustomerForm.svelte';
  import { customerStore } from '../stores/customerStore';
  import { router } from '../stores/routerStore.js';
  import type { CreateCustomerRequest } from '../api/types/customer.types';

  async function handleSubmit(event: CustomEvent<CreateCustomerRequest>) {
    console.log('Creating customer with data:', event.detail);
    const success = await customerStore.addCustomer(event.detail);
    if (success) {
      // Navigate back to customers list on success
      router.navigate('/customers');
    }
  }

  function handleCancel() {
    // Navigate back to customers list
    router.navigate('/customers');
  }
</script>

<AuthSidebar>
  <div class="container mx-auto py-6">
    <div class="mb-6">
      <!-- Back button -->
      <div class="breadcrumbs text-sm">
        <ul>
          <li><a href="#" on:click|preventDefault={() => router.navigate('/customers')}>Clientes</a></li>
          <li>Novo Cliente</li>
        </ul>
      </div>
    </div>

    <!-- Messages -->
    {#if $customerStore.error}
      <div class="alert alert-error mb-6">
        <span>{$customerStore.error}</span>
      </div>
    {/if}

    {#if $customerStore.success}
      <div class="alert alert-success mb-6">
        <span>{$customerStore.success}</span>
      </div>
    {/if}

    <!-- Customer Form -->
    <CustomerForm
      isLoading={$customerStore.isLoading}
      on:submit={handleSubmit}
      on:cancel={handleCancel}
    />
  </div>
</AuthSidebar>