<script>
  import { onMount } from 'svelte';
  import api from '../../api';
  import TeamManagement from './TeamManagement.svelte';
  import AdvogadosManagement from './AdvogadosManagement.svelte';

  let activeTab = 'teams';
  let myTeam = null;
  let loading = true;
  let error = null;

  const tabs = [
    { id: 'teams', label: 'Gerenciar Equipe', icon: '👥' },
    { id: 'advogados', label: 'Gerenciar Usuários', icon: '⚖️' }
  ];

  async function loadMyTeam() {
    try {
      loading = true;
      const response = await api.teams.getMyTeam();
      myTeam = response.data.team;
      console.log('Loaded team data:', myTeam);
    } catch (err) {
      error = err.message || 'Erro ao carregar dados da equipe';
      console.error('Error loading team:', err);
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

<div class="p-6">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-2">Configuração de Equipes</h1>
    <p class="text-gray-600">Gerencie sua equipe e usuários do sistema</p>
  </div>

  <!-- Tab Navigation -->
  <div class="tabs tabs-boxed bg-base-200 mb-6">
    {#each tabs as tab}
      <button
        class="tab tab-lg {activeTab === tab.id ? 'tab-active' : ''}"
        on:click={() => switchTab(tab.id)}
      >
        <span class="mr-2">{tab.icon}</span>
        {tab.label}
      </button>
    {/each}
  </div>

  <!-- Tab Content -->
  <div class="bg-white rounded-lg shadow-sm border border-gray-200">
    {#if loading}
      <div class="flex items-center justify-center p-12">
        <span class="loading loading-spinner loading-lg text-primary"></span>
        <span class="ml-3 text-lg">Carregando...</span>
      </div>
    {:else if error}
      <div class="p-6">
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
      </div>
    {:else if activeTab === 'teams'}
      <TeamManagement {myTeam} on:teamUpdated={loadMyTeam} />
    {:else if activeTab === 'advogados'}
      <AdvogadosManagement />
    {/if}
  </div>
</div>
