<script>
  import { onMount } from 'svelte';
  import AuthLayout from '../components/AuthLayout.svelte';
  import { authStore } from '../stores/authStore';
  import { router } from '../stores/routerStore';
  import api from '../api/index';
  import Icon from '../icons/icons.svelte';

  let email = '';
  let password = '';
  let isLoading = false;
  let errorMessage = '';
  let successMessage = '';
  let showPassword = false;

  onMount(() => {
    if (typeof window !== 'undefined') {
      const authMessage = window.sessionStorage.getItem('authMessage');
      if (authMessage) {
        errorMessage = authMessage;
        window.sessionStorage.removeItem('authMessage');
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

        email = '';
        password = '';

        authStore.loginSuccess(result);

        await new Promise(resolve => setTimeout(resolve, 0));

        const redirectUrl = window.sessionStorage.getItem('redirectAfterLogin');
        if (redirectUrl) {
          window.sessionStorage.removeItem('redirectAfterLogin');
          await router.navigate(redirectUrl, { skipGuards: true });
        } else {
          await router.navigate('/dashboard', { skipGuards: true });
        }
      } else {
        errorMessage = result.message || 'Erro no login';
      }
    } catch (error) {
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
  <div class="w-full max-w-md mx-auto">
    <!-- Header -->
    <div class="text-center mb-8 animate-fade-in">
      <h1 class="text-4xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent mb-2">
        Bem-vindo de volta
      </h1>
      <p class="text-gray-600 text-lg">Entre na sua conta para continuar</p>
    </div>

    <!-- Form Container -->
    <div class="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100 animate-fade-in-delay-1">
      <!-- Back Button -->
      <button
        class="m-6 mb-0 inline-flex items-center text-gray-600 hover:text-[#0277EE] transition-colors duration-300 font-medium text-sm"
        on:click={goHome}
      >
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
        </svg>
        Voltar
      </button>

      <div class="px-6 pb-8">
        <!-- Title -->
        <h2 class="text-3xl font-bold text-[#01013D] text-center mb-8 mt-4">Entrar</h2>

        <!-- Form -->
        <form on:submit|preventDefault={handleLogin} class="space-y-6">
          <!-- Email Input -->
          <div class="relative">
            <label for="email" class="block text-sm font-semibold text-[#01013D] mb-2">
              Email
            </label>
            <input
              id="email"
              type="email"
              placeholder="seu@email.com"
              class="w-full px-4 py-3 bg-[#eef0ef] border-2 border-transparent rounded-lg text-[#01013D] placeholder-gray-500 focus:border-[#0277EE] focus:outline-none transition-all duration-300"
              bind:value={email}
              required
              disabled={isLoading}
            />
          </div>

          <!-- Password Input -->
          <div class="relative">
            <label for="password" class="block text-sm font-semibold text-[#01013D] mb-2">
              Senha
            </label>
            <div class="relative">
              <input
                id="password"
                type={showPassword ? 'text' : 'password'}
                placeholder="••••••••"
                class="w-full px-4 py-3 bg-[#eef0ef] border-2 border-transparent rounded-lg text-[#01013D] placeholder-gray-500 focus:border-[#0277EE] focus:outline-none transition-all duration-300 pr-12"
                bind:value={password}
                required
                disabled={isLoading}
              />
              <button
                type="button"
                on:click={() => (showPassword = !showPassword)}
                class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-[#0277EE] transition-colors"
              >
                {#if showPassword}
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                  </svg>
                {:else}
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-2.29m5.159-2.892a3 3 0 015.667.992 3.01 3.01 0 01-.165 1.98m7.438 2.1a10.05 10.05 0 01-7.6 3.285m3.356-9.518a6 6 0 00-8.477 8.477M9 21l3-8m6 0l3 8"></path>
                  </svg>
                {/if}
              </button>
            </div>
          </div>

          <!-- Messages -->
          {#if errorMessage}
            <div class="p-4 bg-red-50 border-l-4 border-red-500 rounded-lg flex items-start space-x-3 animate-slide-down">
              <svg class="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
              </svg>
              <span class="text-red-700 font-medium">{errorMessage}</span>
            </div>
          {/if}

          {#if successMessage}
            <div class="p-4 bg-green-50 border-l-4 border-green-500 rounded-lg flex items-start space-x-3 animate-slide-down">
              <svg class="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
              </svg>
              <span class="text-green-700 font-medium">{successMessage}</span>
            </div>
          {/if}

          <!-- Submit Button -->
          <button
            type="submit"
            disabled={isLoading}
            class="w-full py-3 bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-semibold rounded-lg hover:shadow-lg hover:scale-105 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {#if isLoading}
              <span class="flex items-center justify-center">
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Entrando...
              </span>
            {:else}
              Entrar
            {/if}
          </button>
        </form>

        <!-- Forgot Password -->
        <div class="text-center mt-6">
          <button class="text-sm text-[#0277EE] hover:text-[#01013D] font-semibold transition-colors duration-300">
            Esqueci minha senha
          </button>
        </div>

        <!-- Divider -->
        <div class="flex items-center my-8">
          <div class="flex-1 h-px bg-gray-200"></div>
          <span class="px-4 text-gray-500 text-sm font-medium">ou</span>
          <div class="flex-1 h-px bg-gray-200"></div>
        </div>

        <!-- Register Link -->
        <div class="space-y-3">
          <p class="text-center text-gray-600 text-sm">
            Não tem uma conta?
          </p>
          <button
            type="button"
            class="w-full py-3 border-2 border-[#01013D] text-[#01013D] font-semibold rounded-lg hover:bg-[#01013D] hover:text-white transition-all duration-300"
            on:click={goToRegister}
          >
            Criar nova conta
          </button>
        </div>
      </div>
    </div>
  </div>
</AuthLayout>

<style>
  @keyframes fade-in {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .animate-fade-in {
    animation: fade-in 0.8s ease-out;
  }

  .animate-fade-in-delay-1 {
    animation: fade-in 0.8s ease-out 0.2s both;
  }

  @keyframes slide-down {
    from {
      opacity: 0;
      transform: translateY(-10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .animate-slide-down {
    animation: slide-down 0.3s ease-out;
  }
</style>
