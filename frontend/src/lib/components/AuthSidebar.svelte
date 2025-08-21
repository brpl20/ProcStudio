<script>
  import { WebsiteName } from '../config.js';
  import { authStore } from '../stores/authStore.js';
  import { router } from '../stores/routerStore.js';
  import Icon from '../icons.svelte';

  export const activeSection = '';

  $: isAuthenticated = $authStore.isAuthenticated;
  $: currentPath = $router.currentPath;

  function handleLogout() {
    authStore.logout();
    router.navigate('/');
  }

  function closeDrawer() {
    const adminDrawer = document.getElementById('admin-drawer');
    if (adminDrawer) {
      adminDrawer.checked = false;
    }
  }
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

      <!-- Equipes (já existente) -->
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
