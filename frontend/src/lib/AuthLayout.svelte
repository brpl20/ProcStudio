<script>
  import { authStore } from './stores/authStore';
  import Login from './Login.svelte';
  import Register from './Register.svelte';
  import ApiTester from './ApiTester.svelte';

  $: ({ currentView } = $authStore);

  function handleLoginSuccess(userData) {
    authStore.loginSuccess(userData);
  }

  function handleRegisterSuccess() {
    authStore.registerSuccess();
  }

  function switchView() {
    authStore.switchView();
  }
</script>

<div class="card bg-base-100 shadow-xl max-w-4xl mx-auto">
  <div class="card-body">
    <h2 class="card-title text-2xl justify-center mb-4">Autenticação</h2>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <!-- Formulário de Auth -->
      <div>
        {#if currentView === 'login'}
          <Login onLoginSuccess={handleLoginSuccess} />
          <div class="text-center mt-4">
            <p class="mb-2">Não tem conta?</p>
            <button class="btn btn-outline btn-primary" on:click={switchView}>
              Registrar-se
            </button>
          </div>
        {:else}
          <Register onRegisterSuccess={handleRegisterSuccess} />
          <div class="text-center mt-4">
            <p class="mb-2">Já tem conta?</p>
            <button class="btn btn-outline btn-primary" on:click={switchView}> Fazer login </button>
          </div>
        {/if}
      </div>

      <!-- Testes API -->
      <div>
        <ApiTester />
      </div>
    </div>
  </div>
</div>
