<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import AvatarUpload from '../components/ui/AvatarUpload.svelte';
  import api from '../api/index';
  import type { WhoAmIResponse } from '../api/types';

  let loading = $state(true);
  let error = $state(null);
  let currentUserData = $state<WhoAmIResponse | null>(null);
  let uploadingAvatar = $state(false);
  let showAvatarEditor = $state(false);
  let successMessage = $state('');

  let whoAmIUser = $derived(currentUserData?.data);
  let userProfile = $derived(whoAmIUser?.attributes?.profile);
  let userTeam = $derived(whoAmIUser?.attributes?.team);
  let userOffices = $derived(whoAmIUser?.attributes?.offices || []);
  let userPhones = $derived(whoAmIUser?.attributes?.phones || []);
  let userAddresses = $derived(whoAmIUser?.attributes?.addresses || []);

  onMount(async () => {
    try {
      currentUserData = await api.users.whoami();
      loading = false;
    } catch (err) {
      error = err;
      loading = false;
    }
  });

  async function handleAvatarUpload(event: CustomEvent) {
    const { file } = event.detail;
    if (!userProfile?.id) {
return;
}

    uploadingAvatar = true;
    error = null;
    successMessage = '';

    try {
      await api.users.uploadAvatar(String(userProfile.id), file);
      currentUserData = await api.users.whoami();
      successMessage = 'Foto do perfil atualizada com sucesso!';
      showAvatarEditor = false;
      setTimeout(() => successMessage = '', 3000);
    } catch (err) {
      error = err.message || 'Erro ao fazer upload da foto';
    } finally {
      uploadingAvatar = false;
    }
  }

  async function handleAvatarRemove() {
    if (!userProfile?.id) {
return;
}

    uploadingAvatar = true;
    error = null;
    successMessage = '';

    try {
      await api.users.removeAvatar(String(userProfile.id));
      currentUserData = await api.users.whoami();
      successMessage = 'Foto removida com sucesso!';
      setTimeout(() => successMessage = '', 3000);
    } catch (err) {
      error = err.message || 'Erro ao remover a foto';
    } finally {
      uploadingAvatar = false;
    }
  }

  async function handleColorChange(event: CustomEvent) {
    const { color } = event.detail;
    if (!userProfile?.id) {
return;
}

    uploadingAvatar = true;
    error = null;

    try {
      await api.users.updateAvatarColor(String(userProfile.id), color);
      currentUserData = await api.users.whoami();
      successMessage = 'Cor do avatar atualizada com sucesso!';
      setTimeout(() => successMessage = '', 3000);
    } catch (err) {
      error = err.message || 'Erro ao atualizar cor do avatar';
    } finally {
      uploadingAvatar = false;
    }
  }
</script>

