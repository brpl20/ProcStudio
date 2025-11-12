<!-- frontend/src/lib/components/teams/UserDetailView.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  
  // Definindo a interface do usuário para tipagem
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
      user_profile_id?: number;
      phones?: { number?: string; kind?: string }[];
      addresses?: { street?: string; number?: string; city?: string; state?: string; zip_code?: string }[];
      bank_accounts?: { bank_name?: string; agency?: string; account_number?: string }[];
    };
  }

  // Propriedade para receber os dados do usuário
  export let user: User;

  const dispatch = createEventDispatcher();

  function handleEdit() {
    // Dispara um evento 'edit' com os dados do usuário atual
    dispatch('edit', user);
  }

  // Funções para obter rótulos mais amigáveis
  function getRoleLabel(role: string | undefined): string {
    if (!role) return 'Não informado';
    const map: Record<string, string> = { lawyer: 'Advogado', paralegal: 'Paralegal', trainee: 'Estagiário', secretary: 'Secretário', counter: 'Contador' };
    return map[role] || role;
  }
</script>

<div class="container mx-auto">
  <div class="card bg-base-100 shadow-xl w-full">
    <div class="card-body">
      <!-- Cabeçalho com Avatar, Nome e Botão Editar -->
      <div class="flex flex-wrap items-center gap-4">
        <div class="avatar placeholder">
          <div class="bg-primary text-primary-content rounded-full w-16">
            <span class="text-xl">{user.attributes.name?.charAt(0) || '?'}</span>
          </div>
        </div>
        <div>
          <h2 class="card-title text-2xl">{user.attributes.name || 'Nome não informado'} {user.attributes.last_name || ''}</h2>
          <p class="text-sm opacity-70">{getRoleLabel(user.attributes.role)}</p>
        </div>
        <button class="btn btn-primary ml-auto" onclick={handleEdit}>Editar</button>
      </div>

      <div class="divider"></div>

      <!-- Seções de Informações -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
        
        <!-- Dados Pessoais -->
        <div>
          <h3 class="font-bold mb-3 border-l-4 border-primary pl-2">Dados Pessoais</h3>
          <p><strong>Email de Acesso:</strong> {user.attributes.access_email || 'Não informado'}</p>
          <p><strong>Status:</strong> <span class="badge {user.attributes.status === 'active' ? 'badge-success' : 'badge-warning'}">{user.attributes.status === 'active' ? 'Ativo' : 'Inativo'}</span></p>
          {#if user.attributes.role === 'lawyer'}
            <p><strong>OAB:</strong> {user.attributes.oab || 'Não informado'}</p>
          {/if}
        </div>

        <!-- Contato -->
        <div>
          <h3 class="font-bold mb-3 border-l-4 border-secondary pl-2">Contato</h3>
          {#if user.attributes.phones && user.attributes.phones.length > 0}
            {#each user.attributes.phones as phone}
              <p><strong>{phone.kind === 'mobile' ? 'Celular' : 'Telefone'}:</strong> {phone.number || 'Não informado'}</p>
            {/each}
          {:else}
            <p class="text-sm opacity-70">Nenhum telefone cadastrado.</p>
          {/if}
        </div>

        <!-- Endereço -->
        <div>
          <h3 class="font-bold mb-3 border-l-4 border-accent pl-2">Endereço</h3>
          {#if user.attributes.addresses && user.attributes.addresses.length > 0}
            {#each user.attributes.addresses as address}
              <p>{address.street || 'Rua não informada'}, {address.number || 'S/N'}</p>
              <p>{address.city || 'Cidade'} - {address.state || 'UF'}, CEP: {address.zip_code || 'Não informado'}</p>
            {/each}
          {:else}
            <p class="text-sm opacity-70">Nenhum endereço cadastrado.</p>
          {/if}
        </div>

        <!-- Dados Bancários -->
        <div>
          <h3 class="font-bold mb-3 border-l-4 border-info pl-2">Dados Bancários</h3>
          {#if user.attributes.bank_accounts && user.attributes.bank_accounts.length > 0}
            {#each user.attributes.bank_accounts as account}
              <div class="mb-2">
                <p><strong>Banco:</strong> {account.bank_name || 'Não informado'}</p>
                <p><strong>Agência:</strong> {account.agency || 'Não informada'} | <strong>Conta:</strong> {account.account_number || 'Não informada'}</p>
              </div>
            {/each}
          {:else}
            <p class="text-sm opacity-70">Nenhum dado bancário cadastrado.</p>
          {/if}
        </div>

      </div>

       <!-- Histórico (Se aplicável) -->
       <div class="mt-6">
          <h3 class="font-bold mb-3 border-l-4 border-warning pl-2">Histórico de Ações</h3>
          <p class="text-sm opacity-70">Funcionalidade de histórico ainda não implementada.</p>
          <!-- Aqui você poderá iterar sobre um array de logs de ações no futuro -->
       </div>

    </div>
  </div>
</div>