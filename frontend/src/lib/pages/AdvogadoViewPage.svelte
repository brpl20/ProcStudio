<script lang="ts">
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import { router } from '../stores/routerStore.js';

  export let id: string;

  // Mock data - in real implementation, fetch from API
  let advogado = {
    id: parseInt(id),
    name: 'Ana Silva',
    email: 'ana.silva@exemplo.com',
    oab: 'OAB/SP 123456',
    telefone: '(11) 99999-9999',
    endereco: 'São Paulo, SP'
  };

  let isLoading = false;
  let error: string | null = null;

  function handleBack() {
    router.navigate('/teams');
  }

  function handleEdit() {
    // TODO: Implement edit functionality
    alert('Funcionalidade de edição será implementada');
  }
</script>

<svelte:head>
  <title>{advogado.name} - Advogado</title>
</svelte:head>

<AuthSidebar>
  <div class="container mx-auto px-4 py-6">
    {#if isLoading}
      <div class="flex justify-center items-center h-64">
        <div class="flex flex-col items-center gap-4">
          <span class="loading loading-spinner loading-lg"></span>
          <p class="text-lg">Carregando dados do advogado...</p>
        </div>
      </div>
    {:else if error}
      <div class="alert alert-error max-w-md mx-auto">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <div>
          <h3 class="font-bold">Erro ao carregar advogado</h3>
          <div class="text-xs">{error}</div>
        </div>
      </div>
      <div class="text-center mt-6">
        <button class="btn btn-primary" on:click={handleBack}>
          ← Voltar à lista
        </button>
      </div>
    {:else}
      <!-- Header -->
      <div class="mb-8">
        <div class="flex items-center gap-4 mb-4">
          <button class="btn btn-ghost btn-sm" on:click={handleBack}>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <h1 class="text-3xl font-bold text-base-content">{advogado.name}</h1>
        </div>
        <p class="text-base-content/70">Detalhes do advogado</p>
      </div>

      <!-- Content -->
      <div class="grid gap-6 max-w-4xl">
        <!-- Main Info Card -->
        <div class="card bg-base-100 shadow-lg">
          <div class="card-body">
            <div class="flex justify-between items-start mb-6">
              <h2 class="card-title text-2xl">Informações Pessoais</h2>
              <button class="btn btn-outline btn-sm" on:click={handleEdit}>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                Editar
              </button>
            </div>
            
            <div class="grid md:grid-cols-2 gap-6">
              <div>
                <h3 class="font-semibold text-base-content/80 mb-2">Nome Completo</h3>
                <p class="text-lg">{advogado.name}</p>
              </div>
              
              <div>
                <h3 class="font-semibold text-base-content/80 mb-2">OAB</h3>
                <p class="text-lg">{advogado.oab}</p>
              </div>
              
              <div>
                <h3 class="font-semibold text-base-content/80 mb-2">Email</h3>
                <p class="text-lg">{advogado.email}</p>
              </div>
              
              <div>
                <h3 class="font-semibold text-base-content/80 mb-2">Telefone</h3>
                <p class="text-lg">{advogado.telefone}</p>
              </div>
              
              <div class="md:col-span-2">
                <h3 class="font-semibold text-base-content/80 mb-2">Endereço</h3>
                <p class="text-lg">{advogado.endereco}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    {/if}
  </div>
</AuthSidebar>