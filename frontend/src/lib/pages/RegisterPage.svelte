<script>
  import AuthLayout from '../components/AuthLayout.svelte';
  import { authStore } from '../stores/authStore';
  import { router } from '../stores/routerStore';
  import api from '../api/index';
  import { validateAndNormalizeOab } from '../validation/oabValidator';
  import PasswordWithValidation from '../components/forms_commons/PasswordWithValidation.svelte';
  import PasswordConfirmation from '../components/forms_commons/PasswordConfirmation.svelte';
  import { validatePassword, DEFAULT_PASSWORD_CONFIG } from '../validation/password-config';

  let email = '';
  let password = '';
  let passwordConfirmation = '';
  let oab = '';
  let isLoading = false;
  let errorMessage = '';
  let successMessage = '';

  async function handleRegister() {
    if (!email || !password || !passwordConfirmation || !oab) {
      errorMessage = 'Todos os campos são obrigatórios';
      return;
    }

    if (password !== passwordConfirmation) {
      errorMessage = 'As senhas não coincidem';
      return;
    }

    // Validate password with the configured requirements
    const passwordValidation = validatePassword(password, DEFAULT_PASSWORD_CONFIG);
    if (!passwordValidation.isValid) {
      errorMessage = passwordValidation.errors.join('. ');
      return;
    }

    // Validação e normalização da OAB
    const oabValidation = validateAndNormalizeOab(oab);
    if (!oabValidation.isValid) {
      errorMessage = oabValidation.error || 'OAB inválida';
      return;
    }

    isLoading = true;
    errorMessage = '';

    try {
      const result = await api.auth.register(email, password, oabValidation.normalizedOab);

      if (result.success) {
        successMessage = 'Registro realizado com sucesso! Você pode fazer login agora.';

        // Limpa o formulário
        email = '';
        password = '';
        passwordConfirmation = '';
        oab = '';

        setTimeout(() => {
          router.navigate('/login');
        }, 2000);
      } else {
        errorMessage = result.message || 'Erro no registro';
      }
    } catch (error) {
      // console.error('Registration error:', error);
      const errorMsg =
        error?.message || error?.data?.message || 'Erro no registro. Tente novamente.';
      errorMessage = errorMsg;
    } finally {
      isLoading = false;
    }
  }

  function goToLogin() {
    router.navigate('/login');
  }

  function goHome() {
    router.navigate('/');
  }
</script>

<AuthLayout>
  <div class="text-center mb-8">
    <h1 class="text-3xl font-bold text-primary mb-2">Criar conta</h1>
    <p class="text-base-content opacity-70">Junte-se a nós e comece hoje mesmo</p>
  </div>

  <div class="card bg-base-100 shadow-xl border">
    <div class="card-body">
      <!-- Botão voltar -->
      <button class="btn btn-ghost btn-sm self-start mb-4" on:click={goHome}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-4 mr-2"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M10 19l-7-7m0 0l7-7m-7 7h18"
          />
        </svg>
        Voltar
      </button>

      <h2 class="text-2xl font-bold text-center mb-6">Registrar-se</h2>

      <!-- Formulário de registro -->
      <form on:submit|preventDefault={handleRegister} class="space-y-4">
        <!-- OAB -->
        <div class="form-control">
          <label class="label" for="oab">
            <span class="label-text font-semibold">OAB</span>
          </label>
          <input
            id="oab"
            type="text"
            placeholder="PR_54159"
            class="input input-bordered w-full"
            bind:value={oab}
            required
            disabled={isLoading}
          />
        </div>

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
        <PasswordWithValidation
          bind:value={password}
          name="password"
          placeholder="Digite sua senha"
          required={true}
          showRequirements={true}
          showStrength={true}
          disabled={isLoading}
        />

        <!-- Confirmar senha -->
        <PasswordConfirmation
          password={password}
          bind:value={passwordConfirmation}
          name="passwordConfirmation"
          placeholder="Confirme sua senha"
          required={true}
          disabled={isLoading}
        />

        <!-- Mensagens -->
        {#if errorMessage}
          <div class="alert alert-error">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="stroke-current shrink-0 h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            <span>{errorMessage}</span>
          </div>
        {/if}

        {#if successMessage}
          <div class="alert alert-success">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="stroke-current shrink-0 h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            <span>{successMessage}</span>
          </div>
        {/if}

        <!-- Botão de registro -->
        <button
          type="submit"
          class="btn btn-primary w-full"
          class:loading={isLoading}
          disabled={isLoading || successMessage}
        >
          {#if isLoading}
            Criando conta...
          {:else if successMessage}
            Conta criada!
          {:else}
            Criar conta
          {/if}
        </button>
      </form>

      <!-- Divider -->
      <div class="divider">ou</div>

      <!-- Link para login -->
      <div class="text-center">
        <p class="text-sm text-base-content opacity-70 mb-3">Já tem uma conta?</p>
        <button class="btn btn-outline btn-primary w-full" on:click={goToLogin}>
          Fazer login
        </button>
      </div>

      <!-- Termos de uso -->
      <div class="text-center mt-6">
        <p class="text-xs text-base-content opacity-60">
          Ao criar uma conta, você concorda com nossos
          <button class="link link-primary">Termos de Uso</button> e
          <button class="link link-primary">Política de Privacidade</button>.
        </p>
      </div>
    </div>
  </div>
</AuthLayout>
