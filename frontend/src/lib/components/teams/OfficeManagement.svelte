<script>
  import { onMount } from 'svelte';
  import api from '../../api';
  import OfficeForm from './OfficeForm.svelte';
  import OfficeList from './OfficeList.svelte';

  let offices = [];
  let loading = true;
  let error = null;
  let showForm = false;
  let editingOffice = null;
  let showDeleted = false;

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
      console.error('Error loading offices:', err);
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
    if (confirm(`Tem certeza que deseja ${office.deleted ? 'excluir permanentemente' : 'arquivar'} o escritório "${office.name}"?`)) {
      try {
        const response = await api.offices.deleteOffice(office.id, office.deleted);
        if (response.success) {
          loadOffices();
        } else {
          alert(response.message || 'Erro ao excluir escritório');
        }
      } catch (err) {
        alert(err.message || 'Erro ao excluir escritório');
      }
    }
  }

  async function handleRestore(office) {
    try {
      const response = await api.offices.restoreOffice(office.id);
      if (response.success) {
        loadOffices();
      } else {
        alert(response.message || 'Erro ao restaurar escritório');
      }
    } catch (err) {
      alert(err.message || 'Erro ao restaurar escritório');
    }
  }

  function toggleShowDeleted() {
    showDeleted = !showDeleted;
    loadOffices();
  }

  onMount(() => {
    loadOffices();
  });
</script>

<div class="p-6">
  {#if showForm}
    <OfficeForm
      office={editingOffice}
      on:close={handleCloseForm}
      on:success={handleFormSuccess}
    />
  {:else}
    <div class="mb-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-2xl font-bold text-gray-900">Gerenciar Escritórios</h2>
        <button
          class="btn btn-primary"
          on:click={handleCreate}
        >
          <span class="mr-2">➕</span>
          Novo Escritório
        </button>
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
    </div>

    {#if loading}
      <div class="flex items-center justify-center py-12">
        <span class="loading loading-spinner loading-lg text-primary"></span>
        <span class="ml-3 text-lg">Carregando escritórios...</span>
      </div>
    {:else if error}
      <div class="alert alert-error mb-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
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