<script lang="ts">
  import { onMount } from 'svelte';
  import { WebsiteName } from '../config.js';
  import { authStore } from '../stores/authStore.js';
  import {
    userProfileStore,
    currentUserProfile,
    type UserProfile
  } from '../stores/userProfileStore.ts';
  import { router } from '../stores/routerStore.js';
  import Icon from '../icons.svelte';
  import TopBar from './TopBar.svelte';
  import Footer from './Footer.svelte';
  import Breadcrumbs from './Breadcrumbs.svelte';
  import AuthGuard from './AuthGuard.svelte';

  export const activeSection: string = '';

  $: isAuthenticated = $authStore.isAuthenticated;
  $: currentPath = $router.currentPath;
  $: currentUser = $authStore.user;
  $: userProfile = $currentUserProfile;
  $: isLoadingProfile = $userProfileStore.isLoading;

  // Computed user display properties
  $: userDisplayName = getUserDisplayName(userProfile, currentUser, isLoadingProfile);
  $: userRole = getUserRole(userProfile, currentUser);
  $: userEmail = getUserEmail(userProfile, currentUser);
  $: userInitials = getUserInitials(userDisplayName);

  function getUserDisplayName(profile: any, user: any, loading: boolean): string {
    if (loading) {
      return '';
    }

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
    const role = profile?.attributes?.role || user?.data?.role || '';
    const gender = profile?.attributes?.gender || user?.data?.gender || '';

    // Translate lawyer role based on gender
    if (role && role.toLowerCase().includes('lawyer')) {
      return gender === 'female' ? 'Advogada' : 'Advogado';
    }

    return role;
  }

  function getUserEmail(profile: any, user: any): string {
    return profile?.attributes?.email || user?.data?.email || '';
  }

  function getUserInitials(name: string): string {
    if (!name || name === 'Carregando...') {
      return '?';
    }
    return (
      name
        .split(' ')
        .map((n) => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2) || 'U'
    );
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

<AuthGuard>
  <div class="drawer lg:drawer-open">
    <input id="admin-drawer" type="checkbox" class="drawer-toggle" />
    <div class="drawer-content flex flex-col min-h-screen">
      <!-- Top Bar -->
      <TopBar showMenuButton={true} />

      <!-- Breadcrumbs -->
      <Breadcrumbs />

      <!-- Conteúdo principal -->
      <div class="flex-1 container px-6 lg:px-12 py-3 lg:py-6">
        <slot />
      </div>

      <!-- Footer -->
      <Footer />
    </div>

    <!-- Menu lateral -->
    <div class="drawer-side">
      <label for="admin-drawer" class="drawer-overlay"></label>
      <ul class="menu menu-lg p-4 w-80 min-h-full bg-base-100 lg:border-r text-base-content">
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

        <!-- Jobs -->
        <li>
          <a
            href="/jobs"
            class={currentPath === '/jobs' ? 'active' : ''}
            on:click|preventDefault={() => {
              router.navigate('/jobs');
              closeDrawer();
            }}
          >
            <Icon name="tasks" />
            Jobs
          </a>
        </li>

        <!-- Time -->
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
            Time
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

        <!-- User Menu no final -->
        {#if isAuthenticated}
          <li class="mt-auto">
            <div class="dropdown dropdown-top w-full">
              <button
                type="button"
                class="btn btn-ghost w-full justify-start px-4 py-3 hover:bg-base-200"
              >
                <div class="flex items-center gap-3 w-full">
                  <div class="avatar placeholder">
                    <div class="bg-primary text-primary-content rounded-full w-8">
                      <span class="text-sm">{userInitials}</span>
                    </div>
                  </div>
                  <div class="flex-1 text-left">
                    {#if isLoadingProfile}
                      <div class="loading loading-spinner loading-xs"></div>
                    {:else}
                      <div class="text-sm font-medium">
                        {userDisplayName}
                      </div>
                      {#if userRole}
                        <div class="text-xs opacity-70">
                          {userRole}
                        </div>
                      {/if}
                    {/if}
                  </div>
                  <Icon name="chevron-up" className="w-4 h-4 opacity-50" strokeWidth="1.5" />
                </div>
              </button>

              <ul
                class="dropdown-content menu p-2 shadow-lg bg-base-100 rounded-box w-72 mb-2 border border-base-300 z-[100]"
              >
                <!-- User info section -->
                <li class="px-3 py-2">
                  <div class="flex items-center gap-3 pointer-events-none">
                    <div class="avatar placeholder">
                      <div class="bg-primary text-primary-content rounded-full w-10">
                        <span class="text-lg">{userInitials}</span>
                      </div>
                    </div>
                    <div class="flex-1">
                      <div class="font-medium">{userDisplayName}</div>
                      {#if userRole}
                        <div class="text-xs opacity-70">{userRole}</div>
                      {/if}
                    </div>
                  </div>
                </li>

                {#if userEmail}
                  <li class="px-3 pb-2">
                    <div class="text-xs text-base-content/60 pointer-events-none">
                      {userEmail}
                    </div>
                  </li>
                {/if}

                <div class="divider my-1"></div>

                <!-- Help and Support -->
                <li>
                  <button class="px-3 py-2">
                    <Icon name="help" className="w-4 h-4" strokeWidth="1.5" />
                    Ajuda
                  </button>
                </li>
                <li>
                  <button class="px-3 py-2">
                    <Icon name="support" className="w-4 h-4" strokeWidth="1.5" />
                    Suporte
                  </button>
                </li>

                <div class="divider my-1"></div>

                <!-- Logout -->
                <li>
                  <button class="px-3 py-2 text-error" on:click={handleLogout}>
                    <Icon name="logout-alt" className="w-4 h-4" strokeWidth="1.5" />
                    Sair
                  </button>
                </li>
              </ul>
            </div>
          </li>
        {/if}
      </ul>
    </div>
  </div>
</AuthGuard>

<style>
  .drawer-content {
    background-color: var(--color-base-200, #faedd6);
  }

  .dropdown-content {
    animation: slideUp 0.2s ease-out;
  }

  @keyframes slideUp {
    from {
      opacity: 0;
      transform: translateY(10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .divider {
    height: 1px;
    background: var(--fallback-bc, oklch(var(--bc) / 0.1));
    margin: 0.5rem 0;
  }

  /* Keep icons blue while text stays dark */
  .menu :global(svg) {
    color: var(--color-primary);
  }

  .menu li a {
    color: var(--color-base-content);
  }

  .menu li a:hover {
    color: var(--color-base-content);
  }

  .menu li a.active {
    background-color: var(--color-primary);
    color: var(--color-primary-content);
  }

  .menu li a.active :global(svg) {
    color: var(--color-primary-content);
  }
</style>
