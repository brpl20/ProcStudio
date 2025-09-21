<script>
  import { onMount } from 'svelte';
  import api from '../../api';
  import OfficeForm from './OfficeForm.svelte';
  import OfficeList from './OfficeList.svelte';
  import { lawyerStore } from '../../stores/lawyerStore.svelte';

  let offices = [];
  let loading = true;
  let error = null;
  let showForm = false;
  let editingOffice = null;
  let showDeleted = false;

  // Check for active lawyers
  $: hasActiveLawyers = lawyerStore.activeLawyers.length > 0;
  $: canCreateOffice = hasActiveLawyers;
  $: tooltipMessage = !hasActiveLawyers
    ? 'É necessário ter pelo menos um advogado ativo no sistema para criar um escritório'
    : '';

  // Debug logging
  $: {
    console.log('OfficeManagement - Debug:', {
      totalLawyers: lawyerStore.lawyers.length,
      activeLawyers: lawyerStore.activeLawyers.length,
      hasActiveLawyers,
      canCreateOffice,
      loading: lawyerStore.loading,
      initialized: lawyerStore.initialized
    });
    if (lawyerStore.lawyers.length > 0) {
      console.log('First lawyer:', lawyerStore.lawyers[0]);
    }
  }

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
    editingOffice = null;
    showForm = true;
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
  {#if showForm}
    <OfficeForm office={editingOffice} on:close={handleCloseForm} on:success={handleFormSuccess} />
  {:else}
    <div class="mb-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-2xl font-bold text-gray-900">Gerenciar Escritórios</h2>
        <div class="tooltip tooltip-left" data-tip={tooltipMessage}>
          <button
            class="btn btn-primary"
            class:btn-disabled={!canCreateOffice}
            disabled={!canCreateOffice}
            on:click={handleCreate}
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
              on:change={toggleShowDeleted}
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
        on:edit={(e) => handleEdit(e.detail)}
        on:delete={(e) => handleDelete(e.detail)}
        on:restore={(e) => handleRestore(e.detail)}
      />
    {/if}
  {/if}
</div>
