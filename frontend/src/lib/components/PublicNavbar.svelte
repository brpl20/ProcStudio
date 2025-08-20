<script>
  import { router } from '../stores/routerStore.js';
  
  function navigateToLogin() {
    router.navigate('/login');
  }
  
  function navigateToRegister() {
    router.navigate('/register');
  }
  
  function navigateHome() {
    router.navigate('/');
  }
</script>

<div class="navbar bg-base-100 shadow-sm">
  <div class="navbar-start">
    <button class="btn btn-ghost text-xl" on:click={navigateHome}>
      ⚖️ ProcStudio
    </button>
  </div>
  
  <div class="navbar-center hidden lg:flex">
    <ul class="menu menu-horizontal px-1">
      <li><a class="btn btn-ghost">Sobre</a></li>
      <li><a class="btn btn-ghost">Funcionalidades</a></li>
      <li><a class="btn btn-ghost">Contato</a></li>
    </ul>
  </div>
  
  <div class="navbar-end">
    <div class="flex gap-2">
      <button class="btn btn-outline btn-primary" on:click={navigateToLogin}>
        Entrar
      </button>
      <button class="btn btn-primary" on:click={navigateToRegister}>
        Registrar
      </button>
    </div>
  </div>
</div>