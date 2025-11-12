<script lang="ts">
  import { onMount } from 'svelte';
  import api from '../../api';
  import OfficeForm from './OfficeForm.svelte';
  import OfficeList from './OfficeList.svelte';
  import { lawyerStore } from '../../stores/lawyerStore.svelte';

  let offices = $state([]);
  let loading = $state(true);
  let error = $state(null);
  let showForm = $state(false);
  let editingOffice = $state(null);
  let showDeleted = $state(false);
  let showOfficeSelection = $state(false);

  // Check for active lawyers - using $derived for better reactivity tracking
  let hasActiveLawyers = $derived(lawyerStore.activeLawyers.length > 0);
  let canCreateOffice = $derived(lawyerStore.initialized && hasActiveLawyers);
  let tooltipMessage = $derived(!hasActiveLawyers
    ? 'É necessário ter pelo menos um advogado ativo no sistema para criar um escritório'
    : '');

  // Debug logging using $effect in runes mode
  $effect(() => {
    console.log('OfficeManagement - Debug:', {
      totalLawyers: lawyerStore.lawyers.length,
      activeLawyers: lawyerStore.activeLawyers.length,
      hasActiveLawyers,
      canCreateOffice,
      loading: lawyerStore.loading,
      initialized: lawyerStore.initialized,
      showOfficeSelection,
      showForm
    });
    if (lawyerStore.lawyers.length > 0) {
      console.log('First lawyer:', lawyerStore.lawyers[0]);
    }
  });

  async function loadOffices() {
    try {
      loading = true;
      error = null;
      const response = await api.offices.getOffices({ deleted: showDeleted });
      if (response.success) {
        offices = response.data || [];
      } else {
        error = response.message || 'Erro ao carregar escritórios';
      }
    } catch (err) {
      error = err.message || 'Erro ao carregar escritórios';
    } finally {
      loading = false;
    }
  }

  function handleCreate() {
    console.log('handleCreate called - before:', { showOfficeSelection, showForm });
    editingOffice = null;
    showOfficeSelection = true;
    console.log('handleCreate called - after:', { showOfficeSelection, showForm });
  }

  function handleOfficeSelection(newOffice) {
    showOfficeSelection = false;
    if (newOffice) {
      window.location.href = '/lawyers-test?new_office=true';
    } else {
      window.location.href = '/lawyers-test?new_office=false';
    }
  }

  function handleCloseSelection() {
    console.log('handleCloseSelection called');
    showOfficeSelection = false;
  }

  function resetAllStates() {
    console.log('Resetting all states');
    showOfficeSelection = false;
    showForm = false;
    editingOffice = null;
  }

  function handleEdit(office) {
    editingOffice = office;
    showForm = true;
  }

  function handleCloseForm() {
    showForm = false;
    editingOffice = null;
  }

  function handleFormSuccess() {
    showForm = false;
    editingOffice = null;
    loadOffices();
  }

  async function handleDelete(office) {
    if (
      window.confirm(
        `Tem certeza que deseja ${office.deleted ? 'excluir permanentemente' : 'arquivar'} o escritório "${office.name}"?`
      )
    ) {
      try {
        const response = await api.offices.deleteOffice(office.id, office.deleted);
        if (response.success) {
          loadOffices();
        } else {
          window.alert(response.message || 'Erro ao excluir escritório');
        }
      } catch (err) {
        window.alert(err.message || 'Erro ao excluir escritório');
      }
    }
  }

  async function handleRestore(office) {
    try {
      const response = await api.offices.restoreOffice(office.id);
      if (response.success) {
        loadOffices();
      } else {
        window.alert(response.message || 'Erro ao restaurar escritório');
      }
    } catch (err) {
      window.alert(err.message || 'Erro ao restaurar escritório');
    }
  }

  function toggleShowDeleted() {
    showDeleted = !showDeleted;
    loadOffices();
  }

  onMount(() => {
    lawyerStore.init();
    loadOffices();
  });
</script>

