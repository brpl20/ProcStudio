<script>
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CepTestForm from '../components/test/CepTestForm.svelte';
  import { currentUserProfile, userProfileStore } from '../stores/userProfileStore.ts';
  import { authStore } from '../stores/authStore.js';
  import api from '../api/index.ts';

  $: userProfile = $currentUserProfile;
  $: avatarUrl = userProfile?.attributes?.avatar_url || userProfile?.attributes?.avatar;
  $: currentUser = $authStore.user;

  let apiResponse = null;
  let profileResponse = null;

  onMount(async () => {
    // eslint-disable-next-line no-console
    console.log('=== ADMIN PAGE AVATAR DEBUG ===');
    // eslint-disable-next-line no-console
    console.log('Current user from authStore:', $authStore.user);
    // eslint-disable-next-line no-console
    console.log('Current user profile from store:', $currentUserProfile);

    try {
      // Get current user ID
      const userId = $authStore.user?.data?.id;
      // eslint-disable-next-line no-console
      console.log('User ID for API call:', userId);

      if (userId) {
        // Make direct API call to get user data
        // eslint-disable-next-line no-console
        console.log('Making API call to get user...');
        const userResponse = await api.users.getUser(userId);
        apiResponse = userResponse;
        // eslint-disable-next-line no-console
        console.log('User API Response:', userResponse);

        // Try to get user profiles list
        // eslint-disable-next-line no-console
        console.log('Making API call to get user profiles...');
        const profilesResponse = await api.users.getUserProfiles();
        // eslint-disable-next-line no-console
        console.log('User Profiles API Response:', profilesResponse);

        // If we have user profile ID, get specific profile
        const userProfileId = userResponse.data?.relationships?.user_profile?.data?.id;
        if (userProfileId) {
          // eslint-disable-next-line no-console
          console.log('Making API call to get specific user profile:', userProfileId);
          const specificProfileResponse = await api.users.getUserProfile(userProfileId);
          profileResponse = specificProfileResponse;
          // eslint-disable-next-line no-console
          console.log('Specific Profile API Response:', specificProfileResponse);
        }

        // eslint-disable-next-line no-console
        console.log('=== END AVATAR DEBUG ===');
      }
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('Error fetching user data:', error);
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

    <!-- CEP Test Section -->
    <div class="divider">CEP Validator Test</div>
    <CepTestForm />

    <!-- Avatar Test Section -->
    <div class="divider">Avatar Test</div>
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h3 class="card-title">Current User Avatar Debug</h3>

        <div class="space-y-4">
          <!-- Debug Info -->
          <div class="bg-base-200 p-4 rounded-lg">
            <h4 class="font-semibold mb-2">Raw Data:</h4>
            <div class="text-sm space-y-1">
              <p><strong>User Profile ID:</strong> {userProfile?.id || 'Not loaded'}</p>
              <p><strong>Avatar URL:</strong> {avatarUrl || 'No avatar URL'}</p>
              <p>
                <strong>Raw Avatar:</strong>
                {userProfile?.attributes?.avatar || 'No avatar field'}
              </p>
              <p>
                <strong>Raw Avatar URL:</strong>
                {userProfile?.attributes?.avatar_url || 'No avatar_url field'}
              </p>
            </div>
          </div>

          <!-- Avatar Display Test -->
          <div class="flex items-center gap-6">
            <div>
              <h4 class="font-semibold mb-2">Large Avatar (80px):</h4>
              <div class="avatar placeholder">
                <div class="bg-primary text-primary-content rounded-full w-20">
                  {#if avatarUrl}
                    <img src={avatarUrl} alt="Avatar" class="rounded-full w-20 h-20 object-cover" />
                  {:else}
                    <span class="text-2xl">U3</span>
                  {/if}
                </div>
              </div>
            </div>

            <div>
              <h4 class="font-semibold mb-2">Medium Avatar (40px):</h4>
              <div class="avatar placeholder">
                <div class="bg-primary text-primary-content rounded-full w-10">
                  {#if avatarUrl}
                    <img src={avatarUrl} alt="Avatar" class="rounded-full w-10 h-10 object-cover" />
                  {:else}
                    <span class="text-lg">U3</span>
                  {/if}
                </div>
              </div>
            </div>

            <div>
              <h4 class="font-semibold mb-2">Small Avatar (32px):</h4>
              <div class="avatar placeholder">
                <div class="bg-primary text-primary-content rounded-full w-8">
                  {#if avatarUrl}
                    <img src={avatarUrl} alt="Avatar" class="rounded-full w-8 h-8 object-cover" />
                  {:else}
                    <span class="text-sm">U3</span>
                  {/if}
                </div>
              </div>
            </div>
          </div>

          <!-- API Response Display -->
          <div class="bg-base-200 p-4 rounded-lg">
            <h4 class="font-semibold mb-2">User API Response:</h4>
            <pre class="text-xs overflow-auto max-h-40">{JSON.stringify(apiResponse, null, 2)}</pre>
          </div>

          <div class="bg-base-200 p-4 rounded-lg">
            <h4 class="font-semibold mb-2">Profile API Response:</h4>
            <pre class="text-xs overflow-auto max-h-40">{JSON.stringify(
                profileResponse,
                null,
                2
              )}</pre>
          </div>

          <!-- Raw JSON Display -->
          <div class="bg-base-200 p-4 rounded-lg">
            <h4 class="font-semibold mb-2">User Profile Store JSON:</h4>
            <pre class="text-xs overflow-auto max-h-40">{JSON.stringify(userProfile, null, 2)}</pre>
          </div>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
