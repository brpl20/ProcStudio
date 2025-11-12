<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import AvatarUpload from '../components/ui/AvatarUpload.svelte';
  import api from '../api/index';
  import type { WhoAmIResponse } from '../api/types';

  // Display data
  let loading = true;
  let error = null;
  let currentUserData: WhoAmIResponse | null = null;
  let uploadingAvatar = false;
  let showAvatarEditor = false;
  let successMessage = '';

  // Derived data from whoami
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
      // Refresh user data
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
      // Refresh user data
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
      // Refresh user data
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
  <div class="container mx-auto space-y-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title text-3xl mb-6">Meu Perfil</h2>

        {#if loading}
          <div class="flex justify-center p-8">
            <span class="loading loading-spinner loading-lg"></span>
          </div>
        {:else if error}
          <div class="alert alert-error">
            <span>Erro ao carregar dados do usuário: {error.message || error}</span>
          </div>
        {:else if userProfile}
          <div class="space-y-6">

            <!-- Success/Error Messages -->
            {#if successMessage}
              <div class="alert alert-success">
                <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>{successMessage}</span>
              </div>
            {/if}

            {#if error && !loading}
              <div class="alert alert-error">
                <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>{error}</span>
              </div>
            {/if}

            <!-- Profile Header with Avatar -->
            <div class="flex items-center gap-6 p-6 bg-base-200 rounded-lg">
              <div class="avatar">
                <div class="w-24 rounded-full ring ring-primary ring-offset-base-100 ring-offset-2">
                  {#if userProfile.avatar_url}
                    <img src={userProfile.avatar_url} alt={userProfile.full_name} />
                  {:else}
                    <div class="bg-neutral text-neutral-content rounded-full w-24 h-24 flex items-center justify-center">
                      <span class="text-4xl">{userProfile.name?.charAt(0) || '?'}</span>
                    </div>
                  {/if}
                </div>
              </div>

              <div class="flex-1">
                <h3 class="text-2xl font-bold">{userProfile.full_name}</h3>
                <p class="text-lg opacity-70">{userProfile.role === 'lawyer' ? (userProfile.gender === 'female' ? 'Advogada' : 'Advogado') : userProfile.role}</p>
                <p class="text-sm opacity-60">OAB: {userProfile.oab}</p>
                <p class="text-sm opacity-60">Email: {whoAmIUser?.attributes?.email}</p>
                <div class="mt-3">
                  <button
                    class="btn btn-primary btn-sm"
                    onclick={() => showAvatarEditor = true}
                  >
                    Alterar Foto
                  </button>
                </div>
              </div>
            </div>

            <!-- Personal Information -->
            <div class="card bg-base-100 shadow">
              <div class="card-body">
                <h4 class="card-title">Informações Pessoais</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label class="label" for="full-name">
                      <span class="label-text font-semibold">Nome Completo</span>
                    </label>
                    <input id="full-name" type="text" value={userProfile.full_name} class="input input-bordered w-full" readonly />
                  </div>

                  <div>
                    <label class="label" for="cpf">
                      <span class="label-text font-semibold">CPF</span>
                    </label>
                    <input id="cpf" type="text" value={userProfile.cpf} class="input input-bordered w-full" readonly />
                  </div>

                  <div>
                    <label class="label" for="rg">
                      <span class="label-text font-semibold">RG</span>
                    </label>
                    <input id="rg" type="text" value={userProfile.rg} class="input input-bordered w-full" readonly />
                  </div>

                  <div>
                    <label class="label" for="birth">
                      <span class="label-text font-semibold">Data de Nascimento</span>
                    </label>
                    <input id="birth" type="text" value={userProfile.birth} class="input input-bordered w-full" readonly />
                  </div>

                  <div>
                    <label class="label" for="nationality">
                      <span class="label-text font-semibold">Nacionalidade</span>
                    </label>
                    <input id="nationality" type="text" value={userProfile.nationality} class="input input-bordered w-full" readonly />
                  </div>

                  <div>
                    <label class="label" for="civil-status">
                      <span class="label-text font-semibold">Estado Civil</span>
                    </label>
                    <input id="civil-status" type="text" value={userProfile.civil_status} class="input input-bordered w-full" readonly />
                  </div>

                  <div>
                    <label class="label" for="gender">
                      <span class="label-text font-semibold">Gênero</span>
                    </label>
                    <input id="gender" type="text" value={userProfile.gender === 'female' ? 'Feminino' : 'Masculino'} class="input input-bordered w-full" readonly />
                  </div>

                  <div>
                    <div class="label">
                      <span class="label-text font-semibold">Status</span>
                    </div>
                    <div class="badge badge-success">{userProfile.status}</div>
                  </div>
                </div>

                {#if userProfile.mother_name}
                  <div class="mt-4">
                    <label class="label" for="mother-name">
                      <span class="label-text font-semibold">Nome da Mãe</span>
                    </label>
                    <input id="mother-name" type="text" value={userProfile.mother_name} class="input input-bordered w-full" readonly />
                  </div>
                {/if}
              </div>
            </div>

            <!-- Team Information -->
            {#if userTeam}
              <div class="card bg-base-100 shadow">
                <div class="card-body">
                  <h4 class="card-title">Informações da Equipe</h4>
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label class="label" for="team-name">
                        <span class="label-text font-semibold">Nome da Equipe</span>
                      </label>
                      <input id="team-name" type="text" value={userTeam.name} class="input input-bordered w-full" readonly />
                    </div>
                    <div>
                      <label class="label" for="subdomain">
                        <span class="label-text font-semibold">Subdomínio</span>
                      </label>
                      <input id="subdomain" type="text" value={userTeam.subdomain} class="input input-bordered w-full" readonly />
                    </div>
                  </div>
                </div>
              </div>
            {/if}

            <!-- Offices -->
            {#if userOffices.length > 0}
              <div class="card bg-base-100 shadow">
                <div class="card-body">
                  <h4 class="card-title">Escritórios</h4>
                  <div class="space-y-4">
                    {#each userOffices as office}
                      <div class="p-4 bg-base-200 rounded-lg">
                        <h5 class="font-semibold">{office.name}</h5>
                        <p class="text-sm">CNPJ: {office.cnpj}</p>
                        <p class="text-sm">Tipo de Sociedade: {office.partnership_type}</p>
                        <p class="text-sm">Participação: {office.partnership_percentage}%</p>
                      </div>
                    {/each}
                  </div>
                </div>
              </div>
            {/if}

            <!-- Contact Information -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <!-- Phones -->
              {#if userPhones.length > 0}
                <div class="card bg-base-100 shadow">
                  <div class="card-body">
                    <h4 class="card-title">Telefones</h4>
                    <div class="space-y-2">
                      {#each userPhones as phone}
                        <div class="p-2 bg-base-200 rounded">
                          <p class="font-medium">{phone.phone_number}</p>
                          {#if phone.phone_type}
                            <p class="text-xs opacity-70">{phone.phone_type}</p>
                          {/if}
                        </div>
                      {/each}
                    </div>
                  </div>
                </div>
              {/if}

              <!-- Addresses -->
              {#if userAddresses.length > 0}
                <div class="card bg-base-100 shadow">
                  <div class="card-body">
                    <h4 class="card-title">Endereços</h4>
                    <div class="space-y-3">
                      {#each userAddresses as address}
                        <div class="p-3 bg-base-200 rounded-lg">
                          <p class="font-medium">{address.street}, {address.number}</p>
                          {#if address.complement}
                            <p class="text-sm">{address.complement}</p>
                          {/if}
                          <p class="text-sm">{address.neighborhood}</p>
                          <p class="text-sm">{address.city} - {address.state}</p>
                          <p class="text-sm">CEP: {address.zip_code}</p>
                          {#if address.address_type}
                            <div class="badge badge-outline text-xs mt-1">{address.address_type}</div>
                          {/if}
                        </div>
                      {/each}
                    </div>
                  </div>
                </div>
              {/if}
            </div>

            <!-- Statistics -->
            <div class="stats stats-vertical lg:stats-horizontal shadow w-full">
              <div class="stat">
                <div class="stat-title">Trabalhos</div>
                <div class="stat-value text-primary">{whoAmIUser?.attributes?.works_count || 0}</div>
                <div class="stat-desc">Total de trabalhos</div>
              </div>

              <div class="stat">
                <div class="stat-title">Jobs</div>
                <div class="stat-value text-secondary">{whoAmIUser?.attributes?.jobs_count || 0}</div>
                <div class="stat-desc">Total de jobs</div>
              </div>
            </div>

            <!-- Actions -->
            <div class="card bg-base-100 shadow">
              <div class="card-body">
                <h4 class="card-title">Ações</h4>
                <div class="flex flex-wrap gap-2">
                  <button class="btn btn-primary" disabled>
                    Editar Perfil
                    <span class="badge badge-ghost">Em breve</span>
                  </button>
                  <button
                    class="btn btn-outline"
                    onclick={() => showAvatarEditor = true}
                  >
                    Alterar Foto
                  </button>
                  <button class="btn btn-outline" disabled>
                    Alterar Senha
                    <span class="badge badge-ghost">Em breve</span>
                  </button>
                </div>
              </div>
            </div>

          </div>
        {:else}
          <div class="alert alert-warning">
            <span>Nenhum dado de usuário encontrado</span>
          </div>
        {/if}
      </div>
    </div>
  </div>

  <!-- Avatar Editor Modal -->
  {#if showAvatarEditor}
    <div class="modal modal-open">
      <div class="modal-box max-w-3xl">
        <button
          class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
          onclick={() => showAvatarEditor = false}
        >✕</button>

        <h3 class="font-bold text-lg mb-4">Editar Foto do Perfil</h3>

        <AvatarUpload
          currentAvatarUrl={userProfile?.avatar_url}
          userName={userProfile?.name || ''}
          loading={uploadingAvatar}
          onUpload={handleAvatarUpload}
          onRemove={handleAvatarRemove}
          onColorChange={handleColorChange}
          onError={(e) => error = e.message}
        />

        <div class="modal-action">
          <button
            class="btn"
            onclick={() => showAvatarEditor = false}
          >
            Fechar
          </button>
        </div>
      </div>
      <div
        role="button"
        tabindex="0"
        class="modal-backdrop"
        onclick={() => showAvatarEditor = false}
        onkeydown={(e) => e.key === 'Escape' && (showAvatarEditor = false)}
        aria-label="Fechar editor de avatar"
      ></div>
    </div>
  {/if}
</AuthSidebar>