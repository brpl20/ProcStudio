<!-- components/customers/CustomerList.svelte -->
<script lang="ts">
  import ConfirmDialog from '../ui/ConfirmDialog.svelte';
  import StatusBadge from '../ui/StatusBadge.svelte';
  import type { Customer, CustomerStatus, ProfileCustomer } from '../../api/types/customer.types';
  import {
    getProfileCustomerFullName,
    getProfileCustomerCpfOrCpnj,
    translateCustomerType,
    phoneMask
  } from '../../utils/profileCustomerUtils';

  let {
    customers = [],
    isLoading = false,
    onEdit = () => {},
    onEditProfile = () => {},
    onViewProfile = () => {},
    onDelete = () => {},
    onDeleteProfile = () => {},
    onUpdateStatus = () => {},
    onResendConfirmation = () => {},
    onInactivateProfile = () => {},
    onRestoreProfile = () => {}
  }: {
    customers?: Customer[];
    isLoading?: boolean;
    onEdit?: (customer: Customer) => void;
    onEditProfile?: (profileCustomer: ProfileCustomer) => void;
    onViewProfile?: (customer: Customer) => void;
    onDelete?: (customerId: number) => void;
    onDeleteProfile?: (profileId: string) => void;
    onUpdateStatus?: (detail: { id: number; status: CustomerStatus }) => void;
    onResendConfirmation?: (customerId: number) => void;
    onInactivateProfile?: (profileId: string) => void;
    onRestoreProfile?: (profileId: string) => void;
  } = $props();

  let customerToDelete = $state<Customer | null>(null);
  let profileToDelete = $state<ProfileCustomer | null>(null);
  let showDeleteConfirm = $state(false);

  function formatDate(dateString?: string | null): string {
    if (!dateString) {
      return '-';
    }
    try {
      return new Date(dateString).toLocaleDateString('pt-BR');
    } catch (error) {
      // Invalid date
      return '-';
    }
  }

  function handleEditClick(customer: Customer): void {
    onEdit(customer);
  }

  function handleEditProfileClick(profileCustomer: ProfileCustomer): void {
    onEditProfile(profileCustomer);
  }

  function handleViewProfileClick(customer: Customer): void {
    onViewProfile(customer);
  }

  function handleStatusChange(customerId: number, newStatus: CustomerStatus): void {
    onUpdateStatus({ id: customerId, status: newStatus });
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
      onDelete(customerToDelete.id);
      customerToDelete = null;
    } else if (profileToDelete) {
      onDeleteProfile(profileToDelete.id);
      profileToDelete = null;
    }
    showDeleteConfirm = false;
  }

  function handleResendConfirmation(customerId: number): void {
    onResendConfirmation(customerId);
  }

  function handleInactivateProfile(profileCustomer: ProfileCustomer): void {
    onInactivateProfile(profileCustomer.id);
  }

  function handleRestoreProfile(profileCustomer: ProfileCustomer): void {
    onRestoreProfile(profileCustomer.id);
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
  <!-- Mobile Card Layout (sm and below) -->
  <div class="block lg:hidden">
    <div class="space-y-4">
      {#each customers as customer (customer.id)}
        {@const profileCustomer = customer.profile_customer}
        {@const fullName = profileCustomer
          ? getProfileCustomerFullName(profileCustomer)
          : 'Nome não informado'}
        {@const cpfOrCnpj = profileCustomer
          ? getProfileCustomerCpfOrCpnj(profileCustomer)
          : 'Não possui'}
        {@const customerType = profileCustomer
          ? translateCustomerType(profileCustomer.attributes.customer_type)
          : 'Não definido'}
        {@const phone = profileCustomer?.attributes.default_phone
          ? phoneMask(profileCustomer.attributes.default_phone)
          : '-'}
        {@const isDeleted = customer.deleted || profileCustomer?.attributes.deleted || false}
        {@const isUnable = profileCustomer?.attributes?.capacity === 'unable'}
        {@const isRelativelyIncapable = profileCustomer?.attributes?.capacity === 'relatively'}
        {@const hasCapacityLimitation = isUnable || isRelativelyIncapable}

        <div
          class="card bg-gradient-to-r from-base-100 to-base-200/50 shadow-md border border-base-200 hover:shadow-lg transition-all duration-300 hover:-translate-y-1"
          class:shadow-warning={isRelativelyIncapable}
          class:shadow-error={isUnable}
          class:opacity-70={isDeleted}
        >
          <div class="card-body p-5">
            <!-- Header Row -->
            <div class="flex items-center justify-between mb-4">
              <div class="flex items-center gap-3">
                <!-- Avatar Circle -->
                <div class="avatar placeholder">
                  <div
                    class="bg-primary text-primary-content rounded-full w-12 h-12 text-lg font-bold flex items-center justify-center"
                    class:bg-warning={isRelativelyIncapable}
                    class:bg-error={isUnable}
                  >
                    {fullName.charAt(0).toUpperCase()}
                  </div>
                </div>

                <div class="flex-1">
                  <div class="flex items-center gap-2">
                    <h3 class="font-bold text-lg text-base-content leading-tight">{fullName}</h3>
                    {#if hasCapacityLimitation}
                      {#if isUnable}
                        <div
                          class="tooltip tooltip-error"
                          data-tip="Cliente Incapaz - Requer Representação Legal"
                        >
                          <span class="text-error text-lg">🚫</span>
                        </div>
                      {:else if isRelativelyIncapable}
                        <div
                          class="tooltip tooltip-warning"
                          data-tip="Relativamente Incapaz - Assistência Recomendada"
                        >
                          <span class="text-warning text-lg">⚠️</span>
                        </div>
                      {/if}
                    {/if}
                  </div>

                  <div class="flex items-center gap-2 mt-1">
                    <span class="badge badge-ghost badge-sm">{customerType}</span>
                    {#if isDeleted}
                      <span class="badge badge-error badge-sm">Inativo</span>
                    {/if}
                  </div>
                </div>
              </div>

              <!-- Actions Menu (Fixed Positioning) -->
              <div class="dropdown dropdown-end dropdown-top">
                <div
                  tabindex="0"
                  role="button"
                  class="btn btn-ghost btn-circle hover:bg-primary/10 transition-colors"
                >
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z"
                    />
                  </svg>
                </div>
                <ul
                  class="dropdown-content menu p-2 shadow-xl bg-base-100 rounded-xl w-48 z-50 border border-base-300"
                >
                  {#if !isDeleted}
                    <li>
                      <button
                        class="flex items-center gap-3 px-4 py-2 hover:bg-primary/5 rounded-lg transition-colors"
                        onclick={() => handleViewProfileClick(customer)}
                        disabled={isLoading}
                      >
                        <svg class="w-4 h-4 text-info" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
                          <path
                            fill-rule="evenodd"
                            d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z"
                            clip-rule="evenodd"
                          />
                        </svg>
                        <span>Ver Perfil</span>
                      </button>
                    </li>
                    <li>
                      <button
                        class="flex items-center gap-3 px-4 py-2 hover:bg-primary/5 rounded-lg transition-colors"
                        onclick={() => handleEditClick(customer)}
                        disabled={isLoading}
                      >
                        <svg class="w-4 h-4 text-primary" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z"
                          />
                        </svg>
                        <span>Editar</span>
                      </button>
                    </li>
                    <div class="divider my-1"></div>
                    <li>
                      <button
                        class="flex items-center gap-3 px-4 py-2 hover:bg-error/5 text-error rounded-lg transition-colors"
                        onclick={() => confirmDelete(customer)}
                        disabled={isLoading}
                      >
                        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                          <path
                            fill-rule="evenodd"
                            d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
                            clip-rule="evenodd"
                          />
                        </svg>
                        <span>Remover</span>
                      </button>
                    </li>
                  {:else}
                    <li>
                      <span class="text-base-content/60 px-4 py-2 text-center">Cliente inativo</span
                      >
                    </li>
                  {/if}
                </ul>
              </div>
            </div>

            <!-- Contact Info -->
            <div class="space-y-2">
              {#if customer.access_email}
                <div class="flex items-center gap-3 p-2 bg-base-200/50 rounded-lg">
                  <svg
                    class="w-4 h-4 text-primary flex-shrink-0"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"
                    />
                    <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
                  </svg>
                  <span class="flex-1 truncate text-sm">{customer.access_email}</span>
                  {#if customer.confirmed_at}
                    <div class="badge badge-success badge-xs">Confirmado</div>
                  {:else}
                    <div class="badge badge-warning badge-xs">Pendente</div>
                  {/if}
                </div>
              {/if}

              {#if phone !== '-'}
                <div class="flex items-center gap-3 p-2 bg-base-200/50 rounded-lg">
                  <svg
                    class="w-4 h-4 text-primary flex-shrink-0"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z"
                    />
                  </svg>
                  <span class="text-sm">{phone}</span>
                </div>
              {/if}

              {#if cpfOrCnpj !== 'Não possui'}
                <div class="flex items-center gap-3 p-2 bg-base-200/50 rounded-lg">
                  <svg
                    class="w-4 h-4 text-primary flex-shrink-0"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M10 2C5.58 2 2 5.58 2 10s3.58 8 8 8 8-3.58 8-8-3.58-8-8-8zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                      clip-rule="evenodd"
                    />
                  </svg>
                  <span class="font-mono text-sm">{cpfOrCnpj}</span>
                </div>
              {/if}
            </div>

            <!-- Footer -->
            <div class="flex items-center justify-between pt-3 mt-4 border-t border-base-200">
              <select
                class="select select-sm select-bordered bg-base-100 hover:bg-base-200 transition-colors"
                value={customer.status}
                onchange={(e) => handleStatusChange(customer.id, e.currentTarget.value)}
                disabled={isLoading}
              >
                <option value="active">Ativo</option>
                <option value="inactive">Inativo</option>
                <option value="deceased">Falecido</option>
              </select>

              <div class="text-xs text-base-content/60 bg-base-200/50 px-2 py-1 rounded">
                ID: #{customer.id}
              </div>
            </div>
          </div>
        </div>
      {/each}
    </div>
  </div>

  <!-- Desktop Table Layout (lg and above) -->
  <div class="hidden lg:block">
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
            {@const fullName = profileCustomer
              ? getProfileCustomerFullName(profileCustomer)
              : 'Nome não informado'}
            {@const cpfOrCnpj = profileCustomer
              ? getProfileCustomerCpfOrCpnj(profileCustomer)
              : 'Não possui'}
            {@const customerType = profileCustomer
              ? translateCustomerType(profileCustomer.attributes.customer_type)
              : 'Não definido'}
            {@const phone = profileCustomer?.attributes.default_phone
              ? phoneMask(profileCustomer.attributes.default_phone)
              : '-'}
            {@const isDeleted = customer.deleted || profileCustomer?.attributes.deleted || false}
            {@const isUnable = profileCustomer?.attributes?.capacity === 'unable'}
            {@const isRelativelyIncapable = profileCustomer?.attributes?.capacity === 'relatively'}
            {@const hasCapacityLimitation = isUnable || isRelativelyIncapable}

            <tr
              class:opacity-60={isDeleted}
              class:border-l-4={hasCapacityLimitation}
              class:border-warning={isRelativelyIncapable}
              class:border-error={isUnable}
            >
              <td>{customer.id}</td>
              <td class="font-medium">
                <div class="flex items-center gap-2">
                  <span>{fullName}</span>
                  {#if hasCapacityLimitation}
                    <div class="flex items-center gap-1">
                      {#if isUnable}
                        <span
                          class="text-error"
                          title="Cliente Incapaz - Requer Representação Legal">🚫</span
                        >
                      {:else if isRelativelyIncapable}
                        <span
                          class="text-warning"
                          title="Cliente Relativamente Incapaz - Assistência Recomendada">⚠️</span
                        >
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
                      onclick={() => {
                        if (window.navigator && window.navigator.clipboard) {
                          window.navigator.clipboard.writeText(cpfOrCnpj);
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
                  onchange={(e) =>
                    handleStatusChange(customer.id, e.currentTarget.value as CustomerStatus)}
                  disabled={isLoading}
                >
                  <option value="active">Ativo</option>
                  <option value="inactive">Inativo</option>
                  <option value="deceased">Falecido</option>
                </select>
              </td>
              <td>
                <div class="flex items-center gap-2">
                  <StatusBadge status={customer.confirmed_at ? 'confirmed' : 'unconfirmed'} />

                  {#if !customer.confirmed_at}
                    <button
                      class="btn btn-xs btn-outline"
                      onclick={() => handleResendConfirmation(customer.id)}
                      disabled={isLoading}
                    >
                      Reenviar
                    </button>
                  {/if}
                </div>
              </td>
              <td>
                <div class="dropdown dropdown-end dropdown-top">
                  <button
                    class="btn btn-sm btn-ghost hover:bg-primary/10 transition-colors"
                    tabindex="0"
                    aria-label="Menu de ações"
                  >
                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                      <path
                        d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z"
                      />
                    </svg>
                  </button>
                  <ul
                    class="dropdown-content z-50 menu p-3 shadow-xl bg-base-100 rounded-xl w-52 border border-base-300"
                  >
                    {#if !isDeleted}
                      <li>
                        <button
                          class="flex items-center gap-3 px-3 py-2 hover:bg-primary/5 rounded-lg transition-colors"
                          onclick={() => handleViewProfileClick(customer)}
                          disabled={isLoading}
                        >
                          <svg class="w-4 h-4 text-info" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
                            <path
                              fill-rule="evenodd"
                              d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z"
                              clip-rule="evenodd"
                            />
                          </svg>
                          <span>Ver Perfil</span>
                        </button>
                      </li>
                      <li>
                        <button
                          class="flex items-center gap-3 px-3 py-2 hover:bg-primary/5 rounded-lg transition-colors"
                          onclick={() => handleEditClick(customer)}
                          disabled={isLoading}
                        >
                          <svg class="w-4 h-4 text-primary" fill="currentColor" viewBox="0 0 20 20">
                            <path
                              d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z"
                            />
                          </svg>
                          <span>Editar</span>
                        </button>
                      </li>
                      {#if profileCustomer}
                        <li>
                          <button
                            class="flex items-center gap-3 px-3 py-2 hover:bg-warning/5 text-warning rounded-lg transition-colors"
                            onclick={() => handleInactivateProfile(profileCustomer)}
                            disabled={isLoading}
                          >
                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                              <path
                                fill-rule="evenodd"
                                d="M5 4a3 3 0 00-3 3v6a3 3 0 003 3h10a3 3 0 003-3V7a3 3 0 00-3-3H5zm-1 9v-1h5v2H5a1 1 0 01-1-1zm7 1h4a1 1 0 001-1v-1h-5v2zm0-4h5V8h-5v2zM9 8H4v2h5V8z"
                                clip-rule="evenodd"
                              />
                            </svg>
                            <span>Inativar Perfil</span>
                          </button>
                        </li>
                      {/if}
                      <div class="divider my-1"></div>
                      <li>
                        <button
                          class="flex items-center gap-3 px-3 py-2 hover:bg-error/5 text-error rounded-lg transition-colors"
                          onclick={() => confirmDelete(customer)}
                          disabled={isLoading}
                        >
                          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                            <path
                              fill-rule="evenodd"
                              d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
                              clip-rule="evenodd"
                            />
                          </svg>
                          <span>Remover</span>
                        </button>
                      </li>
                    {:else}
                      {#if profileCustomer}
                        <li>
                          <button
                            class="flex items-center gap-3 px-3 py-2 hover:bg-success/5 text-success rounded-lg transition-colors"
                            onclick={() => handleRestoreProfile(profileCustomer)}
                            disabled={isLoading}
                          >
                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                              <path
                                fill-rule="evenodd"
                                d="M15.707 4.293a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-5-5a1 1 0 011.414-1.414L10 8.586l4.293-4.293a1 1 0 011.414 0zm0 6a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-5-5a1 1 0 111.414-1.414L10 14.586l4.293-4.293a1 1 0 011.414 0z"
                                clip-rule="evenodd"
                              />
                            </svg>
                            <span>Ativar Perfil</span>
                          </button>
                        </li>
                      {/if}
                      <div class="divider my-1"></div>
                      <li>
                        <button
                          class="flex items-center gap-3 px-3 py-2 hover:bg-error/5 text-error rounded-lg transition-colors"
                          onclick={() => confirmDelete(customer)}
                          disabled={isLoading}
                        >
                          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                            <path
                              fill-rule="evenodd"
                              d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
                              clip-rule="evenodd"
                            />
                          </svg>
                          <span>Remover</span>
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
  </div>
{/if}

<ConfirmDialog
  bind:show={showDeleteConfirm}
  title="Excluir Cliente"
  message={customerToDelete
    ? `Tem certeza que deseja excluir o cliente ${customerToDelete.profile_customer ? getProfileCustomerFullName(customerToDelete.profile_customer) : customerToDelete.email || 'ID ' + customerToDelete.id}? Esta ação não pode ser desfeita.`
    : profileToDelete
      ? `Tem certeza que deseja excluir o cliente ${getProfileCustomerFullName(profileToDelete) || 'ID ' + profileToDelete.id}? Esta ação não pode ser desfeita.`
      : ''}
  confirmText="Excluir"
  cancelText="Cancelar"
  type="danger"
  onConfirm={handleDeleteConfirm}
/>
