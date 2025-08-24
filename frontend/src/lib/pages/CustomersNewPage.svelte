<script lang="ts">
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CustomerForm from '../components/customers/CustomerForm.svelte';
  import { customerStore } from '../stores/customerStore';
  import { router } from '../stores/routerStore.js';

  async function handleSubmit(event: CustomEvent<any>) {
    // The form sends data wrapped in profile_customer, extract it
    const profileCustomerData = event.detail.profile_customer;
    const success = await customerStore.addProfileCustomer(profileCustomerData);
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