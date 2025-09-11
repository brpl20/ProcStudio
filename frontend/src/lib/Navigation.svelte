<script>
  import { authStore } from './stores/authStore';

  export let currentPage = 'home';
  export let onNavigate = () => {};

  function navigateTo(page) {
    onNavigate(page);
  }

  function handleLogout() {
    authStore.logout();
  }
</script>

<nav class="navbar bg-base-200 rounded-box shadow-lg mb-6">
  <div class="navbar-start">
    <button
      class="btn btn-ghost"
      class:btn-active={currentPage === 'home'}
      on:click={() => navigateTo('home')}
      disabled={currentPage === 'home'}
    >
      🏠 Home
    </button>
    <button
      class="btn btn-ghost"
      class:btn-active={currentPage === 'teams'}
      on:click={() => navigateTo('teams')}
      disabled={currentPage === 'teams'}
    >
      👥 Times
    </button>
  </div>
  <div class="navbar-end">
    <button class="btn btn-outline btn-error" on:click={handleLogout}> 🚪 Sair </button>
  </div>
</nav>
