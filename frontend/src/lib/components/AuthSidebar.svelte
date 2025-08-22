<script lang="ts">
  import { onMount } from 'svelte';
  import { WebsiteName } from '../config.js';
  import { authStore } from '../stores/authStore.js';
  import { userProfileStore, currentUserProfile, type UserProfile } from '../stores/userProfileStore.ts';
  import { router } from '../stores/routerStore.js';
  import Icon from '../icons.svelte';

  export const activeSection: string = '';

  $: isAuthenticated = $authStore.isAuthenticated;
  $: currentPath = $router.currentPath;
  $: currentUser = $authStore.user;
  $: userProfile = $currentUserProfile;
  $: isLoadingProfile = $userProfileStore.isLoading;

  // Computed user display properties
  $: userDisplayName = getUserDisplayName(userProfile, currentUser, isLoadingProfile);
  $: userRole = getUserRole(userProfile, currentUser);

  function getUserDisplayName(profile: any, user: any, loading: boolean): string {
    if (loading) return '';
    
    if (profile?.attributes) {
      const firstName = profile.attributes.name || '';
      const lastName = profile.attributes.last_name || '';
      return `${firstName} ${lastName}`.trim() || 'Nome não definido';
    }
    
    if (user?.data) {
      const firstName = user.data.name || '';
      const lastName = user.data.last_name || '';
      return `${firstName} ${lastName}`.trim() || user.data.email || 'Usuário';
    }
    
    return 'Usuário';
  }

  function getUserRole(profile: any, user: any): string {
    return profile?.attributes?.role || user?.data?.role || '';
  }

  function handleLogout(): void {
    authStore.logout();
    router.navigate('/');
  }

  function closeDrawer(): void {
    const adminDrawer = document.getElementById('admin-drawer');
    if (adminDrawer) {
      adminDrawer.checked = false;
    }
  }

  // The currentUserProfile derived store handles automatic fetching
  // No manual onMount needed
</script>

<div class="drawer lg:drawer-open">
  <input id="admin-drawer" type="checkbox" class="drawer-toggle" />
  <div class="drawer-content">
    <!-- Navbar para mobile -->
    <div class="navbar bg-base-100 lg:hidden">
      <div class="flex-1">
        <a
          class="btn btn-ghost normal-case text-xl"
          href="/"
          on:click|preventDefault={() => router.navigate('/')}
        >
          {WebsiteName}
        </a>
      </div>
      <div class="flex-none">
        <label for="admin-drawer" class="btn btn-ghost btn-circle">
          <Icon name="hamburger" />
        </label>
      </div>
    </div>

    <!-- Conteúdo principal -->
    <div class="container px-6 lg:px-12 py-3 lg:py-6">
      <slot />
    </div>
  </div>

  <!-- Menu lateral -->
  <div class="drawer-side">
    <label for="admin-drawer" class="drawer-overlay"></label>
    <ul class="menu menu-lg p-4 w-80 min-h-full bg-base-100 lg:border-r text-primary">
      <!-- Título -->
      <li>
        <div class="normal-case menu-title text-xl font-bold text-primary flex flex-row">
          <a href="/" class="grow" on:click|preventDefault={() => router.navigate('/')}>
            {WebsiteName}
          </a>
          <label for="admin-drawer" class="lg:hidden ml-3"> ✕ </label>
        </div>
      </li>

      <!-- Dashboard -->
      <li>
        <a
          href="/dashboard"
          class={currentPath === '/dashboard' ? 'active' : ''}
          on:click|preventDefault={() => {
            router.navigate('/dashboard');
            closeDrawer();
          }}
        >
          <Icon name="dashboard" />
          Dashboard
        </a>
      </li>

      <!-- Admin -->
      <li>
        <a
          href="/admin"
          class={currentPath === '/admin' ? 'active' : ''}
          on:click|preventDefault={() => {
            router.navigate('/admin');
            closeDrawer();
          }}
        >
          <Icon name="admin" />
          Admin
        </a>
      </li>

      <!-- Configurações -->
      <li>
        <a
          href="/settings"
          class={currentPath === '/settings' ? 'active' : ''}
          on:click|preventDefault={() => {
            router.navigate('/settings');
            closeDrawer();
          }}
        >
          <Icon name="settings" />
          Configurações
        </a>
      </li>

      <!-- Relatórios -->
      <li>
        <a
          href="/reports"
          class={currentPath === '/reports' ? 'active' : ''}
          on:click|preventDefault={() => {
            router.navigate('/reports');
            closeDrawer();
          }}
        >
          <Icon name="reports" />
          Relatórios
        </a>
      </li>

      <!-- Tarefas -->
      <li>
        <a
          href="/tasks"
          class={currentPath === '/tasks' ? 'active' : ''}
          on:click|preventDefault={() => {
            router.navigate('/tasks');
            closeDrawer();
          }}
        >
          <Icon name="tasks" />
          Tarefas
        </a>
      </li>

      <!-- Equipes -->
      <li>
        <a
          href="/teams"
          class={currentPath === '/teams' ? 'active' : ''}
          on:click|preventDefault={() => {
            router.navigate('/teams');
            closeDrawer();
          }}
        >
          <Icon name="teams" />
          Equipes
        </a>
      </li>

      <!-- Trabalhos -->
      <li>
        <a
          href="/works"
          class={currentPath === '/works' ? 'active' : ''}
          on:click|preventDefault={() => {
            router.navigate('/works');
            closeDrawer();
          }}
        >
          <Icon name="work" />
          Trabalhos
        </a>
      </li>

      <!-- Clientes -->
      <li>
        <a
          href="/customers"
          class={currentPath === '/customers' ? 'active' : ''}
          on:click|preventDefault={() => {
            router.navigate('/customers');
            closeDrawer();
          }}
        >
          <Icon name="customer" />
          Clientes
        </a>
      </li>

      <!-- User Info before logout -->
      {#if isAuthenticated}
        <li class="mb-2">
          <div class="px-4 py-1 text-center">
            {#if isLoadingProfile}
              <div class="loading loading-spinner loading-xs"></div>
            {:else}
              <div class="text-sm font-medium text-base-content">
                {userDisplayName}
              </div>
              {#if userRole}
                <div class="text-xs text-base-content/70 mt-1">
                  {userRole}
                </div>
              {/if}
            {/if}
          </div>
        </li>
      {/if}

      <!-- Logout no final -->
      <li class="mt-auto">
        <button on:click={handleLogout} class="mt-auto text-base w-full text-left">
          <Icon name="logout" />
          Sair
        </button>
      </li>
    </ul>
  </div>
</div>

<style>
  .drawer-content {
    background-color: var(--color-base-200, #faedd6);
  }
</style>
