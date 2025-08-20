<script>
  import { authStore } from '../stores/authStore.js';
  import { router } from '../stores/routerStore.js';

  function handleLogout() {
    authStore.logout();
  }

  function navigateTo(path) {
    router.navigate(path);
  }
</script>

<div class="navbar bg-base-100 shadow-sm">
  <div class="navbar-start">
    <div class="dropdown">
      <div tabindex="0" role="button" class="btn btn-ghost btn-circle">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-5 w-5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 6h16M4 12h16M4 18h7"
          />
        </svg>
      </div>
      <ul
        tabindex="0"
        class="menu menu-sm dropdown-content bg-base-100 rounded-box z-[1] mt-3 w-52 p-2 shadow"
      >
        <li><a on:click={() => navigateTo('/dashboard')}>🏠 Dashboard</a></li>
        <li><a on:click={() => navigateTo('/teams')}>👥 Equipes</a></li>
        <li><a on:click={() => navigateTo('/documents')}>📄 Documentos</a></li>
        <li><a on:click={() => navigateTo('/reports')}>📊 Relatórios</a></li>
        <li><a on:click={() => navigateTo('/settings')}>⚙️ Configurações</a></li>
      </ul>
    </div>
  </div>

  <div class="navbar-center">
    <button class="btn btn-ghost text-xl" on:click={() => navigateTo('/dashboard')}>
      ⚖️ ProcStudio
    </button>
  </div>

  <div class="navbar-end">
    <button class="btn btn-ghost btn-circle">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-5 w-5"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
        />
      </svg>
    </button>

    <button class="btn btn-ghost btn-circle">
      <div class="indicator">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-5 w-5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
          />
        </svg>
        <span class="badge badge-xs badge-primary indicator-item"></span>
      </div>
    </button>

    <div class="dropdown dropdown-end">
      <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar">
        <div class="w-8 rounded-full bg-primary flex items-center justify-center">
          <span class="text-primary-content text-sm font-bold">U</span>
        </div>
      </div>
      <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box z-[1] w-52 p-2 shadow">
        <li><a on:click={() => navigateTo('/profile')}>👤 Perfil</a></li>
        <li><a on:click={() => navigateTo('/settings')}>⚙️ Configurações</a></li>
        <li><hr /></li>
        <li><a on:click={handleLogout} class="text-error">🚪 Sair</a></li>
      </ul>
    </div>
  </div>
</div>
