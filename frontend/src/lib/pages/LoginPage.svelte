<script>
  import AuthLayout from '../components/AuthLayout.svelte';
  import { authStore } from '../stores/authStore.js';
  import { router } from '../stores/routerStore.js';
  
  let email = '';
  let password = '';
  let isLoading = false;
  let errorMessage = '';

  async function handleLogin() {
    if (!email || !password) {
      errorMessage = 'Por favor, preencha todos os campos';
      return;
    }

    isLoading = true;
    errorMessage = '';

    try {
      // Simulação de login - substituir pela sua lógica real
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const userData = {
        id: '1',
        email: email,
        name: 'Usuário Teste'
      };
      
      authStore.loginSuccess(userData);
      router.navigate('/dashboard');
    } catch (error) {
      errorMessage = 'Erro ao fazer login. Verifique suas credenciais.';
    } finally {
      isLoading = false;
    }
  }

  function goToRegister() {
    router.navigate('/register');
  }
  
  function goHome() {
    router.navigate('/');
  }
</script>

<AuthLayout>
  <div class="text-center mb-8">
    <h1 class="text-3xl font-bold text-primary mb-2">Bem-vindo de volta</h1>
    <p class="text-base-content opacity-70">Entre na sua conta para continuar</p>
  </div>

  <div class="card bg-base-100 shadow-xl border">
    <div class="card-body">
      <!-- Botão voltar -->
      <button class="btn btn-ghost btn-sm self-start mb-4" on:click={goHome}>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
        Voltar
      </button>

      <h2 class="text-2xl font-bold text-center mb-6">Entrar</h2>

      <!-- Formulário de login -->
      <form on:submit|preventDefault={handleLogin} class="space-y-4">
        <!-- Email -->
        <div class="form-control">
          <label class="label" for="email">
            <span class="label-text font-semibold">Email</span>
          </label>
          <input
            id="email"
            type="email"
            placeholder="Digite seu email"
            class="input input-bordered w-full"
            bind:value={email}
            required
            disabled={isLoading}
          />
        </div>

        <!-- Senha -->
        <div class="form-control">
          <label class="label" for="password">
            <span class="label-text font-semibold">Senha</span>
          </label>
          <input
            id="password"
            type="password"
            placeholder="Digite sua senha"
            class="input input-bordered w-full"
            bind:value={password}
            required
            disabled={isLoading}
          />
        </div>

        <!-- Erro -->
        {#if errorMessage}
          <div class="alert alert-error">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>{errorMessage}</span>
          </div>
        {/if}

        <!-- Botão de login -->
        <button 
          type="submit" 
          class="btn btn-primary w-full"
          class:loading={isLoading}
          disabled={isLoading}
        >
          {#if isLoading}
            Entrando...
          {:else}
            Entrar
          {/if}
        </button>
      </form>

      <!-- Link esqueci a senha -->
      <div class="text-center mt-4">
        <a href="#" class="link link-primary text-sm">Esqueci minha senha</a>
      </div>

      <!-- Divider -->
      <div class="divider">ou</div>

      <!-- Link para registro -->
      <div class="text-center">
        <p class="text-sm text-base-content opacity-70 mb-3">
          Não tem uma conta?
        </p>
        <button class="btn btn-outline btn-primary w-full" on:click={goToRegister}>
          Criar nova conta
        </button>
      </div>
    </div>
  </div>
</AuthLayout>