<AuthSidebar activeSection="user-config">
  <div class="min-h-screen bg-gradient-to-br from-[#eef0ef] to-white p-4 md:p-8">
    <div class="max-w-7xl mx-auto">

      {#if loading}
        <div class="flex items-center justify-center min-h-[400px]">
          <div class="flex flex-col items-center gap-4">
            <div class="w-16 h-16 border-4 border-[#0277EE] border-t-transparent rounded-full animate-spin"></div>
            <p class="text-[#01013D] font-medium">Carregando perfil...</p>
          </div>
        </div>
      {:else if error}
        <div class="bg-red-50 border-l-4 border-red-500 p-6 rounded-lg shadow-sm">
          <div class="flex items-center gap-3">
            <svg class="w-6 h-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span class="text-red-800 font-medium">Erro ao carregar dados: {error.message || error}</span>
          </div>
        </div>
      {:else if userProfile}
        <div class="space-y-6">

          {#if successMessage}
            <div class="bg-green-50 border-l-4 border-green-500 p-6 rounded-lg shadow-sm animate-[fadeIn_0.3s_ease-in]">
              <div class="flex items-center gap-3">
                <svg class="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="text-green-800 font-medium">{successMessage}</span>
              </div>
            </div>
          {/if}

          <div class="bg-gradient-to-br from-[#01013D] to-[#0277EE] rounded-2xl shadow-2xl overflow-hidden">
            <div class="p-8 md:p-12">
              <div class="flex flex-col md:flex-row items-center gap-8">
                <div class="relative group">
                  <div class="w-32 h-32 rounded-full overflow-hidden ring-4 ring-white shadow-xl transition-transform duration-300 group-hover:scale-105">
                    {#if userProfile.avatar_url}
                      <img src={userProfile.avatar_url} alt={userProfile.full_name} class="w-full h-full object-cover" />
                    {:else}
                      <div class="w-full h-full bg-[#0277EE] flex items-center justify-center">
                        <span class="text-6xl font-bold text-white">{userProfile.name?.charAt(0).toUpperCase() || '?'}</span>
                      </div>
                    {/if}
                  </div>
                  <button
                    onclick={() => showAvatarEditor = true}
                    class="absolute bottom-0 right-0 bg-white text-[#0277EE] rounded-full p-3 shadow-lg hover:bg-[#eef0ef] transition-all duration-300 hover:scale-110"
                  >
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                  </button>
                </div>

                <div class="flex-1 text-center md:text-left">
                  <h1 class="text-4xl md:text-5xl font-bold text-white mb-2">{userProfile.full_name}</h1>
                  <p class="text-xl text-[#eef0ef] mb-4">
                    {userProfile.role === 'lawyer' ? (userProfile.gender === 'female' ? 'Advogada' : 'Advogado') : userProfile.role}
                  </p>
                  <div class="flex flex-wrap gap-4 justify-center md:justify-start text-[#eef0ef]">
                    <div class="flex items-center gap-2">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                      </svg>
                      <span>{whoAmIUser?.attributes?.email}</span>
                    </div>
                    <div class="flex items-center gap-2">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                      </svg>
                      <span>OAB: {userProfile.oab}</span>
                    </div>
                  </div>
                </div>

                <div class="grid grid-cols-2 gap-6">
                  <div class="bg-white/10 backdrop-blur-sm rounded-xl p-6 text-center border border-white/20">
                    <div class="text-3xl font-bold text-white mb-1">{whoAmIUser?.attributes?.works_count || 0}</div>
                    <div class="text-sm text-[#eef0ef]">Trabalhos</div>
                  </div>
                  <div class="bg-white/10 backdrop-blur-sm rounded-xl p-6 text-center border border-white/20">
                    <div class="text-3xl font-bold text-white mb-1">{whoAmIUser?.attributes?.jobs_count || 0}</div>
                    <div class="text-sm text-[#eef0ef]">Jobs</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 hover:shadow-xl transition-shadow duration-300">
              <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                <h2 class="text-xl font-bold text-white flex items-center gap-2">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                  Informações Pessoais
                </h2>
              </div>
              <div class="p-6 space-y-4">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nome Completo</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.full_name}</div>
                  </div>
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">CPF</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.cpf}</div>
                  </div>
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">RG</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.rg}</div>
                  </div>
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nascimento</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.birth}</div>
                  </div>
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nacionalidade</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.nationality}</div>
                  </div>
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Estado Civil</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.civil_status}</div>
                  </div>
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Gênero</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.gender === 'female' ? 'Feminino' : 'Masculino'}</div>
                  </div>
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Status</label>
                    <div class="inline-flex items-center bg-green-100 text-green-800 px-4 py-3 rounded-lg font-semibold">
                      <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                      {userProfile.status}
                    </div>
                  </div>
                </div>
                {#if userProfile.mother_name}
                  <div class="pt-2">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nome da Mãe</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.mother_name}</div>
                  </div>
                {/if}
              </div>
            </div>

            {#if userTeam}
              <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 hover:shadow-xl transition-shadow duration-300">
                <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                  <h2 class="text-xl font-bold text-white flex items-center gap-2">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                    Equipe
                  </h2>
                </div>
                <div class="p-6 space-y-4">
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nome da Equipe</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userTeam.name}</div>
                  </div>
                  <div class="group">
                    <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Subdomínio</label>
                    <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userTeam.subdomain}</div>
                  </div>
                </div>
              </div>
            {/if}
          </div>

          {#if userOffices.length > 0}
            <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 hover:shadow-xl transition-shadow duration-300">
              <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                <h2 class="text-xl font-bold text-white flex items-center gap-2">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                  </svg>
                  Escritórios
                </h2>
              </div>
              <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
                {#each userOffices as office}
                  <div class="bg-gradient-to-br from-[#eef0ef] to-white p-6 rounded-xl border border-gray-200 hover:border-[#0277EE] transition-all duration-300">
                    <h3 class="text-lg font-bold text-[#01013D] mb-3">{office.name}</h3>
                    <div class="space-y-2 text-sm">
                      <div class="flex items-center gap-2 text-gray-600">
                        <span class="font-semibold">CNPJ:</span>
                        <span>{office.cnpj}</span>
                      </div>
                      <div class="flex items-center gap-2 text-gray-600">
                        <span class="font-semibold">Sociedade:</span>
                        <span>{office.partnership_type}</span>
                      </div>
                      <div class="flex items-center gap-2 text-gray-600">
                        <span class="font-semibold">Participação:</span>
                        <span class="text-[#0277EE] font-bold">{office.partnership_percentage}%</span>
                      </div>
                    </div>
                  </div>
                {/each}
              </div>
            </div>
          {/if}

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {#if userPhones.length > 0}
              <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 hover:shadow-xl transition-shadow duration-300">
                <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                  <h2 class="text-xl font-bold text-white flex items-center gap-2">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                    Telefones
                  </h2>
                </div>
                <div class="p-6 space-y-3">
                  {#each userPhones as phone}
                    <div class="flex items-center justify-between bg-[#eef0ef] px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors duration-200">
                      <span class="font-medium text-[#01013D]">{phone.phone_number}</span>
                      {#if phone.phone_type}
                        <span class="text-xs bg-[#0277EE] text-white px-3 py-1 rounded-full font-semibold">{phone.phone_type}</span>
                      {/if}
                    </div>
                  {/each}
                </div>
              </div>
            {/if}

            {#if userAddresses.length > 0}
              <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 hover:shadow-xl transition-shadow duration-300">
                <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                  <h2 class="text-xl font-bold text-white flex items-center gap-2">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    Endereços
                  </h2>
                </div>
                <div class="p-6 space-y-4">
                  {#each userAddresses as address}
                    <div class="bg-gradient-to-br from-[#eef0ef] to-white p-4 rounded-xl border border-gray-200 hover:border-[#0277EE] transition-all duration-300">
                      <div class="space-y-1 text-sm text-gray-700">
                        <p class="font-semibold text-[#01013D]">{address.street}, {address.number}</p>
                        {#if address.complement}
                          <p class="text-gray-600">{address.complement}</p>
                        {/if}
                        <p>{address.neighborhood}</p>
                        <p>{address.city} - {address.state}</p>
                        <p class="font-medium">CEP: {address.zip_code}</p>
                        {#if address.address_type}
                          <div class="pt-2">
                            <span class="inline-block text-xs bg-[#0277EE] text-white px-3 py-1 rounded-full font-semibold">{address.address_type}</span>
                          </div>
                        {/if}
                      </div>
                    </div>
                  {/each}
                </div>
              </div>
            {/if}
          </div>

          <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100">
            <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
              <h2 class="text-xl font-bold text-white flex items-center gap-2">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                Ações Rápidas
              </h2>
            </div>
            <div class="p-6">
              <div class="flex flex-wrap gap-4">
                <button
                  onclick={() => showAvatarEditor = true}
                  class="flex items-center gap-2 bg-[#0277EE] hover:bg-[#01013D] text-white px-6 py-3 rounded-lg font-semibold transition-all duration-300 shadow-md hover:shadow-xl transform hover:-translate-y-0.5"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  Alterar Foto
                </button>
                <button
                  disabled
                  class="flex items-center gap-2 bg-gray-300 text-gray-500 px-6 py-3 rounded-lg font-semibold cursor-not-allowed opacity-60"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                  </svg>
                  Editar Perfil
                  <span class="text-xs bg-white px-2 py-1 rounded-full">Em breve</span>
                </button>
                <button
                  disabled
                  class="flex items-center gap-2 bg-gray-300 text-gray-500 px-6 py-3 rounded-lg font-semibold cursor-not-allowed opacity-60"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                  Alterar Senha
                  <span class="text-xs bg-white px-2 py-1 rounded-full">Em breve</span>
                </button>
              </div>
            </div>
          </div>

        </div>
      {:else}
        <div class="bg-yellow-50 border-l-4 border-yellow-500 p-6 rounded-lg shadow-sm">
          <div class="flex items-center gap-3">
            <svg class="w-6 h-6 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <span class="text-yellow-800 font-medium">Nenhum dado de usuário encontrado</span>
          </div>
        </div>
      {/if}
    </div>
  </div>

  {#if showAvatarEditor}
    <div class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-[fadeIn_0.2s_ease-in]">
      <div class="bg-white rounded-2xl shadow-2xl max-w-3xl w-full max-h-[90vh] overflow-auto animate-[slideUp_0.3s_ease-out]">
        <div class="sticky top-0 bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4 flex items-center justify-between">
          <h3 class="text-2xl font-bold text-white">Editar Foto do Perfil</h3>
          <button
            onclick={() => showAvatarEditor = false}
            class="text-white hover:bg-white/20 rounded-full p-2 transition-colors duration-200"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div class="p-6">
          <AvatarUpload
            currentAvatarUrl={userProfile?.avatar_url}
            userName={userProfile?.name || ''}
            loading={uploadingAvatar}
            on:upload={handleAvatarUpload}
            on:remove={handleAvatarRemove}
            on:colorChange={handleColorChange}
            on:error={(e) => error = e.detail.message}
          />
        </div>

        <div class="sticky bottom-0 bg-gray-50 px-6 py-4 flex justify-end gap-3 border-t">
          <button
            onclick={() => showAvatarEditor = false}
            class="px-6 py-3 bg-gray-200 hover:bg-gray-300 text-gray-700 font-semibold rounded-lg transition-colors duration-200"
          >
            Fechar
          </button>
        </div>
      </div>
    </div>
  {/if}
</AuthSidebar>

<style>
  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  @keyframes slideUp {
    from {
      transform: translateY(20px);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }
</style>
