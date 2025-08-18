<script lang="ts">
  import { api } from './api';

  let email = '';
  let password = '';
  let loading = false;
  let message = '';
  let isSuccess = false;

  export let onLoginSuccess: (result: any) => void = () => {};

  async function handleSubmit() {
    if (!email || !password) {
      message = 'E-mail e senha são obrigatórios';
      isSuccess = false;
      return;
    }

    loading = true;
    message = '';

    try {
      const result = await api.login(email, password);
      message = 'Login realizado com sucesso!';
      isSuccess = true;

      // Chama a função de callback para notificar o login
      onLoginSuccess(result);

      // Limpa o formulário
      email = '';
      password = '';
    } catch (error) {
      message = error.message;
      isSuccess = false;
    } finally {
      loading = false;
    }
  }
</script>

<div>
  <h3>Login</h3>

  <form on:submit|preventDefault={handleSubmit}>
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
