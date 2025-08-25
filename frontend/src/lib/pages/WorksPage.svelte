<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import api from '../api/index';

  let works = [];
  let isLoading = false;
  let error = '';
  let success = '';

  // Form state
  let newWorkProcedure = 'administrative';
  let newWorkStatus = 'in_progress';
  let newWorkLawAreaId = '';
  let newWorkNumber = '';
  let newWorkFolder = '';
  let newWorkNote = '';
  let showNewWorkForm = false;

  // Edit state
  let editingWork = null;
  let editProcedure = 'administrative';
  let editStatus = 'in_progress';
  let editLawAreaId = '';
  let editNumber = '';
  let editFolder = '';
  let editNote = '';

  onMount(() => {
    loadWorks();
  });

  async function loadWorks() {
    isLoading = true;
    error = '';

    try {
      const result = await api.works.getWorks();

      if (result.success) {
        works = result.data || [];
        success = 'Trabalhos carregados com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao carregar trabalhos';
      }
    } catch (err) {
      // Error loading works
      error = 'Erro ao carregar trabalhos';
    } finally {
      isLoading = false;
    }
  }

  async function addWork() {
    if (!newWorkNumber || !newWorkFolder || !newWorkLawAreaId) {
      error = 'Número, pasta e área do direito são obrigatórios';
      return;
    }

    isLoading = true;
    error = '';

    try {
      const workData = {
        procedure: newWorkProcedure,
        status: newWorkStatus,
        law_area_id: parseInt(newWorkLawAreaId),
        number: parseInt(newWorkNumber),
        folder: newWorkFolder.trim(),
        note: newWorkNote.trim() || undefined
      };

      const result = await api.works.createWork(workData);

      if (result.success) {
        await loadWorks();
        success = 'Trabalho criado com sucesso';
        resetNewWorkForm();
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao criar trabalho';
      }
    } catch (err) {
      // Error creating work
      error = 'Erro ao criar trabalho';
    } finally {
      isLoading = false;
    }
  }

  async function updateWorkStatus(workId, newStatus) {
    isLoading = true;
    error = '';

    try {
      const result = await api.works.updateWork(workId, { status: newStatus });

      if (result.success) {
        await loadWorks();
        success = 'Status atualizado com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao atualizar status';
      }
    } catch (err) {
      // Error updating work status
      error = 'Erro ao atualizar status';
    } finally {
      isLoading = false;
    }
  }

  async function saveEditWork() {
    if (!editNumber || !editFolder || !editLawAreaId) {
      error = 'Número, pasta e área do direito são obrigatórios';
      return;
    }

    isLoading = true;
    error = '';

    try {
      const workData = {
        procedure: editProcedure,
        status: editStatus,
        law_area_id: parseInt(editLawAreaId),
        number: parseInt(editNumber),
        folder: editFolder.trim(),
        note: editNote.trim() || undefined
      };

      const result = await api.works.updateWork(editingWork.id, workData);

      if (result.success) {
        await loadWorks();
        success = 'Trabalho atualizado com sucesso';
        cancelEdit();
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao atualizar trabalho';
      }
    } catch (err) {
      // Error updating work
      error = 'Erro ao atualizar trabalho';
    } finally {
      isLoading = false;
    }
  }

  async function deleteWork(workId) {
    if (!window.confirm('Tem certeza que deseja excluir este trabalho?')) {
      return;
    }

    isLoading = true;
    error = '';

    try {
      const result = await api.works.deleteWork(workId);

      if (result.success) {
        await loadWorks();
        success = 'Trabalho excluído com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao excluir trabalho';
      }
    } catch (err) {
      // Error deleting work
      error = 'Erro ao excluir trabalho';
    } finally {
      isLoading = false;
    }
  }

  function startEdit(work) {
    editingWork = work;
    editProcedure = work.procedure;
    editStatus = work.status;
    editLawAreaId = work.law_area_id.toString();
    editNumber = work.number.toString();
    editFolder = work.folder;
    editNote = work.note || '';
  }

  function cancelEdit() {
    editingWork = null;
    editProcedure = 'administrative';
    editStatus = 'in_progress';
    editLawAreaId = '';
    editNumber = '';
    editFolder = '';
    editNote = '';
  }

  function resetNewWorkForm() {
    newWorkProcedure = 'administrative';
    newWorkStatus = 'in_progress';
    newWorkLawAreaId = '';
    newWorkNumber = '';
    newWorkFolder = '';
    newWorkNote = '';
    showNewWorkForm = false;
  }

  function getStatusBadge(status) {
    switch (status) {
    case 'completed':
      return 'badge-success';
    case 'in_progress':
      return 'badge-warning';
    case 'paused':
      return 'badge-info';
    case 'archived':
      return 'badge-neutral';
    default:
      return 'badge-ghost';
    }
  }

  function getStatusLabel(status) {
    switch (status) {
    case 'in_progress':
      return 'Em Andamento';
    case 'paused':
      return 'Pausado';
    case 'completed':
      return 'Concluído';
    case 'archived':
      return 'Arquivado';
    default:
      return status;
    }
  }

  function getProcedureLabel(procedure) {
    switch (procedure) {
    case 'administrative':
      return 'Administrativo';
    case 'judicial':
      return 'Judicial';
    case 'extrajudicial':
      return 'Extrajudicial';
    default:
      return procedure;
    }
  }
