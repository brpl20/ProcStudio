<!-- components/customers/CustomerList.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import ConfirmDialog from '../ui/ConfirmDialog.svelte';
  import StatusBadge from '../ui/StatusBadge.svelte';
  import type { Customer, CustomerStatus, ProfileCustomer } from '../../api/types/customer.types';
  import { getProfileCustomerFullName, getProfileCustomerCpfOrCpnj, translateCustomerType, phoneMask } from '../../utils/profileCustomerUtils';

  export let customers: Customer[] = [];
  export let isLoading: boolean = false;

  const dispatch = createEventDispatcher<{
    edit: Customer;
    editProfile: ProfileCustomer;
    viewProfile: Customer;
    delete: number;
    deleteProfile: string;
    updateStatus: { id: number; status: CustomerStatus };
    resendConfirmation: number;
    inactivateProfile: string;
    restoreProfile: string;
  }>();

  let customerToDelete: Customer | null = null;
  let profileToDelete: ProfileCustomer | null = null;
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

  function handleEditProfileClick(profileCustomer: ProfileCustomer): void {
    dispatch('editProfile', profileCustomer);
  }

  function handleViewProfileClick(customer: Customer): void {
    dispatch('viewProfile', customer);
  }

  function handleStatusChange(customerId: number, newStatus: CustomerStatus): void {
    dispatch('updateStatus', { id: customerId, status: newStatus });
  }

  function confirmDelete(customer: Customer): void {
    customerToDelete = customer;
    profileToDelete = null;
    showDeleteConfirm = true;
  }

  function confirmDeleteProfile(profileCustomer: ProfileCustomer): void {
    profileToDelete = profileCustomer;
    customerToDelete = null;
    showDeleteConfirm = true;
  }

  function handleDeleteConfirm(): void {
    if (customerToDelete) {
      dispatch('delete', customerToDelete.id);
      customerToDelete = null;
    } else if (profileToDelete) {
      dispatch('deleteProfile', profileToDelete.id);
      profileToDelete = null;
    }
    showDeleteConfirm = false;
  }

  function handleResendConfirmation(customerId: number): void {
    dispatch('resendConfirmation', customerId);
  }

  function handleInactivateProfile(profileCustomer: ProfileCustomer): void {
    dispatch('inactivateProfile', profileCustomer.id);
  }

  function handleRestoreProfile(profileCustomer: ProfileCustomer): void {
    dispatch('restoreProfile', profileCustomer.id);
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
          <th>Nome Completo</th>
          <th>Email de Acesso</th>
          <th>CPF/CNPJ</th>
          <th>Tipo</th>
          <th>Contato</th>
          <th>Status</th>
          <th>Confirmado</th>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>
        {#each customers as customer (customer.id)}
          {@const profileCustomer = customer.profile_customer}
          {@const fullName = profileCustomer ? getProfileCustomerFullName(profileCustomer) : 'Nome não informado'}
          {@const cpfOrCnpj = profileCustomer ? getProfileCustomerCpfOrCpnj(profileCustomer) : 'Não possui'}
          {@const customerType = profileCustomer ? translateCustomerType(profileCustomer.attributes.customer_type) : 'Não definido'}
          {@const phone = profileCustomer?.attributes.default_phone ? phoneMask(profileCustomer.attributes.default_phone) : '-'}
          {@const isDeleted = customer.deleted || (profileCustomer?.attributes.deleted || false)}
          {@const isUnable = profileCustomer?.attributes?.capacity === 'unable'}
          {@const isRelativelyIncapable = profileCustomer?.attributes?.capacity === 'relatively'}
          {@const hasCapacityLimitation = isUnable || isRelativelyIncapable}

          <tr class:opacity-60={isDeleted} class:border-l-4={hasCapacityLimitation} class:border-warning={isRelativelyIncapable} class:border-error={isUnable}>
            <td>{customer.id}</td>
            <td class="font-medium">
              <div class="flex items-center gap-2">
                <span>{fullName}</span>
                {#if hasCapacityLimitation}
                  <div class="flex items-center gap-1">
                    {#if isUnable}
                      <span class="text-error" title="Cliente Incapaz - Requer Representação Legal">🚫</span>
                    {:else if isRelativelyIncapable}
                      <span class="text-warning" title="Cliente Relativamente Incapaz - Assistência Recomendada">⚠️</span>
                    {/if}
                  </div>
                {/if}
                {#if isDeleted}
                  <span class="badge badge-error badge-xs">Inativo</span>
                {/if}
              </div>
            </td>
            <td>{customer.access_email || '-'}</td>
            <td>
              <div class="flex items-center gap-2">
                <span>{cpfOrCnpj}</span>
                {#if cpfOrCnpj !== 'Não possui'}
                  <button
                    class="btn btn-xs btn-ghost"
                    on:click={() => {
                      if (navigator && navigator.clipboard) {
                        navigator.clipboard.writeText(cpfOrCnpj);
                      }
                    }}
                    title="Copiar CPF/CNPJ"
                  >
                    📋
                  </button>
                {/if}
              </div>
            </td>
            <td>
              <span class="badge badge-outline">
                {customerType}
              </span>
            </td>
            <td>{phone}</td>
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
            <td>
              <div class="dropdown dropdown-end">
                <button class="btn btn-sm btn-ghost">
                  ⋯
                </button>
                <ul class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
                  {#if !isDeleted}
                    <li>
                      <button
                        class="flex items-center gap-2"
                        on:click={() => handleViewProfileClick(customer)}
                        disabled={isLoading}
                      >
                        👁️ Ver Perfil
                      </button>
                    </li>
                    <li>
                      <button
                        class="flex items-center gap-2"
                        on:click={() => handleEditClick(customer)}
                        disabled={isLoading}
                      >
                        ✏️ Editar
                      </button>
                    </li>
                    {#if profileCustomer}
                      <li>
                        <button
                          class="flex items-center gap-2 text-warning"
                          on:click={() => handleInactivateProfile(profileCustomer)}
                          disabled={isLoading}
                        >
                          📦 Inativar Perfil
                        </button>
                      </li>
                    {/if}
                    <li>
                      <button
                        class="flex items-center gap-2 text-error"
                        on:click={() => confirmDelete(customer)}
                        disabled={isLoading}
                      >
                        🗑️ Remover
                      </button>
                    </li>
                  {:else}
                    {#if profileCustomer}
                      <li>
                        <button
                          class="flex items-center gap-2 text-success"
                          on:click={() => handleRestoreProfile(profileCustomer)}
                          disabled={isLoading}
                        >
                          ↩️ Ativar Perfil
                        </button>
                      </li>
                    {/if}
                    <li>
                      <button
                        class="flex items-center gap-2 text-error"
                        on:click={() => confirmDelete(customer)}
                        disabled={isLoading}
                      >
                        🗑️ Remover
                      </button>
                    </li>
                  {/if}
                </ul>
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
  message={
    customerToDelete
      ? `Tem certeza que deseja excluir o cliente ${customerToDelete.profile_customer ? getProfileCustomerFullName(customerToDelete.profile_customer) : customerToDelete.email || 'ID ' + customerToDelete.id}? Esta ação não pode ser desfeita.`
      : profileToDelete
        ? `Tem certeza que deseja excluir o cliente ${getProfileCustomerFullName(profileToDelete) || 'ID ' + profileToDelete.id}? Esta ação não pode ser desfeita.`
        : ''
  }
  confirmText="Excluir"
  cancelText="Cancelar"
  type="danger"
  on:confirm={handleDeleteConfirm}
/>
