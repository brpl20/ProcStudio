<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  // import CepTestForm from '../components/test/CepTestForm.svelte';
  import { authStore } from '../stores/authStore';
  import { usersCacheStore, cacheStatus, allUserProfiles } from '../stores/usersCacheStore';
  import {
    notificationStore,
    unreadCount,
    isConnected,
    recentNotifications
  } from '../stores/notificationStore';
  import api from '../api/index';
  import type { WhoAmIResponse } from '../api/types';

  // Reactive statements for user data
  let authUser = $derived($authStore.user);

  // Cache status
  let cacheInfo = $derived($cacheStatus);

  // Display data
  let loading = $state(true);
  let error = $state(null);
  let currentUserData = $state<WhoAmIResponse | null>(null);

  // Derived data from whoami
  let whoAmIUser = $derived(currentUserData?.data);
  let userProfile = $derived(whoAmIUser?.attributes?.profile);

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
            onclick={() => usersCacheStore.fetchAllProfiles()}
            disabled={cacheInfo.isLoading}
          >
            {cacheInfo.isLoading ? 'Loading...' : 'Refresh Cache'}
          </button>
          <button class="btn btn-sm btn-outline" onclick={() => usersCacheStore.clearCache()}>
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
                        <div
                          class="bg-neutral text-neutral-content rounded-full w-16 h-16 flex items-center justify-center"
                        >
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
                    <div>
                      <strong>Avatar URL:</strong>
                      <a
                        href={userProfile.avatar_url}
                        target="_blank"
                        rel="noopener"
                        class="link link-primary">{userProfile.avatar_url ? 'View' : 'N/A'}</a
                      >
                    </div>
                  </div>
                </div>

                <!-- Team and Office Info -->
                {#if whoAmIUser?.attributes?.team}
                  <div class="bg-base-300 p-2 rounded mt-2">
                    <strong>Team:</strong>
                    {whoAmIUser.attributes.team.name} (ID: {whoAmIUser.attributes.team.id})
                  </div>
                {/if}

                {#if whoAmIUser?.attributes?.offices && whoAmIUser.attributes.offices.length > 0}
                  <div class="bg-base-300 p-2 rounded mt-2">
                    <strong>Offices:</strong>
                    {#each whoAmIUser.attributes.offices as office}
                      <div class="text-sm">
                        {office.name} - {office.partnership_type} ({office.partnership_percentage}%)
                      </div>
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

    <!-- WebSocket Notifications Test Section -->
    <div class="divider">WebSocket Notifications Test</div>
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h3 class="card-title">Real-time Notifications</h3>

        <!-- Connection Status -->
        <div class="stats stats-vertical lg:stats-horizontal shadow">
          <div class="stat">
            <div class="stat-title">WebSocket Status</div>
            <div class="stat-value text-sm {$isConnected ? 'text-success' : 'text-error'}">
              {$isConnected ? '🟢 Connected' : '🔴 Disconnected'}
            </div>
            <div class="stat-desc">
              {$isConnected ? 'Ready to receive notifications' : 'Not connected to server'}
            </div>
          </div>

          <div class="stat">
            <div class="stat-title">Unread Count</div>
            <div class="stat-value">{$unreadCount}</div>
            <div class="stat-desc">Unread notifications</div>
          </div>

          <div class="stat">
            <div class="stat-title">Recent Notifications</div>
            <div class="stat-value">{$recentNotifications.length}</div>
            <div class="stat-desc">Last 10 notifications</div>
          </div>
        </div>

        <!-- Debug Info -->
        <div class="alert alert-info mb-4">
          <div class="text-sm">
            <strong>WebSocket Debug Info:</strong><br />
            Connected: {$isConnected ? 'Yes' : 'No'}<br />
            Has Token: {$authStore.user?.data?.token ? 'Yes' : 'No'}<br />
            Token Preview: {$authStore.user?.data?.token
              ? `${$authStore.user.data.token.substring(0, 20)}...`
              : 'None'}<br />
            Button Disabled: {$isConnected || !$authStore.user?.data?.token ? 'Yes' : 'No'}<br /><br
            />
            <strong>Auth Store Debug:</strong><br />
            Is Authenticated: {$authStore.isAuthenticated ? 'Yes' : 'No'}<br />
            User Object: {$authStore.user ? 'Present' : 'Null'}<br />
            User Structure: {JSON.stringify(Object.keys($authStore.user || {}))}<br />
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex flex-wrap gap-2 mt-4">
          <button
            class="btn btn-sm btn-primary"
            onclick={() => {
              const token = $authStore.user?.data?.token || '';
              console.log(
                '🔑 Using token for WebSocket:',
                token ? `${token.substring(0, 20)}...` : 'No token'
              );
              notificationStore.connect(token);
            }}
            disabled={$isConnected || !$authStore.user?.data?.token}
          >
            Connect WebSocket
          </button>

          <button
            class="btn btn-sm btn-outline"
            onclick={() => notificationStore.disconnect()}
            disabled={!$isConnected}
          >
            Disconnect
          </button>

          <button
            class="btn btn-sm btn-info"
            onclick={() => notificationStore.requestUnreadCount()}
            disabled={!$isConnected}
          >
            Request Unread Count
          </button>

          <button
            class="btn btn-sm btn-warning"
            onclick={() => notificationStore.markAllAsRead()}
            disabled={!$isConnected || $unreadCount === 0}
          >
            Mark All as Read
          </button>
        </div>

        <!-- Recent Notifications List -->
        <div class="mt-6">
          <h4 class="font-semibold mb-3">Recent Notifications</h4>

          {#if $recentNotifications.length === 0}
            <div class="alert alert-info">
              <span
                >No notifications received yet. Create a Job in the backend to test notifications.</span
              >
            </div>
          {:else}
            <div class="space-y-2">
              {#each $recentNotifications as notification}
                <div class="card bg-base-200 compact">
                  <div class="card-body">
                    <div class="flex justify-between items-start">
                      <div class="flex-1">
                        <h5
                          class="font-medium {notification.read
                            ? 'text-base-content/70'
                            : 'text-base-content'}"
                        >
                          {notification.title}
                        </h5>
                        <p class="text-sm text-base-content/80 mt-1">
                          {notification.message}
                        </p>

                        <div class="flex items-center gap-2 mt-2 text-xs">
                          <span class="badge badge-outline">
                            {notification.notification_type}
                          </span>
                          <span class="badge badge-outline">
                            Priority: {notification.priority}
                          </span>
                          <span class="text-base-content/60">
                            {new Date(notification.created_at).toLocaleString()}
                          </span>
                        </div>

                        {#if notification.data}
                          <details class="mt-2">
                            <summary class="text-xs cursor-pointer text-base-content/60"
                              >View data</summary
                            >
                            <pre
                              class="text-xs mt-1 bg-base-300 p-2 rounded overflow-auto max-h-20">
{JSON.stringify(notification.data, null, 2)}
                            </pre>
                          </details>
                        {/if}
                      </div>

                      <div class="flex items-center gap-2">
                        {#if !notification.read}
                          <button
                            class="btn btn-xs btn-outline"
                            onclick={() => notificationStore.markAsRead(notification.id)}
                            disabled={!$isConnected}
                          >
                            Mark Read
                          </button>
                        {:else}
                          <span class="badge badge-success badge-xs">Read</span>
                        {/if}

                        {#if notification.action_url}
                          <button class="btn btn-xs btn-primary" disabled>
                            Go to {notification.action_url}
                          </button>
                        {/if}
                      </div>
                    </div>
                  </div>
                </div>
              {/each}
            </div>
          {/if}
        </div>

        <!-- Test Instructions -->
        <div class="alert alert-warning mt-6">
          <div>
            <h4 class="font-semibold">Testing Instructions:</h4>
            <ol class="list-decimal list-inside text-sm space-y-1 mt-2">
              <li>Make sure WebSocket is connected (green status above)</li>
              <li>
                Use the authenticator tool to create a Job: <code
                  >node ai-tools/authenticator.js create job</code
                >
              </li>
              <li>
                Or use the Rails console: <code
                  >Job.create!(user: User.first, description: "Test job", ...)</code
                >
              </li>
              <li>Watch for real-time notifications to appear above</li>
              <li>Test marking notifications as read</li>
            </ol>
          </div>
        </div>
      </div>
    </div>

    <!-- CEP Test Section -->
    <div class="divider">CEP Validator Test</div>
  </div>
</AuthSidebar>
