<!-- components/customers/CustomerProfileView.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Customer, ProfileCustomer } from '../../api/types/customer.types';
  import {
    getProfileCustomerFullName,
    getProfileCustomerCpfOrCpnj,
    translateCustomerType,
    phoneMask
  } from '../../utils/profileCustomerUtils';

  export let customer: Customer;
  export let isLoading: boolean = false;

  const dispatch = createEventDispatcher<{
    edit: Customer;
    close: void;
  }>();

  $: profileCustomer = customer.profile_customer;
  $: isUnable = profileCustomer?.attributes?.capacity === 'unable';
  $: isRelativelyIncapable = profileCustomer?.attributes?.capacity === 'relatively';
  $: hasCapacityLimitation = isUnable || isRelativelyIncapable;

  function formatDate(dateString?: string): string {
    if (!dateString) {
      return 'Não informado';
    }
    try {
      return new Date(dateString).toLocaleDateString('pt-BR');
    } catch {
      return 'Data inválida';
    }
  }

  function getCapacityDisplay(capacity?: string): { text: string; color: string; icon: string } {
    switch (capacity) {
      case 'unable':
        return {
          text: 'Incapaz',
          color: 'badge-error',
          icon: '🚫'
        };
      case 'relatively':
        return {
          text: 'Relativamente Incapaz',
          color: 'badge-warning',
          icon: '⚠️'
        };
      case 'able':
      default:
        return {
          text: 'Capaz',
          color: 'badge-success',
          icon: '✅'
        };
    }
  }

  function getStatusDisplay(status?: string): { text: string; color: string } {
    switch (status) {
      case 'active':
        return { text: 'Ativo', color: 'badge-success' };
      case 'inactive':
        return { text: 'Inativo', color: 'badge-warning' };
      case 'deceased':
        return { text: 'Falecido', color: 'badge-error' };
      default:
        return { text: status || 'Desconhecido', color: 'badge-neutral' };
    }
  }

  function handleEdit() {
    dispatch('edit', customer);
  }

  function handleClose() {
    dispatch('close');
  }
</script>

