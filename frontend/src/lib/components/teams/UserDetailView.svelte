<!-- frontend/src/lib/components/teams/UserDetailView.svelte -->
<script lang="ts">
  // createEventDispatcher não é mais necessário em Runes mode.
  // import { createEventDispatcher } from 'svelte';

  // A interface permanece a mesma.
  interface User {
    id: number;
    type: string;
    attributes: {
      name?: string;
      last_name?: string;
      email?: string;
      access_email?: string;
      role?: string;
      oab?: string;
      status?: string;
      profile?: {
        id?: number;
        full_name?: string;
        avatar_url?: string;
        cpf?: string;
        rg?: string;
        birth?: string;
        nationality?: string;
        civil_status?: string;
        gender?: 'male' | 'female';
        mother_name?: string;
      };
      phones?: { phone_number?: string; phone_type?: string }[];
      addresses?: {
        street?: string;
        number?: string;
        complement?: string;
        neighborhood?: string;
        city?: string;
        state?: string;
        zip_code?: string;
        address_type?: string;
      }[];
      bank_accounts?: { bank_name?: string; agency?: string; account_number?: string }[];
    };
  }

  // 1. MUDANÇA PRINCIPAL: Usando $props() para declarar as propriedades
  // O componente agora espera uma prop 'user' e uma prop 'onEdit' que é uma função.
  let { user, onEdit } = $props<{
    user: User;
    onEdit: (user: User) => void;
  }>();

  // const dispatch = createEventDispatcher(); // Removido

  // A função handleEdit foi removida porque o evento é tratado diretamente no botão.
  // function handleEdit() { ... }

  // Função para obter rótulos mais amigáveis para cargos
  function getRoleLabel(role: string | undefined): string {
    if (!role) {
return 'Não informado';
}
    const map: Record<string, string> = {
      lawyer: 'Advogado',
      paralegal: 'Paralegal',
      trainee: 'Estagiário',
      secretary: 'Secretário',
      counter: 'Contador'
    };
    return map[role] || role;
  }

  // Dados derivados para facilitar o acesso no template (a sintaxe $derived permanece a mesma)
  let fullName = $derived(user.attributes.profile?.full_name || `${user.attributes.name || ''} ${user.attributes.last_name || ''}`.trim());
  let userProfile = $derived(user.attributes.profile);
  let userPhones = $derived(user.attributes.phones || []);
  let userAddresses = $derived(user.attributes.addresses || []);
  let userBankAccounts = $derived(user.attributes.bank_accounts || []);
</script>

