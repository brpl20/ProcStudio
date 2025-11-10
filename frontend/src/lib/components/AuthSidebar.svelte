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

  export const activeSection: string = '';

  $: isAuthenticated = $authStore.isAuthenticated;
  $: currentPath = router.currentPath;

  let isDrawerOpen = true;
  let isUserToggled = false;
  let isUserDropdownOpen = false;

  let currentUserData: WhoAmIResponse | null = null;
  let isLoadingProfile = true;

  $: whoAmIUser = currentUserData?.data;
  $: userProfile = whoAmIUser?.attributes?.profile;

  $: userDisplayName = userProfile?.full_name || userProfile?.name || 'Usuário';
  $: userRole = getUserRole(userProfile);
  $: userEmail = whoAmIUser?.attributes?.email || '';
  $: userInitials = getUserInitials(userDisplayName);
  $: userAvatarUrl = userProfile?.avatar_url;

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
    { icon: 'customer', label: 'Clientes', path: '/customers' },
  ];

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
      <!-- Floating toggle button for desktop when drawer is closed -->
      {#if !isDrawerOpen && isUserToggled}
        <button
          class="btn btn-circle bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white fixed top-6 left-6 z-50 hidden lg:flex hover:shadow-lg shadow-[#0277EE]/30"
          on:click={toggleDrawer}
          title="Abrir menu"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
      {/if}

      <!-- Top Bar -->
      <TopBar showMenuButton={true} />

      <!-- Breadcrumbs -->
      <Breadcrumbs />

      <!-- Main Content -->
      <div class="flex-1 container px-6 lg:px-12 py-6">
        <slot />
      </div>

      <!-- Footer -->
      <Footer />
    </div>

    <!-- Sidebar -->
    <div class="drawer-side">
      <label for="admin-drawer" class="drawer-overlay"></label>
      
      <div class={`flex flex-col min-h-full bg-white border-r border-gray-200 transition-all duration-300 ${
        isUserToggled && !isDrawerOpen ? 'w-20' : 'w-80'
      }`}>
        
        <!-- Sidebar Header -->
        <div class="border-b border-gray-100 p-4 flex items-center justify-between gap-2">
          {#if !(isUserToggled && !isDrawerOpen)}
            <a
              href="/"
              on:click|preventDefault={() => router.navigate('/')}
              class="text-2xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent hover:scale-105 transition-transform duration-300"
            >
              {WebsiteName}
            </a>
          {/if}
          
          <!-- Desktop toggle button -->
          <button
            class="btn btn-ghost btn-sm hidden lg:flex ml-auto"
            on:click={toggleDrawer}
            title={isDrawerOpen ? 'Recolher menu' : 'Expandir menu'}
          >
            <svg class="w-5 h-5 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                d={isDrawerOpen ? "M15 19l-7-7 7-7" : "M9 5l7 7-7 7"}
              ></path>
            </svg>
          </button>
          
          {#if !(isUserToggled && !isDrawerOpen)}
            <!-- Mobile close button -->
            <label for="admin-drawer" class="lg:hidden btn btn-ghost btn-sm">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </label>
          {/if}
        </div>

        <!-- Menu Items -->
        <nav class="flex-1 px-2 py-4 overflow-y-auto">
          <ul class="space-y-1">
            {#each menuItems as item (item.path)}
              <li>
                <a
                  href={item.path}
                  on:click|preventDefault={() => {
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
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                  </svg>
                  {#if !(isUserToggled && !isDrawerOpen)}
                    <span>{item.label}</span>
                  {/if}
                </a>
              </li>
            {/each}
          </ul>
        </nav>

        <!-- User Menu Section -->
        {#if isAuthenticated}
          <div class="border-t border-gray-100 p-2 relative">
            <button
              on:click={toggleUserDropdown}
              on:blur={() => setTimeout(closeUserDropdown, 200)}
              class={`flex items-center gap-3 w-full p-3 rounded-lg cursor-pointer transition-all duration-300 hover:bg-[#eef0ef] ${
                isUserToggled && !isDrawerOpen ? 'justify-center' : ''
              }`}
            >
              <div class="avatar placeholder flex-shrink-0">
                <div class="bg-gradient-to-br from-[#0277EE] to-[#01013D] text-white rounded-full w-10 h-10 flex items-center justify-center font-bold text-sm">
                  {#if userAvatarUrl}
                    <img
                      src={userAvatarUrl}
                      alt="Avatar"
                      class="rounded-full w-10 h-10 object-cover"
                    />
                  {:else}
                    {userInitials}
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
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"></path>
                </svg>
              {/if}
            </button>

            <!-- User Dropdown Menu -->
            {#if isUserDropdownOpen}
              <div class="absolute bottom-full left-2 right-2 mb-2 bg-white rounded-xl shadow-xl border border-gray-100 z-50 animate-in fade-in slide-in-from-bottom-2 duration-200">
                <ul class="w-full py-1">
                  <!-- User Info -->
                  <li class="px-4 py-3 border-b border-gray-100">
                    <div class="flex items-center gap-3">
                      <div class="avatar placeholder">
                        <div class="bg-gradient-to-br from-[#0277EE] to-[#01013D] text-white rounded-full w-10 h-10 flex items-center justify-center font-bold">
                          {#if userAvatarUrl}
                            <img
                              src={userAvatarUrl}
                              alt="Avatar"
                              class="rounded-full w-10 h-10 object-cover"
                            />
                          {:else}
                            {userInitials}
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

                  <!-- Profile -->
                  <li>
                    <button
                      class="w-full text-left px-4 py-2.5 text-sm text-gray-700 hover:bg-[#eef0ef] hover:text-[#0277EE] transition-colors flex items-center gap-2"
                      on:click={handleUserClick}
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                      </svg>
                      Meu Perfil
                    </button>
                  </li>

                  <!-- Help & Support -->
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
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5-4a2 2 0 11-4 0 2 2 0 014 0z"></path>
                      </svg>
                      Suporte
                    </button>
                  </li>

                  <!-- Logout -->
                  <li class="border-t border-gray-100">
                    <button
                      class="w-full text-left px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors flex items-center gap-2 font-medium"
                      on:click={handleLogout}
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
