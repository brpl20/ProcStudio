<!-- components/customers/CustomerList.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import ConfirmDialog from '../ui/ConfirmDialog.svelte';
  import StatusBadge from '../ui/StatusBadge.svelte';
  import type { Customer, CustomerStatus } from '../../api/types/customer.types';

  export let customers: Customer[] = [];
  export let isLoading: boolean = false;

  const dispatch = createEventDispatcher<{
    edit: Customer;
    delete: number;
    updateStatus: { id: number; status: CustomerStatus };
    resendConfirmation: number;
  }>();

  let customerToDelete: Customer | null = null;
  let showDeleteConfirm: boolean = false;

  function formatDate(dateString?: string | null): string {
    if (!dateString) {
      return '-';
    }
    try {
      return new Date(dateString).toLocaleDateString('pt-BR');
    } catch (error) {
      console.warn('Invalid date:', dateString);
      return '-';
    }
  }

  function handleEditClick(customer: Customer): void {
    dispatch('edit', customer);
  }

  function handleStatusChange(customerId: number, newStatus: CustomerStatus): void {
    dispatch('updateStatus', { id: customerId, status: newStatus });
  }

  function confirmDelete(customer: Customer): void {
    customerToDelete = customer;
    showDeleteConfirm = true;
  }

  function handleDeleteConfirm(): void {
    if (customerToDelete) {
      dispatch('delete', customerToDelete.id);
      customerToDelete = null;
      showDeleteConfirm = false;
    }
  }

  function handleResendConfirmation(customerId: number): void {
    dispatch('resendConfirmation', customerId);
  }
</script>

{#if isLoading && customers.length === 0}
  <div class="flex justify-center py-8">
    <span class="loading loading-spinner loading-lg"></span>
  </div>
{:else if customers.length === 0}
  <div class="text-center py-8">
    <p class="text-lg opacity-70">Nenhum cliente encontrado</p>
    <p class="text-sm opacity-50">Clique em "Novo Cliente" para começar</p>
  </div>
{:else}
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
            <td>{customer.email || '-'}</td>
            <td>
              <select
                class="select select-sm select-bordered"
                value={customer.status}
                on:change={(e) => handleStatusChange(customer.id, e.currentTarget.value as CustomerStatus)}
                disabled={isLoading}
              >
                <option value="active">Ativo</option>
                <option value="inactive">Inativo</option>
                <option value="deceased">Falecido</option>
              </select>
            </td>
            <td>
              <div class="flex items-center gap-2">
                <StatusBadge
                  status={customer.confirmed_at ? 'confirmed' : 'unconfirmed'}
                />

                {#if !customer.confirmed_at}
                  <button
                    class="btn btn-xs btn-outline"
                    on:click={() => handleResendConfirmation(customer.id)}
                    disabled={isLoading}
                  >
                    Reenviar
                  </button>
                {/if}
              </div>
            </td>
            <td>{formatDate(customer.created_at)}</td>
            <td>
              <div class="flex gap-2">
                <button
                  class="btn btn-sm btn-ghost"
                  on:click={() => handleEditClick(customer)}
                  disabled={isLoading}
                  aria-label="Editar cliente"
                >
                  ✏️
                </button>
                <button
                  class="btn btn-sm btn-error"
                  on:click={() => confirmDelete(customer)}
                  disabled={isLoading}
                  aria-label="Excluir cliente"
                >
                  🗑️
                </button>
              </div>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
{/if}

<ConfirmDialog
  bind:show={showDeleteConfirm}
  title="Excluir Cliente"
  message={customerToDelete ? `Tem certeza que deseja excluir o cliente ${customerToDelete.email || 'ID ' + customerToDelete.id}? Esta ação não pode ser desfeita.` : ''}
  confirmText="Excluir"
  cancelText="Cancelar"
  type="danger"
  on:confirm={handleDeleteConfirm}
/>