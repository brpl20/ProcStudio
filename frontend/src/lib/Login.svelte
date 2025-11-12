<script lang="ts">
  import api from './api/index';
  import type { LoginResponse } from './api/index';

  let {
    onLoginSuccess = () => {}
  }: {
    onLoginSuccess?: (result: LoginResponse) => void;
  } = $props();

  let email = $state('');
  let password = $state('');
  let loading = $state(false);
  let message = $state('');
  let isSuccess = $state(false);

  async function handleSubmit() {
    if (!email || !password) {
      message = 'E-mail e senha são obrigatórios';
      isSuccess = false;
      return;
    }

    loading = true;
    message = '';

    try {
      const result = await api.auth.login(email, password);

      if (result.success) {
        message = result.message || 'Login realizado com sucesso!';
        isSuccess = true;
        onLoginSuccess(result);

        // Limpa o formulário
        email = '';
        password = '';
      } else {
        message = result.message || 'Erro no login';
        isSuccess = false;
      }
    } catch (error: any) {
      message = error?.data?.message || error?.message || 'Erro no login. Tente novamente.';
      isSuccess = false;
    } finally {
      loading = false;
    }
  }
</script>

<div>
  <h3>Login</h3>

  <form onsubmit={(e) => {
    e.preventDefault();
    handleSubmit(e);
  }}>
    <div>
      <label for="login-email">E-mail:</label>
      <input type="email" id="login-email" bind:value={email} required disabled={loading} />
    </div>

    <div>
      <label for="login-password">Senha:</label>
      <input
        type="password"
        id="login-password"
        bind:value={password}
        required
        disabled={loading}
      />
    </div>

    <button type="submit" disabled={loading}>
      {loading ? 'Entrando...' : 'Entrar'}
    </button>
  </form>

  {#if message}
    <p style="color: {isSuccess ? 'green' : 'red'}">
      {message}
    </p>
  {/if}
</div>
