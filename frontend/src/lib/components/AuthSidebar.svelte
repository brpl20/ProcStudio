<script lang="ts">
  import { onMount } from 'svelte';
  import { WebsiteName } from '../config.js';
  import { authStore } from '../stores/authStore';
  import { router } from '../stores/routerStore';
  import api from '../api/index';
  import type { WhoAmIResponse } from '../api/types';
  import Icon from '../icons/icons.svelte';
  import TopBar from './TopBar.svelte';
  import Footer from './Footer.svelte';
  import Breadcrumbs from './Breadcrumbs.svelte';
  import AuthGuard from './AuthGuard.svelte';

  let { activeSection = '' }: { activeSection?: string } = $props();

  let isAuthenticated = $derived($authStore.isAuthenticated);
  let currentPath = $derived(router.currentPath);

  // Drawer state management
  let isDrawerOpen = $state(true); // Start open on desktop
  let isUserToggled = $state(false); // Track if user manually toggled

  // WhoAmI data
  let currentUserData = $state<WhoAmIResponse | null>(null);
  let isLoadingProfile = $state(true);

  // Derived data from whoami
  let whoAmIUser = $derived(currentUserData?.data);
  let userProfile = $derived(whoAmIUser?.attributes?.profile);

  // Computed user display properties using whoami data
  let userDisplayName = $derived(userProfile?.full_name || userProfile?.name || 'Usuário');
  let userRole = $derived(getUserRole(userProfile));
  let userEmail = $derived(whoAmIUser?.attributes?.email || '');
  let userInitials = $derived(getUserInitials(userDisplayName));
  let userAvatarUrl = $derived(userProfile?.avatar_url);

  function getUserRole(profile: any): string {
    const role = profile?.role || '';
    const gender = profile?.gender || '';

    // Translate lawyer role based on gender
    if (role && role.toLowerCase().includes('lawyer')) {
      return gender === 'female' ? 'Advogada' : 'Advogado';
    }

    return role;
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

  function handleUserClick(): void {
    router.navigate('/user-config');
    closeDrawer();
  }

  function toggleDrawer(): void {
    isDrawerOpen = !isDrawerOpen;
    isUserToggled = true;
    const adminDrawer = document.getElementById('admin-drawer') as HTMLInputElement;
    if (adminDrawer) {
      adminDrawer.checked = false;
    }
  }

  // Fetch whoami data on mount and handle responsive drawer
  onMount(async () => {
    if (isAuthenticated) {
      try {
        currentUserData = await api.users.whoami();
        isLoadingProfile = false;
      } catch (error) {
        isLoadingProfile = false;
      }
    }

    // Handle window resize for responsive drawer behavior
    function handleResize() {
      if (!isUserToggled) {
        // Only auto-adjust if user hasn't manually toggled
        const isDesktop = window.innerWidth >= 1024; // lg breakpoint
        isDrawerOpen = isDesktop;
      }
    }

    handleResize(); // Set initial state
    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  });
</script>

<AuthGuard>
  <div class="drawer lg:drawer-open">
    <input id="admin-drawer" type="checkbox" class="drawer-toggle" />
    <div class="drawer-content flex flex-col min-h-screen bg-base-200">
      <!-- Floating toggle button for desktop when drawer is closed -->
      {#if !isDrawerOpen && isUserToggled}
        <button
          class="btn btn-circle btn-primary fixed top-4 left-4 z-50 hidden lg:flex"
          onclick={toggleDrawer}
          title="Abrir menu"
        >
          <Icon name="menu" className="w-5 h-5" />
        </button>
      {/if}

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
      <ul class={`menu menu-lg p-4 ${isUserToggled && !isDrawerOpen ? 'w-20' : 'w-80'} min-h-full bg-base-100 lg:border-r text-base-content transition-all duration-300`}>
        <!-- Título com botão de toggle -->
        <li>
          <div class="normal-case menu-title text-xl font-bold text-primary flex flex-row items-center">
            {#if !(isUserToggled && !isDrawerOpen)}
              <a href="/" class="grow" onclick={(e) => {
 e.preventDefault(); router.navigate('/');
}}>
                {WebsiteName}
              </a>
            {/if}
            <!-- Desktop toggle button -->
            <button
              class="btn btn-ghost btn-sm hidden lg:flex"
              onclick={toggleDrawer}
              title={isDrawerOpen ? 'Recolher menu' : 'Expandir menu'}
            >
              <Icon name={isDrawerOpen ? 'chevron-left' : 'chevron-right'} className="w-5 h-5" />
            </button>
            {#if !(isUserToggled && !isDrawerOpen)}
              <!-- Mobile close button -->
              <label for="admin-drawer" class="lg:hidden ml-3"> ✕ </label>
            {/if}
          </div>
        </li>

        <!-- Dashboard -->
        <li>
          <a
            href="/dashboard"
            class={currentPath === '/dashboard' ? 'active bg-primary !text-white [&_svg]:!text-white' : 'text-base-content hover:text-base-content [&_svg]:text-primary'}
            onclick={(e) => {
              e.preventDefault();
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
            class={currentPath === '/admin' ? 'active bg-primary !text-white [&_svg]:!text-white' : 'text-base-content hover:text-base-content [&_svg]:text-primary'}
            onclick={(e) => {
              e.preventDefault();
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
            class={currentPath === '/settings' ? 'active bg-primary !text-white [&_svg]:!text-white' : 'text-base-content hover:text-base-content [&_svg]:text-primary'}
            onclick={(e) => {
              e.preventDefault();
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
            class={currentPath === '/reports' ? 'active bg-primary !text-white [&_svg]:!text-white' : 'text-base-content hover:text-base-content [&_svg]:text-primary'}
            onclick={(e) => {
              e.preventDefault();
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
            class={currentPath === '/jobs' ? 'active bg-primary !text-white [&_svg]:!text-white' : 'text-base-content hover:text-base-content [&_svg]:text-primary'}
            onclick={(e) => {
              e.preventDefault();
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
            class={currentPath === '/teams' ? 'active bg-primary !text-white [&_svg]:!text-white' : 'text-base-content hover:text-base-content [&_svg]:text-primary'}
            onclick={(e) => {
              e.preventDefault();
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
            class={currentPath === '/works' ? 'active bg-primary !text-white [&_svg]:!text-white' : 'text-base-content hover:text-base-content [&_svg]:text-primary'}
            onclick={(e) => {
              e.preventDefault();
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
            class={currentPath === '/customers' ? 'active bg-primary !text-white [&_svg]:!text-white' : 'text-base-content hover:text-base-content [&_svg]:text-primary'}
            onclick={(e) => {
              e.preventDefault();
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
                      {#if userAvatarUrl}
                        <img
                          src={userAvatarUrl}
                          alt="Avatar"
                          class="rounded-full w-8 h-8 object-cover"
                        />
                      {:else}
                        <span class="text-sm">{userInitials}</span>
                      {/if}
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
                class="dropdown-content menu p-2 shadow-lg bg-base-100 rounded-box w-72 mb-2 border border-base-300 z-[100] animate-[slideUp_0.2s_ease-out]"
              >
                <!-- User info section -->
                <li class="px-3 py-2">
                  <div class="flex items-center gap-3 pointer-events-none">
                    <div class="avatar placeholder">
                      <div class="bg-primary text-primary-content rounded-full w-10">
                        {#if userAvatarUrl}
                          <img
                            src={userAvatarUrl}
                            alt="Avatar"
                            class="rounded-full w-10 h-10 object-cover"
                          />
                        {:else}
                          <span class="text-lg">{userInitials}</span>
                        {/if}
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

                <div class="divider my-1 h-px bg-base-content/10"></div>

                <!-- Profile Configuration -->
                <li>
                  <button class="px-3 py-2" onclick={handleUserClick}>
                    <Icon name="user" className="w-4 h-4" strokeWidth="1.5" />
                    Meu Perfil
                  </button>
                </li>

                <div class="divider my-1 h-px bg-base-content/10"></div>

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

                <div class="divider my-1 h-px bg-base-content/10"></div>

                <!-- Logout -->
                <li>
                  <button class="px-3 py-2 text-error" onclick={handleLogout}>
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

