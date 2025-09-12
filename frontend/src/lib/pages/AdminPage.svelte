<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CepTestForm from '../components/test/CepTestForm.svelte';
  import { authStore } from '../stores/authStore';
  import { usersCacheStore, cacheStatus, allUserProfiles } from '../stores/usersCacheStore';
  import api from '../api/index';
  import type { WhoAmIResponse } from '../api/types';

  // Reactive statements for user data
  $: authUser = $authStore.user;

  // Cache status
  $: cacheInfo = $cacheStatus;

  // Display data
  let loading = true;
  let error = null;
  let currentUserData: WhoAmIResponse | null = null;

  // Derived data from whoami
  $: whoAmIUser = currentUserData?.data;
  $: userProfile = whoAmIUser?.attributes?.profile;

  onMount(async () => {
    try {
      currentUserData = await api.users.whoami();
      loading = false;
    } catch (err) {
      error = err;
      loading = false;
    }
  });
</script>

<AuthSidebar activeSection="admin">
  <div class="container mx-auto space-y-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title text-3xl mb-6">Super Admin</h2>
        <p>Todo: Quantidade de usuários</p>
        <p>Todo: Novos Usuários</p>
        <p>Todo: Desistentes</p>
        <p>Todo: Faturamento</p>
        <p>Todo: Ias</p>
      </div>
    </div>

    <!-- Cache Status Section -->
    <div class="divider">Cache Status</div>
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h3 class="card-title">Users Cache Information</h3>
        <div class="stats stats-vertical lg:stats-horizontal shadow">
          <div class="stat">
            <div class="stat-title">Cache Status</div>
            <div class="stat-value text-sm">
              {cacheInfo.isInitialized ? 'Initialized' : 'Not Initialized'}
            </div>
            <div class="stat-desc">
              {cacheInfo.isLoading ? 'Loading...' : 'Ready'}
            </div>
          </div>

          <div class="stat">
            <div class="stat-title">Cached Profiles</div>
            <div class="stat-value">{cacheInfo.profileCount}</div>
            <div class="stat-desc">User profiles in cache</div>
          </div>

          <div class="stat">
            <div class="stat-title">Last Fetched</div>
            <div class="stat-value text-sm">
              {cacheInfo.lastFetched ? cacheInfo.lastFetched.toLocaleTimeString() : 'Never'}
            </div>
            <div class="stat-desc">
              {cacheInfo.lastFetched ? cacheInfo.lastFetched.toLocaleDateString() : ''}
            </div>
          </div>
        </div>

        <div class="mt-4 flex gap-2">
          <button
            class="btn btn-sm btn-primary"
            on:click={() => usersCacheStore.fetchAllProfiles()}
            disabled={cacheInfo.isLoading}
          >
            {cacheInfo.isLoading ? 'Loading...' : 'Refresh Cache'}
          </button>
          <button
            class="btn btn-sm btn-outline"
            on:click={() => usersCacheStore.clearCache()}
          >
            Clear Cache
          </button>
        </div>
      </div>
    </div>

    <!-- User Data Section -->
    <div class="divider">User Data Test</div>
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h3 class="card-title">Current User Information</h3>

        {#if loading}
          <div class="flex justify-center p-8">
            <span class="loading loading-spinner loading-lg"></span>
          </div>
        {:else if error}
          <div class="alert alert-error">
            <span>Error loading user data: {error.message || error}</span>
          </div>
        {:else}
          <div class="space-y-4">
            <!-- Auth User Data from authStore -->
            <div class="bg-base-200 p-4 rounded-lg">
              <h4 class="font-semibold mb-2">Auth User (from login):</h4>
              {#if authUser}
                <div class="grid grid-cols-2 gap-2 text-sm">
                  <div><strong>ID:</strong> {authUser.data?.id || 'N/A'}</div>
                  <div><strong>Name:</strong> {authUser.data?.name || 'N/A'}</div>
                  <div><strong>Last Name:</strong> {authUser.data?.last_name || 'N/A'}</div>
                  <div><strong>OAB:</strong> {authUser.data?.oab || 'N/A'}</div>
                  <div><strong>Role:</strong> {authUser.data?.role || 'N/A'}</div>
                  <div><strong>Gender:</strong> {authUser.data?.gender || 'N/A'}</div>
                </div>
              {:else}
                <p>No auth user data available</p>
              {/if}
            </div>

            <!-- User Profile Data from whoami -->
            <div class="bg-base-200 p-4 rounded-lg">
              <h4 class="font-semibold mb-2">User Profile (from whoami):</h4>
              {#if userProfile}
                <div class="flex items-start gap-4 mb-4">
                  <!-- Avatar Display -->
                  <div class="avatar">
                    <div class="w-16 rounded-full">
                      {#if userProfile.avatar_url}
                        <img src={userProfile.avatar_url} alt={userProfile.full_name} />
                      {:else}
                        <div class="bg-neutral text-neutral-content rounded-full w-16 h-16 flex items-center justify-center">
                          <span class="text-xl">{userProfile.name?.charAt(0) || '?'}</span>
                        </div>
                      {/if}
                    </div>
                  </div>

                  <!-- Profile Info -->
                  <div class="flex-1 grid grid-cols-2 gap-2 text-sm">
                    <div><strong>Profile ID:</strong> {userProfile.id || 'N/A'}</div>
                    <div><strong>Full Name:</strong> {userProfile.full_name || 'N/A'}</div>
                    <div><strong>Name:</strong> {userProfile.name || 'N/A'}</div>
                    <div><strong>Last Name:</strong> {userProfile.last_name || 'N/A'}</div>
                    <div><strong>Role:</strong> {userProfile.role || 'N/A'}</div>
                    <div><strong>OAB:</strong> {userProfile.oab || 'N/A'}</div>
                    <div><strong>CPF:</strong> {userProfile.cpf || 'N/A'}</div>
                    <div><strong>RG:</strong> {userProfile.rg || 'N/A'}</div>
                    <div><strong>Gender:</strong> {userProfile.gender || 'N/A'}</div>
                    <div><strong>Status:</strong> {userProfile.status || 'N/A'}</div>
                    <div><strong>Nationality:</strong> {userProfile.nationality || 'N/A'}</div>
                    <div><strong>Civil Status:</strong> {userProfile.civil_status || 'N/A'}</div>
                    <div><strong>Birth:</strong> {userProfile.birth || 'N/A'}</div>
                    <div><strong>Avatar URL:</strong> <a href={userProfile.avatar_url} target="_blank" rel="noopener" class="link link-primary">{userProfile.avatar_url ? 'View' : 'N/A'}</a></div>
                  </div>
                </div>

                <!-- Team and Office Info -->
                {#if whoAmIUser?.attributes?.team}
                  <div class="bg-base-300 p-2 rounded mt-2">
                    <strong>Team:</strong> {whoAmIUser.attributes.team.name} (ID: {whoAmIUser.attributes.team.id})
                  </div>
                {/if}

                {#if whoAmIUser?.attributes?.offices && whoAmIUser.attributes.offices.length > 0}
                  <div class="bg-base-300 p-2 rounded mt-2">
                    <strong>Offices:</strong>
                    {#each whoAmIUser.attributes.offices as office}
                      <div class="text-sm">{office.name} - {office.partnership_type} ({office.partnership_percentage}%)</div>
                    {/each}
                  </div>
                {/if}
              {:else}
                <p>No user profile data available</p>
              {/if}
            </div>

            <!-- Raw JSON for debugging -->
            <details class="collapse collapse-arrow bg-base-200">
              <summary class="collapse-title font-semibold">Raw Auth User JSON</summary>
              <div class="collapse-content">
                <pre class="text-xs overflow-auto">{JSON.stringify(authUser, null, 2)}</pre>
              </div>
            </details>

            <details class="collapse collapse-arrow bg-base-200">
              <summary class="collapse-title font-semibold">Raw WhoAmI Response JSON</summary>
              <div class="collapse-content">
                <pre class="text-xs overflow-auto">{JSON.stringify(currentUserData, null, 2)}</pre>
              </div>
            </details>
          </div>
        {/if}
      </div>
    </div>

    <!-- Avatar Gallery from Cache -->
    <div class="divider">Cached Avatars Gallery</div>
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h3 class="card-title">All User Avatars from Cache</h3>

        {#if $allUserProfiles.length > 0}
          <div class="grid grid-cols-4 md:grid-cols-6 lg:grid-cols-8 gap-4">
            {#each $allUserProfiles.slice(0, 24) as profile}
              <div class="text-center">
                <div class="avatar placeholder">
                  <div class="bg-neutral text-neutral-content rounded-full w-16">
                    {#if profile.attributes?.avatar_url || profile.attributes?.avatar}
                      <img
                        src={profile.attributes.avatar_url || profile.attributes.avatar}
                        alt={profile.attributes.name}
                        class="rounded-full"
                      />
                    {:else}
                      <span class="text-xl">
                        {profile.attributes?.name?.charAt(0) || '?'}
                      </span>
                    {/if}
                  </div>
                </div>
                <div class="text-xs mt-1 truncate">
                  {profile.attributes?.name || 'Unknown'}
                </div>
              </div>
            {/each}
          </div>

          {#if $allUserProfiles.length > 24}
            <div class="text-sm text-base-content/60 mt-2">
              Showing 24 of {$allUserProfiles.length} cached profiles
            </div>
          {/if}
        {:else}
          <p class="text-base-content/60">No profiles in cache</p>
        {/if}
      </div>
    </div>

    <!-- CEP Test Section -->
    <div class="divider">CEP Validator Test</div>
    <CepTestForm />
  </div>
</AuthSidebar>
