<script lang="ts">
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CustomerForm from '../components/customers/CustomerForm.svelte';
  import { customerStore } from '../stores/customerStore';
  import { router } from '../stores/routerStore.js';
  import { onMount } from 'svelte';

  export let id: string;
  
  let customer: any = null;
  let isLoading = true;
  
  onMount(async () => {
    // Load the customer data
    const customerId = parseInt(id);
    if (!isNaN(customerId)) {
      const success = await customerStore.loadCustomer(customerId);
      if (success) {
        // Get the customer from the store
        const unsubscribe = customerStore.subscribe(state => {
          customer = state.currentCustomer;
          isLoading = false;
        });
        
        return () => unsubscribe();
      } else {
        // Customer not found, redirect to list
        router.navigate('/customers');
      }
    } else {
      // Invalid ID, redirect to list
      router.navigate('/customers');
    }
  });

  async function handleSubmit(event: CustomEvent<any>) {
    // The form sends data wrapped in profile_customer, extract it
    const profileCustomerData = event.detail.profile_customer;
    const customerId = parseInt(id);
    const success = await customerStore.updateProfileCustomer(customerId, profileCustomerData);
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
          <li><button type="button" class="link link-hover" on:click={() => router.navigate('/customers')}>Clientes</button></li>
          <li>Editar Cliente</li>
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
    {#if !isLoading && customer}
      <CustomerForm
        {customer}
        isLoading={$customerStore.isLoading}
        on:submit={handleSubmit}
        on:cancel={handleCancel}
      />
    {:else}
      <div class="flex justify-center py-8">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
    {/if}
  </div>
</AuthSidebar>