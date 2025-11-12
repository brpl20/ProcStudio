<script lang="ts">
  import { onMount } from 'svelte';
  import api from '../../api';

  let { teamId = null } = $props();

  let members = $state([]);
  let loading = $state(true);
  let error = $state(null);

  async function loadTeamMembers() {
    if (!teamId) {
      return;
    }

    try {
      loading = true;
      error = null;

      const response = await api.teams.getMyTeamMembers();
      members = response.data.members || [];
    } catch (err) {
      error = err.message || 'Erro ao carregar membros da equipe';
    } finally {
      loading = false;
    }
  }

  function getRoleBadgeClass(role) {
    switch (role) {
    case 'lawyer':
      return 'bg-[#01013D] text-white';
    case 'paralegal':
      return 'bg-[#01013D] text-white';
    case 'trainee':
      return 'bg-[#01013D]/20 text-[#01013D]';
    case 'secretary':
      return 'bg-[#eef0ef] text-[#01013D] border border-[#01013D]/20';
    default:
      return 'bg-gray-100 text-gray-600';
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

  $effect(() => {
    if (teamId) {
      loadTeamMembers();
    }
  });
</script>

<div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] overflow-hidden">
  <div class="p-6 bg-gradient-to-br from-[#01013D] to-[#01013D]">
    <div class="flex justify-between items-center">
      <h3 class="text-2xl font-bold text-white">Membros da Equipe</h3>
      <button
        class="group relative px-5 py-2.5 bg-white/10 hover:bg-white/20 backdrop-blur-sm text-white rounded-xl transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed border border-white/20 hover:border-white/40 hover:shadow-lg hover:shadow-white/10"
        on:click={loadTeamMembers}
        disabled={loading}
      >
        <div class="flex items-center gap-2">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4 transition-transform duration-300 {loading ? 'animate-spin' : 'group-hover:rotate-180'}"
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
          <span class="font-medium">Atualizar</span>
        </div>
      </button>
    </div>
  </div>

  <div class="p-6">
    {#if loading}
      <div class="flex flex-col items-center justify-center py-16">
        <div class="relative">
          <div class="w-16 h-16 border-4 border-[#eef0ef] border-t-[#01013D] rounded-full animate-spin"></div>
          <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-8 h-8 border-4 border-transparent border-b-[#01013D] rounded-full animate-spin"></div>
        </div>
        <span class="mt-4 text-[#01013D] font-medium">Carregando membros...</span>
      </div>
    {:else if error}
      <div class="bg-red-50 border-l-4 border-red-500 p-4 rounded-lg">
        <div class="flex items-center">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6 text-red-500 mr-3"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span class="text-red-800 font-medium">{error}</span>
        </div>
      </div>
    {:else if members.length === 0}
      <div class="text-center py-16">
        <div class="mb-6 inline-flex items-center justify-center w-24 h-24 rounded-full bg-gradient-to-br from-[#eef0ef] to-[#01013D]/10">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-12 w-12 text-[#01013D]"
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
        <p class="text-[#01013D] text-lg font-semibold mb-2">Nenhum membro encontrado</p>
        <p class="text-gray-500">Os membros da equipe aparecerão aqui</p>
      </div>
    {:else}
      <div class="space-y-3">
        {#each members as member, index}
          <div class="group bg-gradient-to-r from-[#eef0ef]/30 to-white hover:from-[#eef0ef]/50 hover:to-[#01013D]/5 border border-[#eef0ef] hover:border-[#01013D]/30 rounded-xl p-4 transition-all duration-300 hover:shadow-md">
            <div class="flex items-center justify-between gap-4">
              <div class="flex items-center gap-4 flex-1 min-w-0">
                <div class="relative flex-shrink-0">
                  <div class="w-12 h-12 rounded-full bg-gradient-to-br from-[#01013D] to-[#01013D] flex items-center justify-center ring-2 ring-white shadow-lg">
                    <span class="text-white font-bold text-lg">
                      {member.profile?.name?.charAt(0) || member.email?.charAt(0) || '?'}
                    </span>
                  </div>
                </div>

                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-2 mb-1">
                    <h4 class="font-bold text-[#01013D] text-lg truncate">
                      {member.profile?.name || 'Nome não informado'}
                      {member.profile?.last_name || ''}
                    </h4>
                  </div>
                  <p class="text-gray-600 text-sm truncate">
                    {member.email || 'Email não informado'}
                  </p>
                </div>
              </div>

              <div class="flex items-center gap-3 flex-shrink-0">
                <div class="text-right hidden sm:block">
                  {#if member.profile?.oab}
                    <div class="text-xs text-gray-500 mb-1">OAB</div>
                    <div class="font-mono font-semibold text-[#01013D]">
                      {member.profile.oab}
                    </div>
                  {:else}
                    <div class="text-xs text-gray-400">-</div>
                  {/if}
                </div>

                <div class="flex flex-col gap-2">
                  <span class="px-3 py-1 rounded-lg text-xs font-semibold {getRoleBadgeClass(member.profile?.role)} whitespace-nowrap">
                    {getRoleLabel(member.profile?.role)}
                  </span>
                  <span class="px-3 py-1 rounded-lg text-xs font-semibold whitespace-nowrap {member.status === 'active'
                      ? 'bg-green-100 text-green-700'
                      : 'bg-yellow-100 text-yellow-700'}">
                    {member.status === 'active' ? 'Ativo' : 'Inativo'}
                  </span>
                </div>
              </div>
            </div>
          </div>
        {/each}
      </div>

      <div class="mt-6 pt-6 border-t border-[#eef0ef]">
        <div class="flex items-center justify-between">
          <span class="text-gray-600 font-medium">
            Total: <span class="text-[#01013D] font-bold">{members.length}</span> membro{members.length !== 1 ? 's' : ''}
          </span>
          <div class="flex gap-2">
            <div class="w-2 h-2 rounded-full bg-[#01013D] animate-pulse"></div>
            <div class="w-2 h-2 rounded-full bg-[#01013D] animate-pulse" style="animation-delay: 0.2s"></div>
            <div class="w-2 h-2 rounded-full bg-[#01013D] animate-pulse" style="animation-delay: 0.4s"></div>
          </div>
        </div>
      </div>
    {/if}
  </div>
</div>
