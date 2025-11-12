<script>
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

  // Check for active lawyers - using Svelte 5 runes
  let isStoreReady = $derived(lawyerStore.initialized);
  let hasActiveLawyers = $derived(lawyerStore.activeLawyers.length > 0);
  let canCreateOffice = $derived(isStoreReady && hasActiveLawyers);
  let tooltipMessage = $derived(
    !isStoreReady
      ? 'Carregando informações dos advogados...'
      : !hasActiveLawyers
        ? 'É necessário ter pelo menos um advogado ativo no sistema para criar um escritório'
        : ''
  );

  // Debug logging - using $effect for side effects
  $effect(() => {
    console.log('OfficeManagement - Debug:', {
      totalLawyers: lawyerStore.lawyers.length,
      activeLawyers: lawyerStore.activeLawyers.length,
      hasActiveLawyers,
      canCreateOffice,
      loading: lawyerStore.loading,
      initialized: lawyerStore.initialized,
      isStoreReady,
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
      // console.error('Error loading offices:', err);
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
      // Navigate to new office creation page
      window.location.href = '/lawyers-test?new_office=true';
    } else {
      // Navigate to existing office creation page
      window.location.href = '/lawyers-test?new_office=false';
    }
  }

  function handleCloseSelection() {
    console.log('handleCloseSelection called');
    showOfficeSelection = false;
  }

  // Debug function to reset all states
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
    // Initialize lawyer store to check for active lawyers
    lawyerStore.init();
    loadOffices();
  });
</script>

<div class="p-6">
  {#if showOfficeSelection}
    <!-- Office Selection Modal -->
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-8 max-w-2xl w-full mx-4">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold text-gray-900">Selecionar Tipo de Escritório</h2>
          <button class="btn btn-ghost btn-sm" onclick={handleCloseSelection}>✕</button>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Existing Office Option -->
          <div
            class="card bg-base-100 shadow-xl cursor-pointer hover:shadow-2xl transition-shadow"
            onclick={() => handleOfficeSelection(false)}
            onkeydown={(e) => e.key === 'Enter' && handleOfficeSelection(false)}
            tabindex="0"
            role="button"
          >
            <div class="card-body items-center text-center">
              <div class="text-4xl mb-4">🏢</div>
              <h3 class="card-title text-lg mb-2">Escritório Existente</h3>
              <p class="text-sm text-gray-600">
                Cadastre um escritório seu que já existe
              </p>
              <div class="card-actions justify-end mt-4">
                <button class="btn btn-primary">Selecionar</button>
              </div>
            </div>
          </div>

          <!-- New Office Option -->
          <div
            class="card bg-base-100 shadow-xl cursor-pointer hover:shadow-2xl transition-shadow"
            onclick={() => handleOfficeSelection(true)}
            onkeydown={(e) => e.key === 'Enter' && handleOfficeSelection(true)}
            tabindex="0"
            role="button"
          >
            <div class="card-body items-center text-center">
              <div class="text-4xl mb-4">✨</div>
              <h3 class="card-title text-lg mb-2">Novo Escritório</h3>
              <p class="text-sm text-gray-600">
                Utilize nosso sistema para ajudar a criação de um novo escritório
              </p>
              <div class="card-actions justify-end mt-4">
                <button class="btn btn-primary">Selecionar</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  {:else if showForm}
    <OfficeForm office={editingOffice} onClose={handleCloseForm} onSuccess={handleFormSuccess} />
  {:else}
    <div class="mb-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-2xl font-bold text-gray-900">Gerenciar Escritórios</h2>
        <div class="tooltip tooltip-left" data-tip={tooltipMessage}>
          <button
            class="btn btn-primary"
            class:btn-disabled={!canCreateOffice}
            disabled={!canCreateOffice}
            onclick={handleCreate}
          >
            <span class="mr-2">➕</span>
            Novo Escritório
          </button>
        </div>
      </div>

      <div class="flex items-center gap-4 mb-4">
        <div class="form-control">
          <label class="label cursor-pointer">
            <input
              type="checkbox"
              class="checkbox checkbox-primary"
              bind:checked={showDeleted}
              onchange={toggleShowDeleted}
            />
            <span class="label-text ml-2">Mostrar arquivados</span>
          </label>
        </div>
      </div>

      {#if !hasActiveLawyers}
        <div class="alert alert-warning">
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
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"
            />
          </svg>
          <div>
            <h3 class="font-bold">Atenção!</h3>
            <div class="text-sm">
              Não é possível criar um escritório sem advogados ativos no sistema. Por favor,
              cadastre e ative pelo menos um advogado antes de criar um escritório.
            </div>
          </div>
        </div>
      {/if}
    </div>

    {#if loading}
      <div class="flex items-center justify-center py-12">
        <span class="loading loading-spinner loading-lg text-primary"></span>
        <span class="ml-3 text-lg">Carregando escritórios...</span>
      </div>
    {:else if error}
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
    {:else}
      <OfficeList
        {offices}
        {showDeleted}
        onEdit={handleEdit}
        onDelete={handleDelete}
        onRestore={handleRestore}
      />
    {/if}
  {/if}
</div>
