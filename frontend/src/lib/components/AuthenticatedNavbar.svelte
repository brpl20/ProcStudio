<script>
  import { authStore } from '../stores/authStore.js';
  import { router } from '../stores/routerStore.js';
  import Icon from '../icons.svelte';

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
        <Icon name="hamburger" />
      </div>
      <ul
        tabindex="0"
        class="menu menu-sm dropdown-content bg-base-100 rounded-box z-[1] mt-3 w-52 p-2 shadow"
      >
        <li><a on:click={() => navigateTo('/dashboard')}>🏠 Dashboard1</a></li>
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
      <Icon name="search" />
    </button>

    <button class="btn btn-ghost btn-circle">
      <div class="indicator">
        <Icon name="notification" />
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
