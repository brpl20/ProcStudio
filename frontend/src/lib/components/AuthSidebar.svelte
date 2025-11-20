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
  import logoProcStudio from '../../assets/procstudio_logotipo_vertical_sem_fundo.png';

  let { activeSection = '', children }: { activeSection?: string } = $props();

  let isAuthenticated = $derived($authStore.isAuthenticated);
  let currentPath = $derived(router.currentPath);

  let isDrawerOpen = $state(true);
  let isUserToggled = $state(false);
  let isUserDropdownOpen = $state(false);

  let currentUserData = $state<WhoAmIResponse | null>(null);
  let isLoadingProfile = $state(true);

  let whoAmIUser = $derived(currentUserData?.data);
  let userProfile = $derived(whoAmIUser?.attributes?.profile);

  let userDisplayName = $derived(userProfile?.full_name || userProfile?.name || 'Usuário');
  let userRole = $derived(getUserRole(userProfile));
  let userEmail = $derived(whoAmIUser?.attributes?.email || '');
  let userInitials = $derived(getUserInitials(userDisplayName));
  let userAvatarUrl = $derived(userProfile?.avatar_url);

  function getUserRole(profile: any): string {
    const role = profile?.role || '';
    const gender = profile?.gender || '';

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
    isUserDropdownOpen = false;
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
    isUserDropdownOpen = false;
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

  function toggleUserDropdown(): void {
    isUserDropdownOpen = !isUserDropdownOpen;
  }

  function closeUserDropdown(): void {
    isUserDropdownOpen = false;
  }

  const menuItems = [
    { icon: 'dashboard', label: 'Dashboard', path: '/dashboard' },
    { icon: 'admin', label: 'Admin', path: '/admin' },
    { icon: 'settings', label: 'Configurações', path: '/settings' },
    { icon: 'reports', label: 'Relatórios', path: '/reports' },
    { icon: 'tasks', label: 'Jobs', path: '/jobs' },
    { icon: 'teams', label: 'Time', path: '/teams' },
    { icon: 'work', label: 'Trabalhos', path: '/works' },
    { icon: 'customer', label: 'Clientes', path: '/customers' }
  ];

  const iconPaths = {
    dashboard: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6',
    admin: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z',
    settings: 'M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4',
    reports: 'M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
    tasks: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4',
    teams: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z',
    work: 'M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
    customer: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z'
  };

  onMount(async () => {
    if (isAuthenticated) {
      try {
        currentUserData = await api.users.whoami();
        isLoadingProfile = false;
      } catch (error) {
        isLoadingProfile = false;
      }
    }

    function handleResize() {
      if (!isUserToggled) {
        const isDesktop = window.innerWidth >= 1024;
        isDrawerOpen = isDesktop;
      }
    }

    handleResize();
    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  });

  function isActive(path: string): boolean {
    return currentPath === path;
  }
</script>

<AuthGuard>
  <div class="drawer lg:drawer-open">
    <input id="admin-drawer" type="checkbox" class="drawer-toggle" />
    <div class="drawer-content flex flex-col min-h-screen bg-[#eef0ef]">
      {#if !isDrawerOpen && isUserToggled}
        <button
          class="btn btn-circle bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white fixed top-6 left-6 z-50 hidden lg:flex hover:shadow-lg shadow-[#0277EE]/30"
          onclick={toggleDrawer}
          title="Abrir menu"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
      {/if}

      <TopBar showMenuButton={true} />

      <Breadcrumbs />

      <div class="flex-1 container px-6 lg:px-12 py-6">
        {@render children()}
      </div>

      <Footer />
    </div>

    <div class="drawer-side">
      <label for="admin-drawer" class="drawer-overlay"></label>

      <div class={`flex flex-col min-h-full bg-white border-r border-gray-200 transition-all duration-300 ${
        isUserToggled && !isDrawerOpen ? 'w-20' : 'w-80'
      }`}>

        <div class="border-b border-gray-100 p-4 flex items-center justify-between gap-2">
          {#if !(isUserToggled && !isDrawerOpen)}
            <a
              href="/"
              onclick={(e) => {
 e.preventDefault(); router.navigate('/');
}}
              class="text-2xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent hover:scale-105 transition-transform duration-300"
            >
               <img
                src={logoProcStudio}
                alt="Logotipo do ProcStudio"
              class="h-25 w-auto"
              />
            </a>
          {/if}

          <button
            class="btn btn-ghost btn-sm hidden lg:flex ml-auto"
            onclick={toggleDrawer}
            title={isDrawerOpen ? 'Recolher menu' : 'Expandir menu'}
          >
            <svg class="w-5 h-5 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d={isDrawerOpen ? 'M15 19l-7-7 7-7' : 'M9 5l7 7-7 7'}
              ></path>
            </svg>
          </button>

          {#if !(isUserToggled && !isDrawerOpen)}
            <label for="admin-drawer" class="lg:hidden btn btn-ghost btn-sm">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </label>
          {/if}
        </div>

        <nav class="flex-1 px-2 py-4 overflow-y-auto">
          <ul class="space-y-1">
            {#each menuItems as item (item.path)}
              <li>
                <a
                  href={item.path}
                  onclick={(e) => {
                    e.preventDefault();
                    router.navigate(item.path);
                    closeDrawer();
                  }}
                  class={`flex items-center gap-4 px-4 py-3 rounded-lg font-medium transition-all duration-300 group ${
                    isActive(item.path)
                      ? 'bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white shadow-lg shadow-[#0277EE]/30'
                      : 'text-gray-700 hover:bg-[#eef0ef] hover:text-[#0277EE]'
                  }`}
                >
                  <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={iconPaths[item.icon]}></path>
                  </svg>
                  {#if !(isUserToggled && !isDrawerOpen)}
                    <span>{item.label}</span>
                  {/if}
                </a>
              </li>
            {/each}
          </ul>
        </nav>

        {#if isAuthenticated}
          <div class="border-t border-gray-100 p-2 relative">
            <button
              onclick={toggleUserDropdown}
              onblur={() => setTimeout(closeUserDropdown, 200)}
              class={`flex items-center gap-3 w-full p-3 rounded-lg cursor-pointer transition-all duration-300 hover:bg-[#eef0ef] ${
                isUserToggled && !isDrawerOpen ? 'justify-center' : ''
              }`}
            >
              <div class="avatar placeholder flex-shrink-0">
                <div class="bg-gradient-to-br from-[#0277EE] to-[#01013D] text-white rounded-full w-10 h-10">
                  {#if userAvatarUrl}
                    <img
                      src={userAvatarUrl}
                      alt="Avatar"
                      class="rounded-full w-full h-full object-cover"
                    />
                  {:else}
                    <span class="flex items-center justify-center w-full h-full font-bold text-sm">
                      {userInitials}
                    </span>
                  {/if}
                </div>
              </div>

              {#if !(isUserToggled && !isDrawerOpen)}
                <div class="flex-1 min-w-0 text-left">
                  {#if isLoadingProfile}
                    <div class="loading loading-spinner loading-xs"></div>
                  {:else}
                    <div class="text-sm font-semibold text-gray-900 truncate">
                      {userDisplayName}
                    </div>
                    {#if userRole}
                      <div class="text-xs text-gray-500 truncate">
                        {userRole}
                      </div>
                    {/if}
                  {/if}
                </div>

                <svg class={`w-4 h-4 text-gray-400 flex-shrink-0 transition-transform duration-300 ${isUserDropdownOpen ? 'rotate-180' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              {/if}
            </button>

            {#if isUserDropdownOpen}
              <div class="absolute bottom-full left-2 right-2 mb-2 bg-white rounded-xl shadow-xl border border-gray-100 z-50 animate-in fade-in slide-in-from-bottom-2 duration-200">
                <ul class="w-full py-1">
                  <li class="px-4 py-3 border-b border-gray-100">
                    <div class="flex items-center gap-3">
                      <div class="avatar placeholder">
                        <div class="bg-gradient-to-br from-[#0277EE] to-[#01013D] text-white rounded-full w-10 h-10">
                          {#if userAvatarUrl}
                            <img
                              src={userAvatarUrl}
                              alt="Avatar"
                              class="rounded-full w-full h-full object-cover"
                            />
                          {:else}
                            <span class="flex items-center justify-center w-full h-full font-bold text-sm">
                              {userInitials}
                            </span>
                          {/if}
                        </div>
                      </div>
                      <div>
                        <div class="font-semibold text-gray-900 text-sm">{userDisplayName}</div>
                        {#if userRole}
                          <div class="text-xs text-gray-500">{userRole}</div>
                        {/if}
                      </div>
                    </div>
                  </li>

                  {#if userEmail}
                    <li class="px-4 py-2 text-xs text-gray-500 border-b border-gray-100">
                      {userEmail}
                    </li>
                  {/if}

                  <li>
                    <button
                      class="w-full text-left px-4 py-2.5 text-sm text-gray-700 hover:bg-[#eef0ef] hover:text-[#0277EE] transition-colors flex items-center gap-2"
                      onclick={handleUserClick}
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                      </svg>
                      Meu Perfil
                    </button>
                  </li>

                  <li>
                    <button class="w-full text-left px-4 py-2.5 text-sm text-gray-700 hover:bg-[#eef0ef] hover:text-[#0277EE] transition-colors flex items-center gap-2">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                      Ajuda
                    </button>
                  </li>

                  <li>
                    <button class="w-full text-left px-4 py-2.5 text-sm text-gray-700 hover:bg-[#eef0ef] hover:text-[#0277EE] transition-colors flex items-center gap-2">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5 0a4 4 0 11-8 0 4 4 0 018 0z"></path>
                      </svg>
                      Suporte
                    </button>
                  </li>

                  <li class="border-t border-gray-100">
                    <button
                      class="w-full text-left px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors flex items-center gap-2 font-medium"
                      onclick={handleLogout}
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                      </svg>
                      Sair
                    </button>
                  </li>
                </ul>
              </div>
            {/if}
          </div>
        {/if}
      </div>
    </div>
  </div>
</AuthGuard>

<style>
  :global(.drawer-overlay) {
    background-color: rgba(1, 1, 61, 0.3);
  }

  :global(.drawer-side) {
    background: transparent;
  }
</style>