<div class="w-full px-4 sm:px-6 lg:px-8 py-8 space-y-6">
  {#if showOfficeSelection}
    <!-- Office Selection Modal -->
    <div class="fixed inset-0 bg-[#01013D]/70 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-4xl mx-4 animate-in fade-in slide-in-from-bottom-4 duration-300">
        <div class="border-b border-[#eef0ef] px-8 py-6">
          <div class="flex justify-between items-center">
            <div>
              <h2 class="text-3xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent">
                Selecionar Tipo de Escritório
              </h2>
              <p class="text-gray-600 text-sm mt-1">Escolha como deseja cadastrar seu escritório</p>
            </div>
            <button 
              class="p-2 rounded-lg text-gray-400 hover:text-[#01013D] hover:bg-[#eef0ef] transition-all duration-200"
              on:click={handleCloseSelection}
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
        </div>

        <div class="p-8">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Existing Office Option -->
            <button
              class="group bg-white border-2 border-[#eef0ef] hover:border-[#0277EE] rounded-2xl p-8 transition-all duration-300 hover:shadow-xl hover:shadow-[#0277EE]/20 text-left"
              on:click={() => handleOfficeSelection(false)}
            >
              <div class="flex flex-col items-center text-center space-y-4">
                <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-[#0277EE]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-xl font-bold text-[#01013D] mb-2">Escritório Existente</h3>
                  <p class="text-sm text-gray-600">
                    Cadastre um escritório seu que já existe
                  </p>
                </div>
                <div class="w-full pt-4">
                  <div class="px-6 py-3 rounded-xl bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-semibold text-sm group-hover:shadow-lg group-hover:shadow-[#0277EE]/30 transition-all duration-300">
                    Selecionar
                  </div>
                </div>
              </div>
            </button>

            <!-- New Office Option -->
            <button
              class="group bg-white border-2 border-[#eef0ef] hover:border-[#0277EE] rounded-2xl p-8 transition-all duration-300 hover:shadow-xl hover:shadow-[#0277EE]/20 text-left"
              on:click={() => handleOfficeSelection(true)}
            >
              <div class="flex flex-col items-center text-center space-y-4">
                <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-[#0277EE]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-xl font-bold text-[#01013D] mb-2">Novo Escritório</h3>
                  <p class="text-sm text-gray-600">
                    Utilize nosso sistema para ajudar a criação de um novo escritório
                  </p>
                </div>
                <div class="w-full pt-4">
                  <div class="px-6 py-3 rounded-xl bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-semibold text-sm group-hover:shadow-lg group-hover:shadow-[#0277EE]/30 transition-all duration-300">
                    Selecionar
                  </div>
                </div>
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>
  {:else if showForm}
    <OfficeForm office={editingOffice} on:close={handleCloseForm} on:success={handleFormSuccess} />
  {:else}
    <!-- Header Section -->
    <div class="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-6">
      <div>
        <h2 class="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-[#01013D] to-[#01013D] bg-clip-text text-transparent mb-2">
          Gerenciar Escritórios
        </h2>
        <p class="text-gray-600 text-sm">Crie, edite e gerencie escritórios do sistema</p>
      </div>
      
      <button
        class="px-5 py-2.5 rounded-xl font-semibold bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white hover:shadow-lg hover:shadow-[#0277EE]/30 transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:shadow-none"
        class:opacity-50={!canCreateOffice}
        disabled={!canCreateOffice}
        on:click={handleCreate}
        title={tooltipMessage}
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
        </svg>
        Novo Escritório
      </button>
    </div>

    <!-- Filters -->
    <div class="flex items-center gap-4">
      <label class="flex items-center gap-3 cursor-pointer group">
        <div class="relative">
          <input
            type="checkbox"
            class="sr-only peer"
            bind:checked={showDeleted}
            on:change={toggleShowDeleted}
          />
          <div class="w-11 h-6 bg-gray-200 rounded-full peer-checked:bg-gradient-to-r peer-checked:from-[#0277EE] peer-checked:to-[#01013D] transition-all duration-300"></div>
          <div class="absolute left-1 top-1 w-4 h-4 bg-white rounded-full transition-transform duration-300 peer-checked:translate-x-5 shadow-md"></div>
        </div>
        <span class="text-sm font-medium text-gray-700 group-hover:text-[#0277EE] transition-colors duration-200">
          Mostrar arquivados
        </span>
      </label>
    </div>

    <!-- Warning Alert -->
    {#if !hasActiveLawyers}
      <div class="bg-yellow-50 border-l-4 border-yellow-500 rounded-lg p-4 flex items-start gap-3 animate-in fade-in slide-in-from-top-2 duration-300">
        <svg class="w-5 h-5 text-yellow-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
        </svg>
        <div>
          <p class="text-yellow-900 font-semibold text-sm">Atenção!</p>
          <p class="text-yellow-800 text-sm mt-1">
            Não é possível criar um escritório sem advogados ativos no sistema. Por favor,
            cadastre e ative pelo menos um advogado antes de criar um escritório.
          </p>
        </div>
      </div>
    {/if}

    <!-- Error Alert -->
    {#if error}
      <div class="bg-red-50 border-l-4 border-red-500 rounded-lg p-4 flex items-start gap-3 animate-in fade-in slide-in-from-top-2 duration-300">
        <svg class="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
        </svg>
        <div>
          <p class="text-red-900 font-semibold text-sm">Erro ao carregar</p>
          <p class="text-red-800 text-sm mt-1">{error}</p>
        </div>
      </div>
    {/if}

    <!-- Content Card -->
    <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] overflow-hidden">
      {#if loading}
        <div class="p-12 text-center">
          <div class="inline-flex items-center justify-center">
            <div class="w-12 h-12 border-4 border-[#eef0ef] border-t-[#0277EE] rounded-full animate-spin"></div>
          </div>
          <p class="mt-4 text-gray-600 font-medium">Carregando escritórios...</p>
        </div>
      {:else if offices.length === 0}
        <div class="p-12 text-center">
          <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 mb-4">
            <svg class="w-8 h-8 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
            </svg>
          </div>
          <p class="text-[#01013D] font-bold text-lg">Nenhum escritório encontrado</p>
          <p class="text-gray-500 text-sm mt-1">Crie um novo escritório para começar</p>
        </div>
      {:else}
        <OfficeList
          {offices}
          {showDeleted}
          onEdit={handleEdit}
          onDelete={handleDelete}
          onRestore={handleRestore}
        />
      {/if}
    </div>
  {/if}
</div>
