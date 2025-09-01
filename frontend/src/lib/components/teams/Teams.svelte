<script lang="ts">
  import { router } from './stores/routerStore.js';

  let activeTab = 'advogados';

  // Mock data for demonstration
  const advogados = [
    { id: 1, name: 'Ana Silva', email: 'ana.silva@exemplo.com', oab: 'OAB/SP 123456' },
    { id: 2, name: 'Carlos Santos', email: 'carlos.santos@exemplo.com', oab: 'OAB/RJ 654321' }
  ];

  const escritorios = [
    {
      id: 1,
      name: 'Escritório Silva & Advogados',
      cnpj: '12.345.678/0001-90',
      endereco: 'São Paulo, SP'
    },
    { id: 2, name: 'Santos Advocacia', cnpj: '98.765.432/0001-12', endereco: 'Rio de Janeiro, RJ' }
  ];

  function setActiveTab(tab: string) {
    activeTab = tab;
  }

  function navigateToAdvogadoCreate() {
    router.navigate('/teams/advogados/new');
  }

  function navigateToEscritorioCreate() {
    router.navigate('/teams/escritorios/new');
  }

  function navigateToAdvogadoView(id: number) {
    router.navigate(`/teams/advogados/${id}`);
  }

  function navigateToEscritorioView(id: number) {
    router.navigate(`/teams/escritorios/${id}`);
  }
</script>

<div class="container mx-auto px-4 py-6">
  <!-- Header -->
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-base-content mb-2">Times</h1>
    <p class="text-base-content/70">Gerencie equipes, advogados e escritórios</p>
  </div>

  <!-- Tabs -->
  <div class="tabs tabs-boxed mb-6 bg-base-200">
    <button
      class="tab {activeTab === 'equipe' ? 'tab-active' : ''}"
      on:click={() => setActiveTab('equipe')}
    >
      Equipe
    </button>
    <button
      class="tab {activeTab === 'advogados' ? 'tab-active' : ''}"
      on:click={() => setActiveTab('advogados')}
    >
      Advogados
    </button>
    <button
      class="tab {activeTab === 'escritorios' ? 'tab-active' : ''}"
      on:click={() => setActiveTab('escritorios')}
    >
      Escritórios
    </button>
  </div>

  <!-- Tab Content -->
  <div class="tab-content">
    {#if activeTab === 'equipe'}
      <!-- Equipe Tab - Empty for now -->
      <div class="card bg-base-100 shadow-lg">
        <div class="card-body">
          <h2 class="card-title">Equipe</h2>
          <p class="text-base-content/70">Em desenvolvimento...</p>
        </div>
      </div>
    {/if}

    {#if activeTab === 'advogados'}
      <!-- Advogados Tab -->
      <div class="space-y-6">
        <!-- Header with Create Button -->
        <div class="flex justify-between items-center">
          <h2 class="text-2xl font-semibold">Advogados</h2>
          <button class="btn btn-primary" on:click={navigateToAdvogadoCreate}>
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
                d="M12 4v16m8-8H4"
              />
            </svg>
            Novo Advogado
          </button>
        </div>

        <!-- Advogados List -->
        <div class="grid gap-4">
          {#each advogados as advogado}
            <div class="card bg-base-100 shadow hover:shadow-lg transition-shadow">
              <div class="card-body">
                <div class="flex justify-between items-start">
                  <div class="flex-1">
                    <h3 class="card-title text-lg">{advogado.name}</h3>
                    <p class="text-base-content/70 text-sm">{advogado.email}</p>
                    <p class="text-base-content/70 text-sm">{advogado.oab}</p>
                  </div>
                  <button
                    class="btn btn-outline btn-sm"
                    on:click={() => navigateToAdvogadoView(advogado.id)}
                  >
                    Ver Detalhes
                  </button>
                </div>
              </div>
            </div>
          {/each}

          {#if advogados.length === 0}
            <div class="text-center py-12">
              <p class="text-base-content/70">Nenhum advogado cadastrado</p>
              <button class="btn btn-primary btn-sm mt-4" on:click={navigateToAdvogadoCreate}>
                Cadastrar Primeiro Advogado
              </button>
            </div>
          {/if}
        </div>
      </div>
    {/if}

    {#if activeTab === 'escritorios'}
      <!-- Escritórios Tab -->
      <div class="space-y-6">
        <!-- Header with Create Button -->
        <div class="flex justify-between items-center">
          <h2 class="text-2xl font-semibold">Escritórios</h2>
          <button class="btn btn-primary" on:click={navigateToEscritorioCreate}>
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
                d="M12 4v16m8-8H4"
              />
            </svg>
            Novo Escritório
          </button>
        </div>

        <!-- Escritórios List -->
        <div class="grid gap-4">
          {#each escritorios as escritorio}
            <div class="card bg-base-100 shadow hover:shadow-lg transition-shadow">
              <div class="card-body">
                <div class="flex justify-between items-start">
                  <div class="flex-1">
                    <h3 class="card-title text-lg">{escritorio.name}</h3>
                    <p class="text-base-content/70 text-sm">{escritorio.cnpj}</p>
                    <p class="text-base-content/70 text-sm">{escritorio.endereco}</p>
                  </div>
                  <button
                    class="btn btn-outline btn-sm"
                    on:click={() => navigateToEscritorioView(escritorio.id)}
                  >
                    Ver Detalhes
                  </button>
                </div>
              </div>
            </div>
          {/each}

          {#if escritorios.length === 0}
            <div class="text-center py-12">
              <p class="text-base-content/70">Nenhum escritório cadastrado</p>
              <button class="btn btn-primary btn-sm mt-4" on:click={navigateToEscritorioCreate}>
                Cadastrar Primeiro Escritório
              </button>
            </div>
          {/if}
        </div>
      </div>
    {/if}
  </div>
</div>
