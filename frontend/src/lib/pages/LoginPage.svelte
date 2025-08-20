<script>
  import Login from '../Login.svelte';
  import MainLayout from '../components/MainLayout.svelte';
  import { authStore } from '../stores/authStore.js';
  import { router } from '../stores/routerStore.js';

  function handleLoginSuccess(userData) {
    authStore.loginSuccess(userData);
    router.navigate('/dashboard');
  }

  function goToRegister() {
    router.navigate('/register');
  }
</script>

<MainLayout showFooter={false}>
  <div class="flex items-center justify-center min-h-[70vh]">
    <div class="card bg-base-100 shadow-xl w-full max-w-md">
      <div class="card-body">
        <h2 class="card-title text-2xl justify-center mb-4">Entrar</h2>

        <Login onLoginSuccess={handleLoginSuccess} />

        <div class="divider"></div>

        <div class="text-center">
          <p class="mb-2">Não tem conta?</p>
          <button class="btn btn-outline btn-primary" on:click={goToRegister}> Criar Conta </button>
        </div>
      </div>
    </div>
  </div>
</MainLayout>
