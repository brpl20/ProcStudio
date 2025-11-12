<script>
  import api from '../../api';
  import TeamMembers from './TeamMembers.svelte';

  let {
    myTeam = null,
    onTeamUpdated = () => {}
  } = $props();

  let editMode = $state(false);
  let loading = $state(false);
  let error = $state(null);
  let success = $state(null);

  // Form data
  let formData = $state({
    name: '',
    description: '',
    subdomain: ''
  });

  // Initialize form data when myTeam changes
  $effect(() => {
    if (myTeam && myTeam.name !== undefined) {
      formData = {
        name: myTeam.name || '',
        description: myTeam.description || '',
        subdomain: myTeam.subdomain || ''
      };
    }
  });

  async function handleSave() {
    if (!myTeam) {
      return;
    }

    try {
      loading = true;
      error = null;

      const updateData = {
        team: {
          name: formData.name,
          description: formData.description,
          subdomain: formData.subdomain
        }
      };

      const response = await api.teams.updateMyTeam(updateData);

      if (response.success) {
        success = 'Equipe atualizada com sucesso!';
        editMode = false;
        onTeamUpdated();

        // Clear success message after 3 seconds
        setTimeout(() => {
          success = null;
        }, 3000);
      } else {
        error = response.message || 'Erro ao atualizar equipe';
      }
    } catch (err) {
      error = err.message || 'Erro ao atualizar equipe';
      // console.error('Error updating team:', err);
    } finally {
      loading = false;
    }
  }

  function handleCancel() {
    if (myTeam && myTeam.name !== undefined) {
      formData = {
        name: myTeam.name || '',
        description: myTeam.description || '',
        subdomain: myTeam.subdomain || ''
      };
    }
    editMode = false;
    error = null;
  }

  function toggleEdit() {
    editMode = !editMode;
    if (!editMode) {
      handleCancel();
    }
  }
</script>

<div class="p-6">
  <div class="flex justify-between items-center mb-6">
    <h2 class="text-2xl font-semibold text-gray-800">Informações da Equipe</h2>
    <button class="btn btn-primary btn-sm" onclick={toggleEdit} disabled={loading}>
      {editMode ? 'Cancelar' : 'Editar'}
    </button>
  </div>

  <!-- Success Alert -->
  {#if success}
    <div class="alert alert-success mb-4">
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
          d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
        />
      </svg>
      <span>{success}</span>
    </div>
  {/if}

  <!-- Error Alert -->
  {#if error}
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
  {/if}

  {#if myTeam}
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <!-- Team Information Form -->
      <div class="card bg-base-100 border border-base-300">
        <div class="card-body">
          <h3 class="card-title text-lg mb-4">Dados da Equipe</h3>

          <form onsubmit={(e) => { e.preventDefault(); handleSave(e); }}>
            <div class="form-control mb-4">
              <label class="label" for="team-name">
                <span class="label-text font-medium">Nome da Equipe</span>
              </label>
              <input
                id="team-name"
                type="text"
                bind:value={formData.name}
                class="input input-bordered w-full"
                disabled={!editMode || loading}
                required
              />
            </div>

            <div class="form-control mb-4">
              <label class="label" for="team-description">
                <span class="label-text font-medium">Descrição</span>
              </label>
              <textarea
                id="team-description"
                bind:value={formData.description}
                class="textarea textarea-bordered w-full"
                rows="3"
                disabled={!editMode || loading}
                placeholder="Descrição da equipe..."
              ></textarea>
            </div>

            <div class="form-control mb-6">
              <label class="label" for="team-subdomain">
                <span class="label-text font-medium">Subdomínio</span>
              </label>
              <input
                id="team-subdomain"
                type="text"
                bind:value={formData.subdomain}
                class="input input-bordered w-full"
                disabled={!editMode || loading}
                placeholder="meuescritorio"
              />
              {#if formData.subdomain}
                <div class="label">
                  <span class="label-text-alt text-info">
                    URL: {formData.subdomain}.procstudio.com
                  </span>
                </div>
              {/if}
            </div>

            {#if editMode}
              <div class="card-actions justify-end">
                <button
                  type="button"
                  class="btn btn-ghost"
                  onclick={handleCancel}
                  disabled={loading}
                >
                  Cancelar
                </button>
                <button type="submit" class="btn btn-primary" disabled={loading}>
                  {#if loading}
                    <span class="loading loading-spinner loading-sm"></span>
                  {/if}
                  Salvar
                </button>
              </div>
            {/if}
          </form>
        </div>
      </div>

      <!-- Team Status and Info -->
      <div class="card bg-base-100 border border-base-300">
        <div class="card-body">
          <h3 class="card-title text-lg mb-4">Status da Equipe</h3>

          <div class="space-y-4">
            <div class="flex justify-between items-center">
              <span class="text-sm font-medium text-gray-600">Status:</span>
              <div class="badge badge-success">
                {myTeam.status || 'active'}
              </div>
            </div>

            <div class="flex justify-between items-center">
              <span class="text-sm font-medium text-gray-600">Criado em:</span>
              <span class="text-sm">
                {new Date(myTeam.created_at).toLocaleDateString('pt-BR')}
              </span>
            </div>

            <div class="flex justify-between items-center">
              <span class="text-sm font-medium text-gray-600">Última atualização:</span>
              <span class="text-sm">
                {new Date(myTeam.updated_at || myTeam.created_at).toLocaleDateString('pt-BR')}
              </span>
            </div>

            <div class="flex justify-between items-center">
              <span class="text-sm font-medium text-gray-600">ID da Equipe:</span>
              <span class="text-sm font-mono">#{myTeam.id}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Team Members Section -->
    <div class="mt-8">
      <TeamMembers teamId={myTeam.id} />
    </div>
  {:else}
    <div class="text-center py-8">
      <p class="text-gray-500">Nenhuma equipe encontrada</p>
    </div>
  {/if}
</div>
