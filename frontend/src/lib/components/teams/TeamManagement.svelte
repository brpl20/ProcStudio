<script>
  import { createEventDispatcher } from 'svelte';
  import api from '../../api';
  import TeamMembers from './TeamMembers.svelte';

  export let myTeam = null;

  const dispatch = createEventDispatcher();

  let editMode = false;
  let loading = false;
  let error = null;
  let success = null;

  let formData = {
    name: '',
    description: '',
    subdomain: ''
  };

  $: if (myTeam && myTeam.name !== undefined) {
    formData = {
      name: myTeam.name || '',
      description: myTeam.description || '',
      subdomain: myTeam.subdomain || ''
    };
  }

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
        dispatch('teamUpdated');

        setTimeout(() => {
          success = null;
        }, 3000);
      } else {
        error = response.message || 'Erro ao atualizar equipe';
      }
    } catch (err) {
      error = err.message || 'Erro ao atualizar equipe';
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

<div class="w-full px-4 sm:px-6 lg:px-8 py-8 space-y-8">
  <!-- Header Section -->
  <div class="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-6">
    <div class="flex-1">
      <h2 class="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent mb-2">
        Informações da Equipe
      </h2>
      <p class="text-gray-600 text-sm sm:text-base">Configure os detalhes principais da sua equipe</p>
    </div>
    <button
      class={`px-6 py-2.5 rounded-xl font-semibold transition-all duration-300 whitespace-nowrap {
        editMode
          ? 'bg-gray-100 text-[#01013D] hover:bg-gray-200'
          : 'bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white hover:shadow-lg hover:shadow-[#0277EE]/30'
      }`}
      on:click={toggleEdit}
      disabled={loading}
    >
      {editMode ? 'Cancelar' : 'Editar'}
    </button>
  </div>

  <!-- Success Alert -->
  {#if success}
    <div class="bg-green-50 border-l-4 border-green-500 rounded-lg p-4 flex items-start gap-3 animate-in fade-in slide-in-from-top-2 duration-300">
      <svg class="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
      </svg>
      <div>
        <p class="text-green-900 font-semibold text-sm">{success}</p>
      </div>
    </div>
  {/if}

  <!-- Error Alert -->
  {#if error}
    <div class="bg-red-50 border-l-4 border-red-500 rounded-lg p-4 flex items-start gap-3 animate-in fade-in slide-in-from-top-2 duration-300">
      <svg class="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
      </svg>
      <div>
        <p class="text-red-900 font-semibold text-sm">Erro ao atualizar</p>
        <p class="text-red-800 text-sm mt-1">{error}</p>
      </div>
    </div>
  {/if}

  {#if myTeam}
    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Team Information Form -->
      <div class="lg:col-span-2">
        <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] overflow-hidden">
          <div class="p-6 sm:p-8">
            <h3 class="text-xl sm:text-2xl font-bold text-[#01013D] mb-8">Dados da Equipe</h3>

            <form on:submit|preventDefault={handleSave} class="space-y-6">
              <div>
                <label class="block text-sm font-semibold text-[#01013D] mb-3" for="team-name">
                  Nome da Equipe
                </label>
                <input
                  id="team-name"
                  type="text"
                  bind:value={formData.name}
                  class="w-full px-4 py-3 rounded-xl border border-[#eef0ef] bg-white text-[#01013D] placeholder-gray-400 transition-all duration-300 focus:border-[#0277EE] focus:ring-2 focus:ring-[#0277EE]/20 focus:outline-none disabled:bg-gray-50 disabled:text-gray-500 hover:border-[#0277EE]/30"
                  disabled={!editMode || loading}
                  required
                />
              </div>

              <div>
                <label class="block text-sm font-semibold text-[#01013D] mb-3" for="team-description">
                  Descrição
                </label>
                <textarea
                  id="team-description"
                  bind:value={formData.description}
                  class="w-full px-4 py-3 rounded-xl border border-[#eef0ef] bg-white text-[#01013D] placeholder-gray-400 transition-all duration-300 focus:border-[#0277EE] focus:ring-2 focus:ring-[#0277EE]/20 focus:outline-none disabled:bg-gray-50 disabled:text-gray-500 hover:border-[#0277EE]/30 resize-none"
                  rows="4"
                  disabled={!editMode || loading}
                  placeholder="Descrição detalhada da sua equipe..."
                ></textarea>
              </div>

              <div>
                <label class="block text-sm font-semibold text-[#01013D] mb-3" for="team-subdomain">
                  Subdomínio
                </label>
                <input
                  id="team-subdomain"
                  type="text"
                  bind:value={formData.subdomain}
                  class="w-full px-4 py-3 rounded-xl border border-[#eef0ef] bg-white text-[#01013D] placeholder-gray-400 transition-all duration-300 focus:border-[#0277EE] focus:ring-2 focus:ring-[#0277EE]/20 focus:outline-none disabled:bg-gray-50 disabled:text-gray-500 hover:border-[#0277EE]/30"
                  disabled={!editMode || loading}
                  placeholder="meuescritorio"
                />
                {#if formData.subdomain}
                  <div class="mt-3 p-4 bg-gradient-to-r from-[#0277EE]/5 to-[#01013D]/5 rounded-xl border border-[#0277EE]/20">
                    <p class="text-sm text-[#01013D] font-semibold">
                      URL: <span class="font-mono text-[#0277EE]">{formData.subdomain}.procstudio.com</span>
                    </p>
                  </div>
                {/if}
              </div>

              {#if editMode}
                <div class="flex flex-col sm:flex-row gap-3 justify-end pt-6 border-t border-[#eef0ef]">
                  <button
                    type="button"
                    class="px-6 py-3 rounded-xl font-semibold text-[#01013D] bg-gray-100 hover:bg-gray-200 transition-colors duration-300 disabled:opacity-50 disabled:cursor-not-allowed order-2 sm:order-1"
                    on:click={handleCancel}
                    disabled={loading}
                  >
                    Cancelar
                  </button>
                  <button
                    type="submit"
                    class="px-6 py-3 rounded-xl font-semibold bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white hover:shadow-lg hover:shadow-[#0277EE]/30 transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed order-1 sm:order-2"
                    disabled={loading}
                  >
                    {#if loading}
                      <div class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    {/if}
                    Salvar Alterações
                  </button>
                </div>
              {/if}
            </form>
          </div>
        </div>
      </div>

      <!-- Team Status Card -->
      <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] overflow-hidden">
        <div class="p-6 sm:p-8">
          <h3 class="text-xl sm:text-2xl font-bold text-[#01013D] mb-8">Status da Equipe</h3>

          <div class="space-y-6">
            <div class="pb-6 border-b border-[#eef0ef]">
              <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">Status</p>
              <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-green-100/80 border border-green-300">
                <div class="w-2 h-2 rounded-full bg-green-600"></div>
                <span class="text-green-900 font-bold text-sm">{myTeam.status || 'Ativa'}</span>
              </div>
            </div>

            <div class="pb-6 border-b border-[#eef0ef]">
              <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">Criado em</p>
              <p class="text-base text-[#01013D] font-bold">
                {new Date(myTeam.created_at).toLocaleDateString('pt-BR', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric'
                })}
              </p>
            </div>

            <div class="pb-6 border-b border-[#eef0ef]">
              <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">Última atualização</p>
              <p class="text-base text-[#01013D] font-bold">
                {new Date(myTeam.updated_at || myTeam.created_at).toLocaleDateString('pt-BR', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric'
                })}
              </p>
            </div>

            <div>
              <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">ID da Equipe</p>
              <div class="p-3 bg-gradient-to-br from-[#eef0ef]/50 to-white rounded-xl border border-[#eef0ef] overflow-hidden">
                <p class="font-mono text-xs text-[#01013D] break-all font-semibold">
                  {myTeam.id}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Team Members Section -->
    <div>
      <TeamMembers teamId={myTeam.id} />
    </div>
  {:else}
    <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] p-8 sm:p-12 text-center">
      <div class="inline-flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 mb-4">
        <svg class="w-10 h-10 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 8.048M7 14H5a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2h-2m-1-7a4 4 0 11-8 0 4 4 0 018 0z"></path>
        </svg>
      </div>
      <p class="text-[#01013D] text-lg font-bold mb-2">Nenhuma equipe encontrada</p>
      <p class="text-gray-500 text-sm">Suas equipes aparecerão aqui</p>
    </div>
  {/if}
</div>

<style>
  :global(input:focus, textarea:focus) {
    --tw-ring-color: rgba(2, 119, 238, 0.1);
  }
</style>
