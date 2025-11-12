<script>
  import { onMount } from 'svelte';
  import api from '../../api';
  import TeamManagement from './TeamManagement.svelte';
  import AdvogadosManagement from './AdvogadosManagement.svelte';
  import OfficeManagement from './OfficeManagement.svelte';

  let activeTab = 'teams';
  let myTeam = null;
  let loading = true;
  let error = null;

  const tabs = [
    {
      id: 'teams',
      label: 'Gerenciar Equipe',
      icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 8.048M7 14H5a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2h-2m-1-7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>'
    },
    {
      id: 'advogados',
      label: 'Gerenciar Usuários',
      icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>'
    },
    {
      id: 'offices',
      label: 'Escritórios',
      icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z"></path></svg>'
    }
  ];

  async function loadMyTeam() {
    try {
      loading = true;
      const response = await api.teams.getMyTeam();
      myTeam = response.data.team;
    } catch (err) {
      error = err.message || 'Erro ao carregar dados da equipe';
    } finally {
      loading = false;
    }
  }

  function switchTab(tabId) {
    activeTab = tabId;
  }

  onMount(() => {
    loadMyTeam();
  });
</script>

<div class="space-y-6">
  <!-- Header -->
  <div>
    <h1 class="text-4xl font-bold text-gray-900 mb-2">Configuração de Equipes</h1>
    <p class="text-gray-600 text-lg">Gerencie sua equipe, usuários do sistema e escritórios</p>
  </div>

  <!-- Tab Navigation -->
  <div class="flex gap-2 bg-white rounded-lg p-1 border border-gray-200 shadow-sm">
    {#each tabs as tab}
      <button
        class={`flex items-center gap-2.5 px-6 py-3 rounded-md font-medium transition-all duration-300 ${
          activeTab === tab.id
            ? 'bg-gradient-to-r from-[#01013D] to-[#01013D] text-white shadow-lg shadow-[#01013D]/30'
            : 'text-gray-700 hover:bg-[#eef0ef] hover:text-[]'
        }`}
        onclick={() => switchTab(tab.id)}
      >
        <span class="flex-shrink-0">
          {@html tab.icon}
        </span>
        <span>{tab.label}</span>
      </button>
    {/each}
  </div>

  <!-- Tab Content -->
  <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
    {#if loading}
      <div class="flex items-center justify-center p-16">
        <div class="text-center">
          <div class="inline-block mb-4">
            <div class="loading loading-spinner loading-lg" style="color: ;"></div>
          </div>
          <p class="text-lg text-gray-600 font-medium">Carregando...</p>
        </div>
      </div>
    {:else if error}
      <div class="p-8">
        <div class="bg-red-50 border border-red-200 rounded-lg p-6 flex items-start gap-4">
          <svg
            class="w-6 h-6 text-red-600 flex-shrink-0 mt-0.5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 8v4m0 4v.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <div>
            <h3 class="text-red-900 font-semibold mb-1">Erro ao carregar</h3>
            <p class="text-red-800">{error}</p>
          </div>
        </div>
      </div>
    {:else if activeTab === 'teams'}
      <TeamManagement {myTeam} onTeamUpdated={loadMyTeam} />
    {:else if activeTab === 'advogados'}
      <AdvogadosManagement />
    {:else if activeTab === 'offices'}
      <OfficeManagement />
    {/if}
  </div>
</div>

<style>
  :global(.loading) {
    --loading-bg: ;
  }
</style>
