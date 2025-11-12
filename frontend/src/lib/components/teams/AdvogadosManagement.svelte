<script lang="ts">
  import { onMount } from 'svelte';
  import api from '../../api';
  import ConfirmDialog from '../ui/ConfirmDialog.svelte';
  import { userFormStore } from '../../stores/userFormStore.svelte.ts';
  import UserFormUnified from './UserFormUnified.svelte';

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
      phones?: any[];
      addresses?: any[];
      bank_accounts?: any[];
    };
  }

  let users: User[] = $state([]);
  let loading = $state(false);
  let error: string | null = $state(null);
  let success: string | null = $state(null);

  let showDeleteDialog = $state(false);
  let deletingUser: User | null = $state(null);

  async function loadUsers() {
    loading = true;
    error = null;
    try {
      const response = await api.users.getUserProfiles();
      users = response.data || [];
    } catch (err: any) {
      error = err.message || 'Erro ao carregar usuários';
    } finally {
      loading = false;
    }
  }

  function openCreateForm() {
    userFormStore.startCreate();
  }

  function openInviteForm() {
    userFormStore.startInvite();
  }

  function openEditForm(user: User) {
    userFormStore.startEdit(user);
  }

  function openDeleteDialog(user: User) {
    deletingUser = user;
    showDeleteDialog = true;
  }

  function closeDeleteDialog() {
    deletingUser = null;
    showDeleteDialog = false;
  }

  async function handleDeleteConfirm() {
    if (!deletingUser) return;
    try {
      const response = await api.users.deleteUser(String(deletingUser.id));
      if (response.success) {
        success = 'Usuário removido com sucesso!';
        loadUsers();
        setTimeout(() => { success = null; }, 3000);
      } else {
        error = response.message || 'Erro ao remover usuário';
      }
    } catch (err: any) {
      error = err.message || 'Erro ao remover usuário';
    } finally {
      closeDeleteDialog();
    }
  }

  async function handleSaveSuccess() {
    if (userFormStore.mode === 'invite') {
      success = 'Convite enviado com sucesso!';
    } else {
      success = userFormStore.mode === 'create' ? 'Usuário criado com sucesso!' : 'Usuário atualizado com sucesso!';
    }
    await loadUsers();
    userFormStore.reset();
    setTimeout(() => {
      success = null;
    }, 1500);
  }

  $effect(() => {
    if (userFormStore.success) {
      handleSaveSuccess();
    }
  });

  function getRoleBadgeClass(role: string): string {
    const map: Record<string, string> = { 
      lawyer: 'bg-blue-100 text-blue-900', 
      paralegal: 'bg-indigo-100 text-indigo-900', 
      trainee: 'bg-cyan-100 text-cyan-900', 
      secretary: 'bg-sky-100 text-sky-900' 
    };
    return map[role] || 'bg-gray-100 text-gray-900';
  }

  function getRoleLabel(role: string): string {
    const map: Record<string, string> = { 
      lawyer: 'Advogado', 
      paralegal: 'Paralegal', 
      trainee: 'Estagiário', 
      secretary: 'Secretário', 
      counter: 'Contador', 
      excounter: 'Ex-contador', 
      representant: 'Representante' 
    };
    return map[role] || role;
  }

  onMount(() => {
    loadUsers();
  });
</script>

