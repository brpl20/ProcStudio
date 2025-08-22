<script>
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import api from '../api/index';
  import { onMount } from 'svelte';

  let customers = [];
  let isLoading = false;
  let error = '';
  let success = '';

  // Form state
  let newCustomerEmail = '';
  let newCustomerPassword = '';
  let newCustomerPasswordConfirmation = '';
  let newCustomerStatus = 'active';
  let showNewCustomerForm = false;

  // Edit state
  let editingCustomer = null;
  let editEmail = '';
  let editStatus = 'active';

  onMount(() => {
    loadCustomers();
  });

  async function loadCustomers() {
    isLoading = true;
    error = '';

    try {
      const result = await api.customers.getCustomers();

      if (result.success) {
        customers = result.data || [];
        success = 'Clientes carregados com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao carregar clientes';
      }
    } catch (err) {
      console.error('Error loading customers:', err);
      error = 'Erro ao carregar clientes';
    } finally {
      isLoading = false;
    }
  }

  async function addCustomer() {
    if (!newCustomerEmail || !newCustomerPassword || !newCustomerPasswordConfirmation) {
      error = 'Email e senha são obrigatórios';
      return;
    }

    if (newCustomerPassword !== newCustomerPasswordConfirmation) {
      error = 'Senha e confirmação de senha não coincidem';
      return;
    }

    isLoading = true;
    error = '';

    try {
      const customerData = {
        email: newCustomerEmail.trim(),
        password: newCustomerPassword,
        password_confirmation: newCustomerPasswordConfirmation,
        status: newCustomerStatus
      };

      const result = await api.customers.createCustomer(customerData);

      if (result.success) {
        await loadCustomers();
        success = 'Cliente criado com sucesso';
        resetNewCustomerForm();
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao criar cliente';
      }
    } catch (err) {
      console.error('Error creating customer:', err);
      error = 'Erro ao criar cliente';
    } finally {
      isLoading = false;
    }
  }

  async function updateCustomerStatus(customerId, newStatus) {
    isLoading = true;
    error = '';

    try {
      const result = await api.customers.updateCustomer(customerId, { status: newStatus });

      if (result.success) {
        await loadCustomers();
        success = 'Status atualizado com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao atualizar status';
      }
    } catch (err) {
      console.error('Error updating customer status:', err);
      error = 'Erro ao atualizar status';
    } finally {
      isLoading = false;
    }
  }

  async function saveEditCustomer() {
    if (!editEmail) {
      error = 'Email é obrigatório';
      return;
    }

    isLoading = true;
    error = '';

    try {
      const customerData = {
        email: editEmail.trim(),
        status: editStatus
      };

      const result = await api.customers.updateCustomer(editingCustomer.id, customerData);

      if (result.success) {
        await loadCustomers();
        success = 'Cliente atualizado com sucesso';
        cancelEdit();
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao atualizar cliente';
      }
    } catch (err) {
      console.error('Error updating customer:', err);
      error = 'Erro ao atualizar cliente';
    } finally {
      isLoading = false;
    }
  }

  async function deleteCustomer(customerId) {
    if (!window.confirm('Tem certeza que deseja excluir este cliente?')) {
      return;
    }

    isLoading = true;
    error = '';

    try {
      const result = await api.customers.deleteCustomer(customerId);

      if (result.success) {
        await loadCustomers();
        success = 'Cliente excluído com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao excluir cliente';
      }
    } catch (err) {
      console.error('Error deleting customer:', err);
      error = 'Erro ao excluir cliente';
    } finally {
      isLoading = false;
    }
  }

  async function resendConfirmation(customerId) {
    isLoading = true;
    error = '';

    try {
      const result = await api.customers.resendConfirmation(customerId);

      if (result.success) {
        success = 'Email de confirmação reenviado com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao reenviar confirmação';
      }
    } catch (err) {
      console.error('Error resending confirmation:', err);
      error = 'Erro ao reenviar confirmação';
    } finally {
      isLoading = false;
    }
  }

  function startEdit(customer) {
    editingCustomer = customer;
    editEmail = customer.email;
    editStatus = customer.status;
  }

  function cancelEdit() {
    editingCustomer = null;
    editEmail = '';
    editStatus = 'active';
  }

  function resetNewCustomerForm() {
    newCustomerEmail = '';
    newCustomerPassword = '';
    newCustomerPasswordConfirmation = '';
    newCustomerStatus = 'active';
    showNewCustomerForm = false;
  }

  function getStatusBadge(status) {
    switch (status) {
    case 'active':
      return 'badge-success';
    case 'inactive':
      return 'badge-warning';
    case 'deceased':
      return 'badge-neutral';
    default:
      return 'badge-ghost';
    }
  }

  function getStatusLabel(status) {
    switch (status) {
    case 'active':
      return 'Ativo';
    case 'inactive':
      return 'Inativo';
    case 'deceased':
      return 'Falecido';
    default:
      return status;
    }
  }

  function formatDate(dateString) {
    if (!dateString) {
      return '-';
    }
    return new Date(dateString).toLocaleDateString('pt-BR');
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
            on:click={() => (showNewCustomerForm = !showNewCustomerForm)}
            disabled={isLoading}
          >
            + Novo Cliente
          </button>
        </div>

        <!-- Messages -->
        {#if error}
          <div class="alert alert-error mb-4">
            <span>{error}</span>
          </div>
        {/if}

        {#if success}
          <div class="alert alert-success mb-4">
            <span>{success}</span>
          </div>
        {/if}

        <!-- New Customer Form -->
        {#if showNewCustomerForm}
          <div class="card bg-base-200 shadow mb-6">
            <div class="card-body">
              <h3 class="card-title">Novo Cliente</h3>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Email *</span>
                  </label>
                  <input
                    type="email"
                    class="input input-bordered"
                    bind:value={newCustomerEmail}
                    placeholder="email@exemplo.com"
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Status</span>
                  </label>
                  <select
                    class="select select-bordered"
                    bind:value={newCustomerStatus}
                    disabled={isLoading}
                  >
                    <option value="active">Ativo</option>
                    <option value="inactive">Inativo</option>
                    <option value="deceased">Falecido</option>
                  </select>
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Senha *</span>
                  </label>
                  <input
                    type="password"
                    class="input input-bordered"
                    bind:value={newCustomerPassword}
                    placeholder="Senha"
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Confirmar Senha *</span>
                  </label>
                  <input
                    type="password"
                    class="input input-bordered"
                    bind:value={newCustomerPasswordConfirmation}
                    placeholder="Confirmar senha"
                    disabled={isLoading}
                  />
                </div>
              </div>

              <div class="card-actions justify-end mt-4">
                <button class="btn btn-ghost" on:click={resetNewCustomerForm} disabled={isLoading}>
                  Cancelar
                </button>
                <button
                  class="btn btn-primary"
                  class:loading={isLoading}
                  on:click={addCustomer}
                  disabled={isLoading}
                >
                  Criar Cliente
                </button>
              </div>
            </div>
          </div>
        {/if}

        <!-- Loading -->
        {#if isLoading && customers.length === 0}
          <div class="flex justify-center py-8">
            <span class="loading loading-spinner loading-lg"></span>
          </div>
        {/if}

        <!-- Customers List -->
        {#if customers.length > 0}
          <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Email</th>
                  <th>Status</th>
                  <th>Confirmado</th>
                  <th>Criado em</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {#each customers as customer (customer.id)}
                  <tr>
                    <td>{customer.id}</td>
                    <td>
                      {#if editingCustomer && editingCustomer.id === customer.id}
                        <input
                          type="email"
                          class="input input-sm input-bordered"
                          bind:value={editEmail}
                          disabled={isLoading}
                        />
                      {:else}
                        {customer.email}
                      {/if}
                    </td>
                    <td>
                      <select
                        class="select select-sm select-bordered"
                        value={customer.status}
                        on:change={(e) => updateCustomerStatus(customer.id, e.target.value)}
                        disabled={isLoading}
                      >
                        <option value="active">Ativo</option>
                        <option value="inactive">Inativo</option>
                        <option value="deceased">Falecido</option>
                      </select>
                    </td>
                    <td>
                      <div class="flex items-center gap-2">
                        <span
                          class="badge {customer.confirmed_at ? 'badge-success' : 'badge-warning'}"
                        >
                          {customer.confirmed_at ? 'Sim' : 'Não'}
                        </span>
                        {#if !customer.confirmed_at}
                          <button
                            class="btn btn-xs btn-outline"
                            on:click={() => resendConfirmation(customer.id)}
                            disabled={isLoading}
                          >
                            Reenviar
                          </button>
                        {/if}
                      </div>
                    </td>
                    <td>{formatDate(customer.created_at)}</td>
                    <td>
                      {#if editingCustomer && editingCustomer.id === customer.id}
                        <div class="flex gap-2">
                          <button
                            class="btn btn-sm btn-success"
                            on:click={saveEditCustomer}
                            disabled={isLoading}
                          >
                            Salvar
                          </button>
                          <button
                            class="btn btn-sm btn-ghost"
                            on:click={cancelEdit}
                            disabled={isLoading}
                          >
                            Cancelar
                          </button>
                        </div>
                      {:else}
                        <div class="flex gap-2">
                          <button
                            class="btn btn-sm btn-ghost"
                            on:click={() => startEdit(customer)}
                            disabled={isLoading}
                          >
                            ✏️
                          </button>
                          <button
                            class="btn btn-sm btn-error"
                            on:click={() => deleteCustomer(customer.id)}
                            disabled={isLoading}
                          >
                            🗑️
                          </button>
                        </div>
                      {/if}
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        {:else if !isLoading}
          <div class="text-center py-8">
            <p class="text-lg opacity-70">Nenhum cliente encontrado</p>
            <p class="text-sm opacity-50">Clique em "Novo Cliente" para começar</p>
          </div>
        {/if}

        <!-- Refresh Button -->
        <div class="card-actions justify-end mt-6">
          <button
            class="btn btn-outline"
            class:loading={isLoading}
            on:click={loadCustomers}
            disabled={isLoading}
          >
            🔄 Atualizar
          </button>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