<div class="modal modal-open">
  <div class="modal-box w-full max-w-5xl max-h-[90vh] overflow-y-auto">
    <!-- Header -->
    <div class="flex justify-between items-start mb-6">
      <div class="flex items-center gap-3">
        <h3 class="font-bold text-xl">
          {profileCustomer ? getProfileCustomerFullName(profileCustomer) : 'Cliente'}
        </h3>
        {#if hasCapacityLimitation}
          {@const capacityInfo = getCapacityDisplay(profileCustomer?.attributes?.capacity)}
          <div class="badge {capacityInfo.color} gap-2">
            <span class="text-lg">{capacityInfo.icon}</span>
            {capacityInfo.text}
          </div>
        {/if}
      </div>
      <div class="flex gap-2">
        <button class="btn btn-primary btn-sm" on:click={handleEdit} disabled={isLoading}>
          ✏️ Editar
        </button>
        <button class="btn btn-ghost btn-sm btn-circle" on:click={handleClose}> ✕ </button>
      </div>
    </div>

    {#if isLoading}
      <div class="flex justify-center py-8">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
    {:else if !profileCustomer}
      <div class="text-center py-8">
        <p class="text-lg text-warning">⚠️ Perfil do cliente não encontrado</p>
        <p class="text-sm opacity-70">Este cliente não possui um perfil associado</p>
      </div>
    {:else}
      <!-- Main Content Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Personal Information Card -->
        <div class="card bg-base-200 shadow-sm">
          <div class="card-body">
            <h4 class="card-title text-lg flex items-center gap-2">
              👤 Informações Pessoais
              {#if customer.status}
                {@const statusInfo = getStatusDisplay(customer.status)}
                <div class="badge {statusInfo.color} badge-sm">
                  {statusInfo.text}
                </div>
              {/if}
            </h4>

            <div class="space-y-3">
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="text-sm font-semibold opacity-70">Nome Completo</label>
                  <p class="text-base">{getProfileCustomerFullName(profileCustomer)}</p>
                </div>

                <div>
                  <label class="text-sm font-semibold opacity-70">Tipo</label>
                  <div class="flex items-center gap-2">
                    <span class="badge badge-outline">
                      {translateCustomerType(profileCustomer.attributes.customer_type)}
                    </span>
                  </div>
                </div>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="text-sm font-semibold opacity-70">CPF/CNPJ</label>
                  <div class="flex items-center gap-2">
                    <span class="font-mono">{getProfileCustomerCpfOrCpnj(profileCustomer)}</span>
                    {#if getProfileCustomerCpfOrCpnj(profileCustomer) !== 'Não possui'}
                      <button
                        class="btn btn-xs btn-ghost"
                        on:click={() => {
                          if (navigator?.clipboard) {
                            navigator.clipboard.writeText(
                              getProfileCustomerCpfOrCpnj(profileCustomer)
                            );
                          }
                        }}
                        title="Copiar"
                      >
                        📋
                      </button>
                    {/if}
                  </div>
                </div>

                <div>
                  <label class="text-sm font-semibold opacity-70">RG</label>
                  <p class="font-mono">{profileCustomer.attributes.rg || 'Não informado'}</p>
                </div>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="text-sm font-semibold opacity-70">Data de Nascimento</label>
                  <p>{formatDate(profileCustomer.attributes.birth)}</p>
                </div>

                <div>
                  <label class="text-sm font-semibold opacity-70">Gênero</label>
                  <p class="capitalize">{profileCustomer.attributes.gender || 'Não informado'}</p>
                </div>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="text-sm font-semibold opacity-70">Estado Civil</label>
                  <p class="capitalize">
                    {profileCustomer.attributes.civil_status || 'Não informado'}
                  </p>
                </div>

                <div>
                  <label class="text-sm font-semibold opacity-70">Nacionalidade</label>
                  <p class="capitalize">{profileCustomer.attributes.nationality || 'Brasileiro'}</p>
                </div>
              </div>

              <div>
                <label class="text-sm font-semibold opacity-70">Nome da Mãe</label>
                <p>{profileCustomer.attributes.mother_name || 'Não informado'}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Contact Information Card -->
        <div class="card bg-base-200 shadow-sm">
          <div class="card-body">
            <h4 class="card-title text-lg">📞 Contatos</h4>

            <div class="space-y-3">
              <div>
                <label class="text-sm font-semibold opacity-70">Email de Acesso</label>
                <p class="font-mono">{customer.access_email || 'Não informado'}</p>
                {#if customer.confirmed_at}
                  <div class="badge badge-success badge-xs">✓ Confirmado</div>
                {:else}
                  <div class="badge badge-warning badge-xs">⚠️ Não confirmado</div>
                {/if}
              </div>

              <div>
                <label class="text-sm font-semibold opacity-70">Telefone Principal</label>
                <p>
                  {profileCustomer.attributes.default_phone
                    ? phoneMask(profileCustomer.attributes.default_phone)
                    : 'Não informado'}
                </p>
              </div>

              <!-- Additional phones if available -->
              {#if profileCustomer.relationships?.phones && profileCustomer.relationships.phones.length > 0}
                <div>
                  <label class="text-sm font-semibold opacity-70">Outros Telefones</label>
                  <div class="space-y-1">
                    {#each profileCustomer.relationships.phones as phone}
                      <p class="text-sm">{phoneMask(phone.phone_number)}</p>
                    {/each}
                  </div>
                </div>
              {/if}

              <!-- Additional emails if available -->
              {#if profileCustomer.relationships?.emails && profileCustomer.relationships.emails.length > 0}
                <div>
                  <label class="text-sm font-semibold opacity-70">Outros Emails</label>
                  <div class="space-y-1">
                    {#each profileCustomer.relationships.emails as email}
                      <p class="text-sm font-mono">{email.email}</p>
                    {/each}
                  </div>
                </div>
              {/if}
            </div>
          </div>
        </div>

        <!-- Professional Information Card -->
        <div class="card bg-base-200 shadow-sm">
          <div class="card-body">
            <h4 class="card-title text-lg">💼 Informações Profissionais</h4>

            <div class="space-y-3">
              <div>
                <label class="text-sm font-semibold opacity-70">Profissão</label>
                <p>
                  {profileCustomer.attributes.profession ||
                    (isUnable ? 'N/A - Cliente incapaz' : 'Não informado')}
                </p>
              </div>

              <div>
                <label class="text-sm font-semibold opacity-70">Empresa</label>
                <p>{profileCustomer.attributes.company || 'Não informado'}</p>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="text-sm font-semibold opacity-70">Benefício INSS</label>
                  <p class="font-mono">
                    {profileCustomer.attributes.number_benefit || 'Não informado'}
                  </p>
                </div>

                <div>
                  <label class="text-sm font-semibold opacity-70">NIT</label>
                  <p class="font-mono">{profileCustomer.attributes.nit || 'Não informado'}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Address Information Card -->
        {#if profileCustomer.relationships?.addresses && profileCustomer.relationships.addresses.length > 0}
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body">
              <h4 class="card-title text-lg">📍 Endereços</h4>

              <div class="space-y-4">
                {#each profileCustomer.relationships.addresses as address, index}
                  <div class="border-l-4 border-primary pl-4">
                    {#if address.description}
                      <h5 class="font-semibold text-sm">{address.description}</h5>
                    {:else}
                      <h5 class="font-semibold text-sm">Endereço {index + 1}</h5>
                    {/if}

                    <div class="text-sm space-y-1">
                      <p>{address.street}, {address.number}</p>
                      <p>{address.neighborhood}</p>
                      <p>{address.city} - {address.state}</p>
                      <p class="font-mono">CEP: {address.zip_code}</p>
                    </div>
                  </div>
                {/each}
              </div>
            </div>
          </div>
        {/if}

        <!-- Banking Information Card -->
        {#if profileCustomer.relationships?.bank_accounts && profileCustomer.relationships.bank_accounts.length > 0}
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body">
              <h4 class="card-title text-lg">🏦 Informações Bancárias</h4>

              <div class="space-y-4">
                {#each profileCustomer.relationships.bank_accounts as bank, index}
                  <div class="border-l-4 border-secondary pl-4">
                    <h5 class="font-semibold text-sm">{bank.bank_name || `Conta ${index + 1}`}</h5>

                    <div class="text-sm space-y-1">
                      <p>
                        <span class="font-semibold">Tipo:</span>
                        {bank.type_account || 'Não informado'}
                      </p>
                      <p>
                        <span class="font-semibold">Agência:</span>
                        <span class="font-mono">{bank.agency || 'Não informado'}</span>
                      </p>
                      <p>
                        <span class="font-semibold">Conta:</span>
                        <span class="font-mono">{bank.account || 'Não informado'}</span>
                      </p>
                      {#if bank.operation}
                        <p>
                          <span class="font-semibold">Operação:</span>
                          <span class="font-mono">{bank.operation}</span>
                        </p>
                      {/if}
                      {#if bank.pix}
                        <p>
                          <span class="font-semibold">PIX:</span>
                          <span class="font-mono">{bank.pix}</span>
                        </p>
                      {/if}
                    </div>
                  </div>
                {/each}
              </div>
            </div>
          </div>
        {/if}
      </div>

      <!-- Guardian/Representative Information -->
      {#if hasCapacityLimitation}
        <div class="mt-6">
          <div class="alert alert-info">
            <span class="text-lg">
              {#if isUnable}
                🛡️
              {:else}
                ⚠️
              {/if}
            </span>
            <div>
              <h4 class="font-bold">
                {#if isUnable}
                  Cliente Incapaz - Requer Representação Legal
                {:else}
                  Cliente Relativamente Incapaz - Assistência Recomendada
                {/if}
              </h4>
              <p class="text-sm">
                {#if isUnable}
                  Este cliente é juridicamente incapaz e deve ser representado por um responsável
                  legal em todos os atos jurídicos.
                {:else}
                  Este cliente possui capacidade civil limitada e pode necessitar de assistência em
                  determinados atos jurídicos.
                {/if}
              </p>

              <!-- TODO: Display Guardian/Representative information when available -->
              {#if profileCustomer.attributes.represent}
                <div class="mt-3 p-3 bg-base-100 rounded-lg">
                  <h5 class="font-semibold text-sm mb-2">📋 Responsável Legal:</h5>
                  <p class="text-sm">
                    <strong>Nome:</strong>
                    {profileCustomer.attributes.represent.name || 'Não informado'}
                  </p>
                  <p class="text-sm">
                    <strong>Relacionamento:</strong>
                    {profileCustomer.attributes.represent.relationship_type || 'Não informado'}
                  </p>
                </div>
              {:else}
                <div class="mt-3 p-3 bg-warning/10 rounded-lg">
                  <p class="text-sm text-warning-content">
                    ⚠️ Nenhum responsável legal cadastrado. É necessário associar um responsável a
                    este cliente.
                  </p>
                </div>
              {/if}
            </div>
          </div>
        </div>
      {/if}

      <!-- System Information -->
      <div class="mt-6">
        <div class="card bg-base-300 shadow-sm">
          <div class="card-body">
            <h4 class="card-title text-lg">🔧 Informações do Sistema</h4>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div>
                <label class="text-sm font-semibold opacity-70">ID do Cliente</label>
                <p class="font-mono">#{customer.id}</p>
              </div>

              <div>
                <label class="text-sm font-semibold opacity-70">Criado em</label>
                <p>{formatDate(customer.created_at)}</p>
              </div>

              <div>
                <label class="text-sm font-semibold opacity-70">Status</label>
                {#if customer.status}
                  {@const statusInfo = getStatusDisplay(customer.status)}
                  <div class="badge {statusInfo.color} badge-sm">
                    {statusInfo.text}
                  </div>
                {/if}
              </div>
            </div>

            {#if customer.created_by_id}
              <div class="mt-3">
                <label class="text-sm font-semibold opacity-70">Criado por usuário</label>
                <p class="font-mono">#{customer.created_by_id}</p>
              </div>
            {/if}
          </div>
        </div>
      </div>
    {/if}
  </div>

  <!-- Modal backdrop -->
  <form method="dialog" class="modal-backdrop">
    <button on:click={handleClose}>close</button>
  </form>
</div>