<div class="w-full px-4 sm:px-6 lg:px-8 py-8 space-y-6">
  <!-- Header Section -->
  <div class="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-6">
    <div>
      <h2 class="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-[#01013D] to-[#01013D] bg-clip-text text-transparent mb-2">
        Gerenciar Usuários
      </h2>
      <p class="text-gray-600 text-sm">Crie, edite e gerencie usuários do sistema</p>
    </div>
    
    <!-- Button Group -->
    <div class="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
      <button 
        class="px-5 py-2.5 rounded-xl font-semibold bg-gray-100 text-[#01013D] hover:bg-gray-200 transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
        on:click={openInviteForm} 
        disabled={loading}
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        Convidar
      </button>
      <button 
        class="px-5 py-2.5 rounded-xl font-semibold bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white hover:shadow-lg hover:shadow-[#0277EE]/30 transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
        on:click={openCreateForm} 
        disabled={loading}
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
        </svg>
        Novo Usuário
      </button>
    </div>
  </div>

  <!-- Success Alert -->
  {#if success}
    <div class="bg-green-50 border-l-4 border-green-500 rounded-lg p-4 flex items-start gap-3 animate-in fade-in slide-in-from-top-2 duration-300">
      <svg class="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
      </svg>
      <div>
        <p class="text-green-900 font-semibold text-sm">{success}</p>
      </div>
    </div>
  {/if}

  <!-- Error Alert -->
  {#if error}
    <div class="bg-red-50 border-l-4 border-red-500 rounded-lg p-4 flex items-start gap-3 animate-in fade-in slide-in-from-top-2 duration-300">
      <svg class="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
      </svg>
      <div>
        <p class="text-red-900 font-semibold text-sm">Erro ao atualizar</p>
        <p class="text-red-800 text-sm mt-1">{error}</p>
      </div>
    </div>
  {/if}

  <!-- Content Card -->
  <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] overflow-hidden">
    {#if loading}
      <div class="p-12 text-center">
        <div class="inline-flex items-center justify-center">
          <div class="w-12 h-12 border-4 border-[#eef0ef] border-t-[#0277EE] rounded-full animate-spin"></div>
        </div>
        <p class="mt-4 text-gray-600 font-medium">Carregando usuários...</p>
      </div>
    {:else if users.length === 0}
      <div class="p-12 text-center">
        <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 mb-4">
          <svg class="w-8 h-8 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
          </svg>
        </div>
        <p class="text-[#01013D] font-bold text-lg">Nenhum usuário encontrado</p>
        <p class="text-gray-500 text-sm mt-1">Crie um novo usuário para começar</p>
      </div>
    {:else}
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gradient-to-r from-[#01013D]/5 to-[#0277EE]/5 border-b border-[#eef0ef]">
            <tr>
              <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">Nome</th>
              <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">Email</th>
              <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">Função</th>
              <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">Status</th>
              <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">OAB</th>
              <th class="px-6 py-4 text-center text-sm font-bold text-[#01013D]">Ações</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#eef0ef]">
            {#each users as user}
              <tr class="hover:bg-gradient-to-r hover:from-[#eef0ef]/30 hover:to-[#0277EE]/5 transition-colors duration-200">
                <td class="px-6 py-4">
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-full bg-gradient-to-br from-[#01013D] to-[#0277EE] flex items-center justify-center flex-shrink-0">
                      <span class="text-white font-bold text-sm">{user.attributes?.name?.charAt(0) || '?'}</span>
                    </div>
                    <div>
                      <p class="font-semibold text-[#01013D]">{user.attributes?.name || 'Nome não informado'} {user.attributes?.last_name || ''}</p>
                      <p class="text-xs text-gray-500">ID: #{user.id}</p>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <p class="text-sm text-gray-700">{user.attributes?.access_email || 'Email não informado'}</p>
                </td>
                <td class="px-6 py-4">
                  <span class="px-3 py-1 rounded-full text-xs font-semibold {getRoleBadgeClass(user.attributes?.role || '')}">
                    {getRoleLabel(user.attributes?.role || '')}
                  </span>
                </td>
                <td class="px-6 py-4">
                  <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold {user.attributes?.status === 'active' ? 'bg-green-100 text-green-900' : 'bg-yellow-100 text-yellow-900'}">
                    <div class="w-2 h-2 rounded-full {user.attributes?.status === 'active' ? 'bg-green-600' : 'bg-yellow-600'}"></div>
                    {user.attributes?.status === 'active' ? 'Ativo' : 'Inativo'}
                  </div>
                </td>
                <td class="px-6 py-4">
                  <p class="text-sm font-mono text-gray-700">{user.attributes?.oab || '-'}</p>
                </td>
                <td class="px-6 py-4">
                  <div class="flex justify-center gap-2">
                    <button 
                      class="p-2 rounded-lg text-[#0277EE] hover:bg-[#0277EE]/10 transition-colors duration-200"
                      on:click={() => openEditForm(user)} 
                      title="Editar usuário"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                    </button>
                    <button 
                      class="p-2 rounded-lg text-red-600 hover:bg-red-100 transition-colors duration-200"
                      on:click={() => openDeleteDialog(user)} 
                      title="Remover usuário"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                    </button>
                  </div>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>
</div>

<!-- Modal Dialog -->
<dialog class="modal" open={userFormStore.mode !== null}>
  <div class="modal-box w-11/12 max-w-4xl max-h-[90vh] overflow-y-auto rounded-2xl">
    <UserFormUnified />
  </div>
  <form method="dialog" class="modal-backdrop" on:submit|preventDefault={() => userFormStore.reset()}>
    <button>close</button>
  </form>
</dialog>

<!-- Delete Confirmation Dialog -->
{#if showDeleteDialog && deletingUser}
  <ConfirmDialog
    show={showDeleteDialog}
    title="Confirmar Remoção"
    message="Tem certeza que deseja remover o usuário {deletingUser.attributes?.name || 'Usuário'}?"
    confirmText="Remover"
    cancelText="Cancelar"
    type="danger"
    on:confirm={handleDeleteConfirm}
    on:cancel={closeDeleteDialog}
  />
{/if}
