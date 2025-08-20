<script>
  import Register from '../Register.svelte';
  import { authStore } from '../stores/authStore.js';
  import { router } from '../stores/routerStore.js';
  
  function handleRegisterSuccess() {
    authStore.registerSuccess();
    router.navigate('/login');
  }
  
  function goToLogin() {
    router.navigate('/login');
  }
  
  function goHome() {
    router.navigate('/');
  }
</script>

<div class="min-h-screen bg-base-100 flex items-center justify-center">
  <div class="card bg-base-100 shadow-xl w-full max-w-md">
    <div class="card-body">
      <button class="btn btn-ghost btn-sm self-start" on:click={goHome}>
        ← Voltar ao Início
      </button>
      
      <h2 class="card-title text-2xl justify-center mb-4">Criar Conta</h2>
      
      <Register onRegisterSuccess={handleRegisterSuccess} />
      
      <div class="divider"></div>
      
      <div class="text-center">
        <p class="mb-2">Já tem conta?</p>
        <button class="btn btn-outline btn-primary" on:click={goToLogin}>
          Fazer Login
        </button>
      </div>
    </div>
  </div>
</div>