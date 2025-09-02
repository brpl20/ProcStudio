<script>
  import { onMount } from 'svelte';
  import api from '../../api';
  import UserForm from './UserForm.svelte';
  import ConfirmDialog from '../ui/ConfirmDialog.svelte';

  let users = [];
  let loading = true;
  let error = null;
  let success = null;

  // Modal states
  let showUserForm = false;
  let showDeleteDialog = false;
  let editingUser = null;
  let deletingUser = null;

  // Form mode
  let formMode = 'create'; // 'create' or 'edit'

  async function loadUsers() {
    try {
      loading = true;
      error = null;

      const response = await api.users.getUserProfiles();
      users = response.data || [];
    } catch (err) {
      error = err.message || 'Erro ao carregar usuários';
      console.error('Error loading users:', err);
    } finally {
      loading = false;
    }
  }

  function openCreateForm() {
    editingUser = null;
    formMode = 'create';
    showUserForm = true;
  }

  function openEditForm(user) {
    editingUser = user;
    formMode = 'edit';
    showUserForm = true;
  }

  function closeUserForm() {
    showUserForm = false;
    editingUser = null;
  }

  async function handleUserSaved(event) {
    const { success: isSuccess, message } = event.detail;

    if (isSuccess) {
      success = message;
      closeUserForm();
      await loadUsers();

      // Clear success message after 3 seconds
      setTimeout(() => {
        success = null;
      }, 3000);
    }
  }

  function openDeleteDialog(user) {
    deletingUser = user;
    showDeleteDialog = true;
  }

  function closeDeleteDialog() {
    showDeleteDialog = false;
    deletingUser = null;
  }

  async function handleDeleteConfirm() {
    if (!deletingUser) return;

    try {
      const response = await api.users.deleteUserProfile(deletingUser.id);

      if (response.success) {
        success = 'Usuário removido com sucesso!';
        await loadUsers();

        // Clear success message after 3 seconds
        setTimeout(() => {
          success = null;
        }, 3000);
      } else {
        error = response.message || 'Erro ao remover usuário';
      }
    } catch (err) {
      error = err.message || 'Erro ao remover usuário';
      console.error('Error deleting user:', err);
    } finally {
      closeDeleteDialog();
    }
  }

  function getRoleBadgeClass(role) {
    switch (role) {
      case 'lawyer':
        return 'badge-primary';
      case 'paralegal':
        return 'badge-secondary';
      case 'trainee':
        return 'badge-accent';
      case 'secretary':
        return 'badge-info';
      default:
        return 'badge-ghost';
    }
  }

  function getRoleLabel(role) {
    const roleMap = {
      lawyer: 'Advogado',
      paralegal: 'Paralegal',
      trainee: 'Estagiário',
      secretary: 'Secretário',
      counter: 'Contador',
      excounter: 'Ex-Contador',
      representant: 'Representante'
    };
    return roleMap[role] || role;
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
    <button class="btn btn-primary" on:click={openCreateForm} disabled={loading}>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-5 w-5 mr-2"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M12 6v6m0 0v6m0-6h6m-6 0H6"
        />
      </svg>
      Novo Usuário
    </button>
  </div>

  <!-- Success Alert -->
  {#if success}
    <div class="alert alert-success mb-4">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="stroke-current shrink-0 h-6 w-6"
        fill="none"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
        />
      </svg>
      <span>{success}</span>
    </div>
  {/if}

  <!-- Error Alert -->
  {#if error}
    <div class="alert alert-error mb-4">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="stroke-current shrink-0 h-6 w-6"
        fill="none"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
        />
      </svg>
      <span>{error}</span>
    </div>
  {/if}

  <!-- Users Table -->
  <div class="card bg-base-100 border border-base-300">
    <div class="card-body">
      {#if loading}
        <div class="flex items-center justify-center py-12">
          <span class="loading loading-spinner loading-lg text-primary"></span>
          <span class="ml-3 text-lg">Carregando usuários...</span>
        </div>
      {:else if users.length === 0}
        <div class="text-center py-12">
          <div class="mb-4">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-16 w-16 mx-auto text-gray-300"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
              />
            </svg>
          </div>
          <p class="text-gray-500 mb-2">Nenhum usuário encontrado</p>
          <p class="text-sm text-gray-400 mb-4">Comece criando o primeiro usuário do sistema</p>
          <button class="btn btn-primary btn-sm" on:click={openCreateForm}>
            Criar Primeiro Usuário
          </button>
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
                          <span class="text-sm">
                            {user.attributes?.name?.charAt(0) || '?'}
                          </span>
                        </div>
                      </div>
                      <div>
                        <div class="font-bold">
                          {user.attributes?.name || 'Nome não informado'}
                          {user.attributes?.last_name || ''}
                        </div>
                        <div class="text-sm opacity-50">ID: #{user.id}</div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span class="text-sm">
                      {user.attributes?.access_email || 'Email não informado'}
                    </span>
                  </td>
                  <td>
                    <div class="badge {getRoleBadgeClass(user.attributes?.role)} badge-sm">
                      {getRoleLabel(user.attributes?.role)}
                    </div>
                  </td>
                  <td>
                    <div
                      class="badge {user.attributes?.status === 'active'
                        ? 'badge-success'
                        : 'badge-warning'} badge-sm"
                    >
                      {user.attributes?.status === 'active' ? 'Ativo' : 'Inativo'}
                    </div>
                  </td>
                  <td>
                    <span class="text-sm font-mono">
                      {user.attributes?.oab || '-'}
                    </span>
                  </td>
                  <td class="text-center">
                    <div class="flex justify-center space-x-2">
                      <button
                        class="btn btn-ghost btn-xs"
                        on:click={() => openEditForm(user)}
                        title="Editar usuário"
                      >
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          class="h-4 w-4"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                          />
                        </svg>
                      </button>
                      <button
                        class="btn btn-ghost btn-xs text-error hover:bg-error hover:text-error-content"
                        on:click={() => openDeleteDialog(user)}
                        title="Remover usuário"
                      >
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          class="h-4 w-4"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                          />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>

        <div class="flex justify-between items-center mt-4 text-sm text-gray-500">
          <span>Total: {users.length} usuário{users.length !== 1 ? 's' : ''}</span>
          <button class="btn btn-ghost btn-sm" on:click={loadUsers} disabled={loading}>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4 mr-1"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
              />
            </svg>
            Atualizar
          </button>
        </div>
      {/if}
    </div>
  </div>
</div>

<!-- User Form Modal -->
{#if showUserForm}
  <UserForm
    isOpen={showUserForm}
    user={editingUser}
    mode={formMode}
    on:saved={handleUserSaved}
    on:close={closeUserForm}
  />
{/if}

<!-- Delete Confirmation Dialog -->
{#if showDeleteDialog && deletingUser}
  <ConfirmDialog
    isOpen={showDeleteDialog}
    title="Confirmar Remoção"
    message="Tem certeza que deseja remover o usuário {deletingUser.attributes?.name ||
      'Usuário'}? Esta ação pode ser desfeita posteriormente."
    confirmText="Remover"
    cancelText="Cancelar"
    confirmClass="btn-error"
    on:confirm={handleDeleteConfirm}
    on:cancel={closeDeleteDialog}
  />
{/if}
