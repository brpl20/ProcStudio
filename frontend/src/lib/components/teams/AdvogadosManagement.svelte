
<script lang="ts">
  import { onMount } from 'svelte';
  import api from '../../api';
  import ConfirmDialog from '../ui/ConfirmDialog.svelte';
  import { userFormStore } from '../../stores/userFormStore.svelte.ts';
  import UserFormUnified from './UserFormUnified.svelte';
  import UserDetailView from './UserDetailView.svelte';
  

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

  let users = $state<User[]>([]);
  let loading = $state(false);
  let error = $state<string | null>(null);
  let success = $state<string | null>(null);

  let showDeleteDialog = $state(false);
  let deletingUser = $state<User | null>(null);

  // ====================== 2. ESTADO PARA O MODAL DE DETALHES =====================
  let showDetailModal = $state(false);
  let viewingUser = $state<User | null>(null);
  // ==============================================================================

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

  // =================== 3. FUNÇÃO PARA ABRIR O MODAL DE DETALHES =================
  function openUserDetail(user: User) {
    viewingUser = user;
    showDetailModal = true;
  }
  // ==============================================================================

  // ============= 6. FUNÇÃO PARA LIDAR COM O EVENTO DE EDIÇÃO ====================
  function handleEditFromDetail(event: CustomEvent<User>) {
    const userToEdit = event.detail;
    showDetailModal = false; // Fecha o modal de detalhes
    viewingUser = null;
    // Um pequeno delay para garantir que o modal de detalhes fechou antes do de edição abrir
    setTimeout(() => {
      openEditForm(userToEdit);
    }, 150);
  }
  // ==============================================================================

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
  <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
    <div>
      <h2 class="text-2xl font-semibold text-gray-800">Gerenciar Usuários</h2>
      <p class="text-gray-600 text-sm mt-1">Crie, edite e gerencie usuários do sistema</p>
    </div>
    <div class="flex flex-wrap gap-4">
      <button class="btn btn-secondary" onclick={openInviteForm} disabled={loading}>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        Convidar Usuário
      </button>
      <button class="btn btn-primary" onclick={openCreateForm} disabled={loading}>
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
                    <div class="flex justify-center space-x-1">
                      <!-- ============= 4. BOTÃO "VER DETALHES" NA TABELA ============== -->
                      <button class="btn btn-ghost btn-xs" onclick={() => openUserDetail(user)} title="Ver detalhes">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                      </button>
                      <!-- ==================================================================== -->
                      <button class="btn btn-ghost btn-xs" onclick={() => openEditForm(user)} title="Editar usuário">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                      </button>
                      <button class="btn btn-ghost btn-xs text-error hover:bg-error hover:text-error-content" onclick={() => openDeleteDialog(user)} title="Remover usuário">
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

<!-- Modal do Formulário de Edição/Criação -->
<dialog class="modal" open={userFormStore.mode !== null}>
  <div class="modal-box w-11/12 max-w-4xl">
    <UserFormUnified />
  </div>
  <form method="dialog" class="modal-backdrop" onsubmit={(e) => { e.preventDefault(); userFormStore.reset(); }}>
    <button>close</button>
  </form>
</dialog>

<!-- ======================= 5. NOVO MODAL PARA DETALHES DO USUÁRIO ========================= -->
<dialog class="modal" open={showDetailModal}>
  <div class="modal-box w-11/12 max-w-4xl">
    {#if viewingUser}
      <UserDetailView user={viewingUser} on:edit={handleEditFromDetail} />
    {/if}
  </div>
  <form method="dialog" class="modal-backdrop" onsubmit={(e) => { e.preventDefault(); showDetailModal = false; viewingUser = null; }}>
    <button>close</button>
  </form>
</dialog>
<!-- ======================================================================================== -->


{#if showDeleteDialog && deletingUser}
  <ConfirmDialog
    show={showDeleteDialog}
    title="Confirmar Remoção"
    message="Tem certeza que deseja remover o usuário {deletingUser.attributes?.name || 'Usuário'}?"
    confirmText="Remover"
    cancelText="Cancelar"
    type="danger"
    onConfirm={handleDeleteConfirm}
    onCancel={closeDeleteDialog}
  />
{/if}
