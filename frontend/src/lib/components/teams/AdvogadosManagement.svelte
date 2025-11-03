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

  let users: User[] = [];
  let loading = false;
  let error: string | null = null;
  let success: string | null = null;

  const formState = userFormStore;

  let showDeleteDialog = false;
  let deletingUser: User | null = null;

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

  // ============== ALTERAÇÃO: Chama o novo método startInvite ======================
  function openInviteForm() {
    userFormStore.startInvite(); // Agora chama a função correta para o fluxo de convite
  }
  // ==============================================================================

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

  // ====================== ALTERAÇÃO: Mensagem de sucesso diferenciada para convite ======================
  async function handleSaveSuccess() {
    if ($formState.mode === 'invite') {
      success = 'Convite enviado com sucesso!'; // Mensagem específica para convite
    } else {
      success = $formState.mode === 'create' ? 'Usuário criado com sucesso!' : 'Usuário atualizado com sucesso!';
    }
    await loadUsers(); // Recarrega a lista de usuários

    // Fecha o modal imediatamente resetando o store
    userFormStore.reset(); 

    // Mantém a mensagem de sucesso visível na tela principal por um tempo
    setTimeout(() => {
      success = null;
    }, 1500);
  }
  // =====================================================================================================

  $: {
    if ($formState.success) {
      handleSaveSuccess();
    }
  }

  function getRoleBadgeClass(role: string): string {
    const map: Record<string, string> = { lawyer: 'badge-primary', paralegal: 'badge-secondary', trainee: 'badge-accent', secretary: 'badge-info' };
    return map[role] || 'badge-ghost';
  }

  function getRoleLabel(role: string): string {
    const map: Record<string, string> = { lawyer: 'Advogado', paralegal: 'Paralegal', trainee: 'Estagiário', secretary: 'Secretário', counter: 'Contador', excounter: 'Ex-contador', representant: 'Representante' };
    return map[role] || role;
  }

  onMount(() => {
    loadUsers();
  });
</script>

<div class="p-6">
  <div class="flex justify-between items-center mb-6">
    <div>
      <h2 class="text-2xl font-semibold text-gray-800">Gerenciar Usuários</h2>
      <p class="text-gray-600 text-sm mt-1">Crie, edite e gerencie usuários do sistema</p>
    </div>
    <div class="flex space-x-4">
      <button class="btn btn-secondary" on:click={openInviteForm} disabled={loading}>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        Convidar Usuário
      </button>
      <button class="btn btn-primary" on:click={openCreateForm} disabled={loading}>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
        </svg>
        Novo Usuário
      </button>
    </div>
  </div>

  {#if success}<div class="alert alert-success mb-4"><span>{success}</span></div>{/if}
  {#if error}<div class="alert alert-error mb-4"><span>{error}</span></div>{/if}

  <div class="card bg-base-100 border border-base-300">
    <div class="card-body">
      {#if loading}
        <div class="text-center p-10">
          <span class="loading loading-lg loading-spinner text-primary"></span>
          <p class="mt-4 text-gray-500">Carregando usuários...</p>
        </div>
      {:else if users.length === 0}
         <div class="text-center p-10">
          <p class="text-gray-500">Nenhum usuário encontrado.</p>
        </div>
      {:else}
        <div class="overflow-x-auto">
          <table class="table table-zebra w-full">
            <thead>
              <tr>
                <th>Nome</th>
                <th>Email</th>
                <th>Função</th>
                <th>Status</th>
                <th>OAB</th>
                <th class="text-center">Ações</th>
              </tr>
            </thead>
            <tbody>
              {#each users as user}
                <tr>
                  <td>
                    <div class="flex items-center space-x-3">
                      <div class="avatar placeholder">
                        <div class="bg-neutral-focus text-neutral-content rounded-full w-10">
                          <span class="text-sm">{user.attributes?.name?.charAt(0) || '?'}</span>
                        </div>
                      </div>
                      <div>
                        <div class="font-bold">{user.attributes?.name || 'Nome não informado'} {user.attributes?.last_name || ''}</div>
                        <div class="text-sm opacity-50">ID: #{user.id}</div>
                      </div>
                    </div>
                  </td>
                  <td><span class="text-sm">{user.attributes?.access_email || 'Email não informado'}</span></td>
                  <td><span class="badge {getRoleBadgeClass(user.attributes?.role || '')}">{getRoleLabel(user.attributes?.role || '')}</span></td>
                  <td><div class="badge {user.attributes?.status === 'active' ? 'badge-success' : 'badge-warning'} badge-sm">{user.attributes?.status === 'active' ? 'Ativo' : 'Inativo'}</div></td>
                  <td><span class="text-sm font-mono">{user.attributes?.oab || '-'}</span></td>
                  <td class="text-center">
                    <div class="flex justify-center space-x-2">
                      <button class="btn btn-ghost btn-xs" on:click={() => openEditForm(user)} title="Editar usuário">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                      </button>
                      <button class="btn btn-ghost btn-xs text-error hover:bg-error hover:text-error-content" on:click={() => openDeleteDialog(user)} title="Remover usuário">
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
</div>

<dialog class="modal" open={$formState.mode !== null}>
  <div class="modal-box w-11/12 max-w-4xl">
    <UserFormUnified />
  </div>
  <form method="dialog" class="modal-backdrop" on:submit|preventDefault={() => userFormStore.reset()}>
    <button>close</button>
  </form>
</dialog>

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