</script>

<AuthSidebar>
  <div class="container mx-auto py-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">📂 Trabalhos</h2>
          <button
            class="btn btn-primary"
            on:click={() => (showNewWorkForm = !showNewWorkForm)}
            disabled={isLoading}
          >
            + Novo Trabalho
          </button>
        </div>

        <!-- Messages -->
        {#if error}
          <div class="alert alert-error mb-4">
            <span>{error}</span>
          </div>
        {/if}

        {#if success}
          <div class="alert alert-success mb-4">
            <span>{success}</span>
          </div>
        {/if}

        <!-- New Work Form -->
        {#if showNewWorkForm}
          <div class="card bg-base-200 shadow mb-6">
            <div class="card-body">
              <h3 class="card-title">Novo Trabalho</h3>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label" for="work-number">
                    <span class="label-text">Número *</span>
                  </label>
                  <input
                    id="work-number"
                    type="number"
                    class="input input-bordered"
                    bind:value={newWorkNumber}
                    placeholder="Número do trabalho"
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label" for="work-folder">
                    <span class="label-text">Pasta *</span>
                  </label>
                  <input
                    id="work-folder"
                    type="text"
                    class="input input-bordered"
                    bind:value={newWorkFolder}
                    placeholder="Nome da pasta"
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label" for="work-procedure">
                    <span class="label-text">Procedimento</span>
                  </label>
                  <select
                    id="work-procedure"
                    class="select select-bordered"
                    bind:value={newWorkProcedure}
                    disabled={isLoading}
                  >
                    <option value="administrative">Administrativo</option>
                    <option value="judicial">Judicial</option>
                    <option value="extrajudicial">Extrajudicial</option>
                  </select>
                </div>

                <div class="form-control">
                  <label class="label" for="work-status">
                    <span class="label-text">Status</span>
                  </label>
                  <select
                    id="work-status"
                    class="select select-bordered"
                    bind:value={newWorkStatus}
                    disabled={isLoading}
                  >
                    <option value="in_progress">Em Andamento</option>
                    <option value="paused">Pausado</option>
                    <option value="completed">Concluído</option>
                    <option value="archived">Arquivado</option>
                  </select>
                </div>

                <div class="form-control">
                  <label class="label" for="work-law-area">
                    <span class="label-text">Área do Direito (ID) *</span>
                  </label>
                  <input
                    id="work-law-area"
                    type="number"
                    class="input input-bordered"
                    bind:value={newWorkLawAreaId}
                    placeholder="ID da área do direito"
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label" for="work-note">
                    <span class="label-text">Observações</span>
                  </label>
                  <textarea
                    id="work-note"
                    class="textarea textarea-bordered"
                    bind:value={newWorkNote}
                    placeholder="Observações do trabalho"
                    disabled={isLoading}
                  ></textarea>
                </div>
              </div>

              <div class="card-actions justify-end mt-4">
                <button class="btn btn-ghost" on:click={resetNewWorkForm} disabled={isLoading}>
                  Cancelar
                </button>
                <button
                  class="btn btn-primary"
                  class:loading={isLoading}
                  on:click={addWork}
                  disabled={isLoading}
                >
                  Criar Trabalho
                </button>
              </div>
            </div>
          </div>
        {/if}

        <!-- Loading -->
        {#if isLoading && works.length === 0}
          <div class="flex justify-center py-8">
            <span class="loading loading-spinner loading-lg"></span>
          </div>
        {/if}

        <!-- Works List -->
        {#if works.length > 0}
          <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Número</th>
                  <th>Pasta</th>
                  <th>Procedimento</th>
                  <th>Status</th>
                  <th>Área do Direito</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {#each works as work (work.id)}
                  <tr>
                    <td>{work.id}</td>
                    <td>
                      {#if editingWork && editingWork.id === work.id}
                        <input
                          type="number"
                          class="input input-sm input-bordered"
                          bind:value={editNumber}
                          disabled={isLoading}
                        />
                      {:else}
                        {work.number}
                      {/if}
                    </td>
                    <td>
                      {#if editingWork && editingWork.id === work.id}
                        <input
                          type="text"
                          class="input input-sm input-bordered"
                          bind:value={editFolder}
                          disabled={isLoading}
                        />
                      {:else}
                        <div>
                          <div class="font-semibold">{work.folder}</div>
                          {#if work.note}
                            <div class="text-sm opacity-70">{work.note}</div>
                          {/if}
                        </div>
                      {/if}
                    </td>
                    <td>
                      {#if editingWork && editingWork.id === work.id}
                        <select
                          class="select select-sm select-bordered"
                          bind:value={editProcedure}
                          disabled={isLoading}
                        >
                          <option value="administrative">Administrativo</option>
                          <option value="judicial">Judicial</option>
                          <option value="extrajudicial">Extrajudicial</option>
                        </select>
                      {:else}
                        {getProcedureLabel(work.procedure)}
                      {/if}
                    </td>
                    <td>
                      <select
                        class="select select-sm select-bordered"
                        value={work.status}
                        on:change={(e) => updateWorkStatus(work.id, e.target.value)}
                        disabled={isLoading}
                      >
                        <option value="in_progress">Em Andamento</option>
                        <option value="paused">Pausado</option>
                        <option value="completed">Concluído</option>
                        <option value="archived">Arquivado</option>
                      </select>
                    </td>
                    <td>
                      {#if editingWork && editingWork.id === work.id}
                        <input
                          type="number"
                          class="input input-sm input-bordered"
                          bind:value={editLawAreaId}
                          placeholder="Law Area ID"
                          disabled={isLoading}
                        />
                      {:else}
                        {work.law_area_id}
                      {/if}
                    </td>
                    <td>
                      {#if editingWork && editingWork.id === work.id}
                        <div class="flex gap-2">
                          <button
                            class="btn btn-sm btn-success"
                            on:click={saveEditWork}
                            disabled={isLoading}
                          >
                            Salvar
                          </button>
                          <button
                            class="btn btn-sm btn-ghost"
                            on:click={cancelEdit}
                            disabled={isLoading}
                          >
                            Cancelar
                          </button>
                        </div>
                      {:else}
                        <div class="flex gap-2">
                          <button
                            class="btn btn-sm btn-ghost"
                            on:click={() => startEdit(work)}
                            disabled={isLoading}
                          >
                            ✏️
                          </button>
                          <button
                            class="btn btn-sm btn-error"
                            on:click={() => deleteWork(work.id)}
                            disabled={isLoading}
                          >
                            🗑️
                          </button>
                        </div>
                      {/if}
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        {:else if !isLoading}
          <div class="text-center py-8">
            <p class="text-lg opacity-70">Nenhum trabalho encontrado</p>
            <p class="text-sm opacity-50">Clique em "Novo Trabalho" para começar</p>
          </div>
        {/if}

        <!-- Refresh Button -->
        <div class="card-actions justify-end mt-6">
          <button
            class="btn btn-outline"
            class:loading={isLoading}
            on:click={loadWorks}
            disabled={isLoading}
          >
            🔄 Atualizar
          </button>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
