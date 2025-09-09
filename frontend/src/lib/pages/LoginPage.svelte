<script>
  import { onMount } from 'svelte';
  import AuthLayout from '../components/AuthLayout.svelte';
  import { authStore } from '../stores/authStore.js';
  import { router } from '../stores/routerStore.js';
  import api from '../api/index';
  import Icon from '../icons.svelte';

  let email = '';
  let password = '';
  let isLoading = false;
  let errorMessage = '';
  let successMessage = '';

  onMount(() => {
    // Check for auth error from AuthGuard
    if (typeof window !== 'undefined') {
      const authError = window.sessionStorage.getItem('authError');
      if (authError) {
        errorMessage = authError;
        window.sessionStorage.removeItem('authError');
      }
    }
  });

  async function handleLogin() {
    if (!email || !password) {
      errorMessage = 'E-mail e senha são obrigatórios';
      return;
    }

    isLoading = true;
    errorMessage = '';

    try {
      const result = await api.auth.login(email, password);

      if (result.success) {
        successMessage = result.message || 'Login realizado com sucesso!';

        // Limpa o formulário
        email = '';
        password = '';

        // Pode precisar ajustar baseado na estrutura do authStore
        authStore.loginSuccess(result);

        // Check if there's a redirect URL stored
        const redirectUrl = window.sessionStorage.getItem('redirectAfterLogin');
        if (redirectUrl) {
          window.sessionStorage.removeItem('redirectAfterLogin');
          router.navigate(redirectUrl);
        } else {
          router.navigate('/dashboard');
        }
      } else {
        errorMessage = result.message || 'Erro no login';
      }
    } catch (error) {
      // console.error('Login error:', error);
      errorMessage = error?.data?.message || error?.message || 'Erro no login. Tente novamente.';
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
        <Icon name="arrow-left" className="h-4 w-4 mr-2" />
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

        <!-- Mensagens -->
        {#if errorMessage}
          <div class="alert alert-error">
            <Icon name="error" className="stroke-current shrink-0 h-6 w-6" />
            <span>{errorMessage}</span>
          </div>
        {/if}

        {#if successMessage}
          <div class="alert alert-success">
            <Icon name="success" className="stroke-current shrink-0 h-6 w-6" />
            <span>{successMessage}</span>
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
        <button class="link link-primary text-sm">Esqueci minha senha</button>
      </div>

      <!-- Divider -->
      <div class="divider">ou</div>

      <!-- Link para registro -->
      <div class="text-center">
        <p class="text-sm text-base-content opacity-70 mb-3">Não tem uma conta?</p>
        <button class="btn btn-outline btn-primary w-full" on:click={goToRegister}>
          Criar nova conta
        </button>
      </div>
    </div>
  </div>
</AuthLayout>
