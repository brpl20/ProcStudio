<script lang="ts">
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CustomerForm from '../components/customers/CustomerForm.svelte';
  import { customerStore } from '../stores/customerStore';
  import { router } from '../stores/routerStore';
  import api from '../api/index';

  async function handleSubmit(event: CustomEvent<any>) {
    console.log('CustomersNewPage handleSubmit called with:', event.detail);

    const submitData = event.detail.data;

    // Check if we're creating a person with a representative/assistant
    if (submitData.represented && submitData.representor) {
      // This is a two-person creation with relationship
      const { represented, representor, relationship_type } = submitData;

      try {
        // Step 1: Create the represented person (unable or relatively incapable)
        const representedCustomer = await customerStore.addProfileCustomer(represented);

        if (representedCustomer && representedCustomer.id) {
          // Step 2: Create the representor (guardian or assistant)
          // Remove any relationship attributes that were added before
          const cleanRepresentorData = { ...representor };
          delete cleanRepresentorData.represents_attributes;
          delete cleanRepresentorData.represent_attributes;

          const representorCustomer = await customerStore.addProfileCustomer(cleanRepresentorData);

          if (representorCustomer && representorCustomer.id) {
            // Step 3: Create the Represent relationship between them
            console.log('Creating relationship:', {
              represented: representedCustomer.id,
              representor: representorCustomer.id,
              type: relationship_type
            });

            const relationshipResponse = await api.customers.createRepresent({
              profile_customer_id: parseInt(representedCustomer.id), // The person being represented
              representor_id: parseInt(representorCustomer.id), // The person who represents
              relationship_type: relationship_type,
              active: true
            });

            if (relationshipResponse.success) {
              console.log('Relationship created successfully');
              // All three operations successful
              router.navigate('/customers');
            } else {
              console.error('Failed to create relationship:', relationshipResponse.message);
              // The customers were created but relationship failed
              // You might want to show an error message here
            }
          }
        }
      } catch (error) {
        console.error('Error creating represented/representor relationship:', error);
      }
    } else {
      // Single person creation (normal flow)
      const profileCustomerData = submitData.profile_customer;
      console.log('Creating single customer with data:', profileCustomerData);
      const createdCustomer = await customerStore.addProfileCustomer(profileCustomerData);
      if (createdCustomer) {
        console.log('Customer created successfully:', createdCustomer);
        // Navigate back to customers list on success
        router.navigate('/customers');
      } else {
        console.log('Customer creation failed');
      }
    }
  }

  function handleCancel() {
    // Navigate back to customers list
    router.navigate('/customers');
  }
</script>

<AuthSidebar>
  <div class="container mx-auto py-6">
    <div class="mb-6"></div>

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
