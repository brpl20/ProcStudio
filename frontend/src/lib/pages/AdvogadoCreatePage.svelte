<script lang="ts">
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import { router } from '../stores/routerStore.js';

  let advogadoName = '';
  let isLoading = false;

  async function handleSubmit() {
    if (!advogadoName.trim()) {
      alert('Nome é obrigatório');
      return;
    }

    isLoading = true;
    
    try {
      // TODO: Implement API call to create advogado
      console.log('Creating advogado:', { name: advogadoName.trim() });
      
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Navigate back to teams page
      router.navigate('/teams');
    } catch (error: any) {
      console.error('Error creating advogado:', error);
      alert('Erro ao criar advogado');
    } finally {
      isLoading = false;
    }
  }

  function handleCancel() {
    router.navigate('/teams');
  }
</script>

<svelte:head>
  <title>Novo Advogado</title>
</svelte:head>

<AuthSidebar>
  <div class="container mx-auto px-4 py-6">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center gap-4 mb-4">
        <button class="btn btn-ghost btn-sm" on:click={handleCancel}>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <h1 class="text-3xl font-bold text-base-content">Novo Advogado</h1>
      </div>
      <p class="text-base-content/70">Cadastre um novo advogado no sistema</p>
    </div>

    <!-- Form -->
    <div class="card bg-base-100 shadow-lg max-w-2xl">
      <div class="card-body">
        <form on:submit|preventDefault={handleSubmit}>
          <!-- Name Field -->
          <div class="form-control mb-6">
            <label class="label" for="advogado-name">
              <span class="label-text font-medium">Nome *</span>
            </label>
            <input 
              type="text" 
              id="advogado-name"
              class="input input-bordered w-full" 
              placeholder="Digite o nome do advogado"
              bind:value={advogadoName}
              disabled={isLoading}
              required
            />
          </div>

          <!-- Action Buttons -->
          <div class="card-actions justify-end gap-4">
            <button 
              type="button" 
              class="btn btn-ghost" 
              on:click={handleCancel}
              disabled={isLoading}
            >
              Cancelar
            </button>
            <button 
              type="submit" 
              class="btn btn-primary" 
              disabled={isLoading || !advogadoName.trim()}
            >
              {#if isLoading}
                <span class="loading loading-spinner loading-sm"></span>
                Salvando...
              {:else}
                Salvar Advogado
              {/if}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</AuthSidebar>