<script>
  import { onMount } from 'svelte';
  import api from '../../api';

  export let teamId = null;

  let members = [];
  let loading = true;
  let error = null;

  async function loadTeamMembers() {
    if (!teamId) return;

    try {
      loading = true;
      error = null;

      const response = await api.teams.getMyTeamMembers();
      members = response.data.members || [];
      console.log('Loaded team members:', members);
    } catch (err) {
      error = err.message || 'Erro ao carregar membros da equipe';
      console.error('Error loading team members:', err);
    } finally {
      loading = false;
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
    if (teamId) {
      loadTeamMembers();
    }
  });

  // Reload when teamId changes
  $: if (teamId) {
    loadTeamMembers();
  }
</script>

<div class="card bg-base-100 border border-base-300">
  <div class="card-body">
    <div class="flex justify-between items-center mb-4">
      <h3 class="card-title text-lg">Membros da Equipe</h3>
      <button
        class="btn btn-outline btn-primary btn-sm"
        on:click={loadTeamMembers}
        disabled={loading}
      >
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

    {#if loading}
      <div class="flex items-center justify-center py-8">
        <span class="loading loading-spinner loading-md text-primary"></span>
        <span class="ml-2">Carregando membros...</span>
      </div>
    {:else if error}
      <div class="alert alert-error">
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
    {:else if members.length === 0}
      <div class="text-center py-8">
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
              d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
            />
          </svg>
        </div>
        <p class="text-gray-500 mb-2">Nenhum membro encontrado</p>
        <p class="text-sm text-gray-400">Os membros da equipe aparecerão aqui</p>
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
            </tr>
          </thead>
          <tbody>
            {#each members as member}
              <tr>
                <td>
                  <div class="flex items-center space-x-3">
                    <div class="avatar placeholder">
                      <div class="bg-neutral-focus text-neutral-content rounded-full w-8">
                        <span class="text-xs">
                          {member.profile?.name?.charAt(0) || member.email?.charAt(0) || '?'}
                        </span>
                      </div>
                    </div>
                    <div>
                      <div class="font-bold">
                        {member.profile?.name || 'Nome não informado'}
                        {member.profile?.last_name || ''}
                      </div>
                    </div>
                  </div>
                </td>
                <td>
                  <span class="text-sm">
                    {member.email || 'Email não informado'}
                  </span>
                </td>
                <td>
                  <div class="badge {getRoleBadgeClass(member.profile?.role)} badge-sm">
                    {getRoleLabel(member.profile?.role)}
                  </div>
                </td>
                <td>
                  <div
                    class="badge {member.status === 'active'
                      ? 'badge-success'
                      : 'badge-warning'} badge-sm"
                  >
                    {member.status === 'active' ? 'Ativo' : 'Inativo'}
                  </div>
                </td>
                <td>
                  <span class="text-sm font-mono">
                    {member.profile?.oab || '-'}
                  </span>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>

      <div class="flex justify-between items-center mt-4 text-sm text-gray-500">
        <span>Total: {members.length} membro{members.length !== 1 ? 's' : ''}</span>
      </div>
    {/if}
  </div>
</div>
