<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CepTestForm from '../components/test/CepTestForm.svelte';
  import { authStore } from '../stores/authStore';
  import { userProfileStore, currentUserProfile } from '../stores/userProfileStore';
  import { usersCacheStore, cacheStatus, allUserProfiles } from '../stores/usersCacheStore';

  // Reactive statements for user data
  $: authUser = $authStore.user;
  $: userProfile = $currentUserProfile;
  $: userId = authUser?.data?.id;
  $: cachedProfile = userId ? usersCacheStore.getProfileByUserId(userId) : null;
  
  // Cache status
  $: cacheInfo = $cacheStatus;

  // Display data
  let loading = true;
  let error = null;

  onMount(async () => {
    // eslint-disable-next-line no-console
    console.log('=== ADMIN PAGE DEBUG ===');
    // eslint-disable-next-line no-console
    console.log('Auth User:', authUser);
    // eslint-disable-next-line no-console
    console.log('User ID:', userId);
    // eslint-disable-next-line no-console
    console.log('Cache Status:', $cacheStatus);
    
    if (userId) {
      try {
        // Fetch user profile (will use cache)
        await userProfileStore.fetchCurrentUser(String(userId));
        loading = false;
        // eslint-disable-next-line no-console
        console.log('User Profile Loaded:', $currentUserProfile);
        // eslint-disable-next-line no-console
        console.log('Cached Profile:', cachedProfile);
      } catch (err) {
        error = err;
        loading = false;
        // eslint-disable-next-line no-console
        console.error('Error loading profile:', err);
      }
    } else {
      loading = false;
      // eslint-disable-next-line no-console
      console.log('No user ID available');
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

            <!-- User Profile Data from userProfileStore -->
            <div class="bg-base-200 p-4 rounded-lg">
              <h4 class="font-semibold mb-2">User Profile (from API):</h4>
              {#if userProfile}
                <div class="grid grid-cols-2 gap-2 text-sm">
                  <div><strong>Profile ID:</strong> {userProfile.id || 'N/A'}</div>
                  <div><strong>Name:</strong> {userProfile.attributes?.name || 'N/A'}</div>
                  <div><strong>Last Name:</strong> {userProfile.attributes?.last_name || 'N/A'}</div>
                  <div><strong>OAB:</strong> {userProfile.attributes?.oab || 'N/A'}</div>
                  <div><strong>CPF:</strong> {userProfile.attributes?.cpf || 'N/A'}</div>
                  <div><strong>RG:</strong> {userProfile.attributes?.rg || 'N/A'}</div>
                  <div><strong>Avatar URL:</strong> {userProfile.attributes?.avatar_url || userProfile.attributes?.avatar || 'N/A'}</div>
                </div>
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
              <summary class="collapse-title font-semibold">Raw User Profile JSON</summary>
              <div class="collapse-content">
                <pre class="text-xs overflow-auto">{JSON.stringify(userProfile, null, 2)}</pre>
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
