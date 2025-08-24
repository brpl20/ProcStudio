<!-- CustomerNewPage.svelte -->
<script lang="ts">
  import { goto } from '$app/navigation';
  import CustomerForm from '../components/customers/CustomerForm.svelte';
  import { CustomerService } from '../api/services/customer.service';
  import { HttpClient } from '../api/utils/http-client';
  
  let isLoading = false;
  
  // Initialize the customer service
  const httpClient = new HttpClient();
  const customerService = new CustomerService(httpClient);

  async function handleSubmit(event: CustomEvent<any>) {
    isLoading = true;
    
    try {
      // Extract the profile_customer data from the event
      const profileCustomerData = event.detail.profile_customer;
      const response = await customerService.createProfileCustomer(profileCustomerData);
      
      if (response.success) {
        // Show success message
        alert('Cliente criado com sucesso!');
        
        // Redirect to customer details or list page
        goto(`/customers/${response.data.id}`);
      } else {
        throw new Error(response.message);
      }
    } catch (error: any) {
      console.error('Error creating customer:', error);
      
      // Handle validation errors
      if (error.response?.data?.errors) {
        const errors = error.response.data.errors;
        const errorMessages = Object.entries(errors)
          .map(([field, messages]) => `${field}: ${(messages as string[]).join(', ')}`)
          .join('\n');
        
        alert(`Erro ao criar cliente:\n${errorMessages}`);
      } else {
        alert(error.message || 'Erro ao criar cliente. Por favor, tente novamente.');
      }
    } finally {
      isLoading = false;
    }
  }

  function handleCancel() {
    goto('/customers');
  }
</script>

<div class="container mx-auto px-4 py-8">
  <div class="mb-6">
    <h1 class="text-3xl font-bold">Novo Cliente</h1>
    <p class="text-gray-600 mt-2">Preencha os dados para cadastrar um novo cliente</p>
  </div>

  <CustomerForm
    on:submit={handleSubmit}
    on:cancel={handleCancel}
    {isLoading}
  />
</div>