<div class="container mx-auto space-y-6">
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      {#if user}
        <div class="space-y-6">
          <!-- Cabeçalho do Perfil com Avatar -->
          <div class="flex items-center gap-6 p-6 bg-base-200 rounded-lg">
            <div class="avatar">
              <div class="w-24 rounded-full ring ring-primary ring-offset-base-100 ring-offset-2">
                {#if userProfile?.avatar_url}
                  <img src={userProfile.avatar_url} alt={fullName} />
                {:else}
                  <div class="bg-neutral text-neutral-content rounded-full w-24 h-24 flex items-center justify-center">
                    <span class="text-4xl">{fullName.charAt(0) || '?'}</span>
                  </div>
                {/if}
              </div>
            </div>

            <div class="flex-1">
              <h2 class="text-2xl font-bold">{fullName}</h2>
              <p class="text-lg opacity-70">{getRoleLabel(user.attributes.role)}</p>
              {#if user.attributes.role === 'lawyer'}
                <p class="text-sm opacity-60">OAB: {user.attributes.oab || 'Não informada'}</p>
              {/if}
              <p class="text-sm opacity-60">Email: {user.attributes.access_email}</p>
              <div class="mt-3">
                <!-- 2. MUDANÇA NO EVENTO: Chamando a função 'onEdit' passada como prop -->
                <button class="btn btn-primary btn-sm" onclick={() => onEdit(user)}>
                  Editar Usuário
                </button>
              </div>
            </div>
          </div>

          <!-- O resto do template permanece o mesmo... -->

          <!-- Informações Pessoais -->
          <div class="card bg-base-100 shadow">
            <div class="card-body">
              <h4 class="card-title">Informações da Conta</h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="label" for="email">
                    <span class="label-text font-semibold">Email de Acesso</span>
                  </label>
                  <input id="email" type="text" value={user.attributes.access_email || 'Não informado'} class="input input-bordered w-full" readonly />
                </div>

                <div>
                    <label class="label" for="role">
                      <span class="label-text font-semibold">Cargo</span>
                    </label>
                    <input id="role" type="text" value={getRoleLabel(user.attributes.role)} class="input input-bordered w-full" readonly />
                </div>

                {#if user.attributes.role === 'lawyer'}
                  <div>
                    <label class="label" for="oab">
                      <span class="label-text font-semibold">OAB</span>
                    </label>
                    <input id="oab" type="text" value={user.attributes.oab || 'Não informado'} class="input input-bordered w-full" readonly />
                  </div>
                {/if}

                <div>
                  <div class="label">
                    <span class="label-text font-semibold">Status</span>
                  </div>
                  <div class="badge {user.attributes.status === 'active' ? 'badge-success' : 'badge-warning'}">
                    {user.attributes.status === 'active' ? 'Ativo' : 'Inativo'}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Informações de Contato e Endereço -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Telefones -->
            {#if userPhones.length > 0}
              <div class="card bg-base-100 shadow">
                <div class="card-body">
                  <h4 class="card-title">Telefones</h4>
                  <div class="space-y-2">
                    {#each userPhones as phone}
                      <div class="p-2 bg-base-200 rounded">
                        <p class="font-medium">{phone.phone_number}</p>
                        {#if phone.phone_type}
                          <p class="text-xs opacity-70 capitalize">{phone.phone_type}</p>
                        {/if}
                      </div>
                    {/each}
                  </div>
                </div>
              </div>
            {:else}
              <div class="card bg-base-100 shadow">
                <div class="card-body">
                  <h4 class="card-title">Telefones</h4>
                  <p class="text-sm opacity-70">Nenhum telefone cadastrado.</p>
                </div>
              </div>
            {/if}

            <!-- Endereços -->
            {#if userAddresses.length > 0}
              <div class="card bg-base-100 shadow">
                <div class="card-body">
                  <h4 class="card-title">Endereços</h4>
                  <div class="space-y-3">
                    {#each userAddresses as address}
                      <div class="p-3 bg-base-200 rounded-lg">
                        <p class="font-medium">{address.street || 'Rua não informada'}, {address.number || 'S/N'}</p>
                        {#if address.complement}
                          <p class="text-sm">{address.complement}</p>
                        {/if}
                        <p class="text-sm">{address.neighborhood || 'Bairro não informado'}</p>
                        <p class="text-sm">{address.city || 'Cidade'} - {address.state || 'UF'}</p>
                        <p class="text-sm">CEP: {address.zip_code || 'Não informado'}</p>
                        {#if address.address_type}
                          <div class="badge badge-outline text-xs mt-1 capitalize">{address.address_type}</div>
                        {/if}
                      </div>
                    {/each}
                  </div>
                </div>
              </div>
            {:else}
               <div class="card bg-base-100 shadow">
                <div class="card-body">
                  <h4 class="card-title">Endereços</h4>
                  <p class="text-sm opacity-70">Nenhum endereço cadastrado.</p>
                </div>
              </div>
            {/if}
          </div>

          <!-- Dados Bancários -->
          <div class="card bg-base-100 shadow">
            <div class="card-body">
              <h4 class="card-title">Dados Bancários</h4>
              {#if userBankAccounts.length > 0}
                <div class="space-y-3">
                  {#each userBankAccounts as account}
                    <div class="p-3 bg-base-200 rounded-lg">
                      <p><strong>Banco:</strong> {account.bank_name || 'Não informado'}</p>
                      <p><strong>Agência:</strong> {account.agency || 'Não informada'}</p>
                      <p><strong>Conta:</strong> {account.account_number || 'Não informada'}</p>
                    </div>
                  {/each}
                </div>
              {:else}
                <p class="text-sm opacity-70">Nenhum dado bancário cadastrado.</p>
              {/if}
            </div>
          </div>

        </div>
      {:else}
        <div class="alert alert-warning">
          <span>Nenhum dado de usuário encontrado para exibição.</span>
        </div>
      {/if}
    </div>
  </div>
</div>