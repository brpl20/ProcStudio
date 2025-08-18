<script lang="ts">
  import { api } from './api';
  import { validateAndNormalizeOab } from './oabValidator';

  let email = '';
  let password = '';
  let passwordConfirmation = '';
  let oab = '';
  let loading = false;
  let message = '';
  let isSuccess = false;

  async function handleSubmit() {
    if (!email || !password || !passwordConfirmation || !oab) {
      message = 'Todos os campos são obrigatórios';
      isSuccess = false;
      return;
    }

    if (password !== passwordConfirmation) {
      message = 'As senhas não coincidem';
      isSuccess = false;
      return;
    }

    // Validação e normalização da OAB
    const oabValidation = validateAndNormalizeOab(oab);
    if (!oabValidation.isValid) {
      message = oabValidation.error || 'OAB inválida';
      isSuccess = false;
      return;
    }

    loading = true;
    message = '';

    try {
      const result = await api.register(email, password, oabValidation.normalizedOab as string);
      message = 'Registro realizado com sucesso!';
      isSuccess = true;

      // Limpa o formulário
      email = '';
      password = '';
      passwordConfirmation = '';
      oab = '';
    } catch (error: any) {
      message = error.message;
      isSuccess = false;
    } finally {
      loading = false;
    }
  }
</script>

<div>
  <h3>Registro</h3>

  <form on:submit|preventDefault={handleSubmit}>
    <div>
      <label for="email">E-mail:</label>
      <input type="email" id="email" bind:value={email} required disabled={loading} />
    </div>

    <div>
      <label for="password">Senha:</label>
      <input type="password" id="password" bind:value={password} required disabled={loading} />
    </div>

    <div>
      <label for="password-confirmation">Confirmar Senha:</label>
      <input
        type="password"
        id="password-confirmation"
        bind:value={passwordConfirmation}
        required
        disabled={loading}
      />
    </div>

    <div>
      <label for="oab">OAB:</label>
      <input
        type="text"
        id="oab"
        bind:value={oab}
        placeholder="PR_54159"
        required
        disabled={loading}
      />
    </div>

    <button type="submit" disabled={loading}>
      {loading ? 'Registrando...' : 'Registrar'}
    </button>
  </form>

  {#if message}
    <p style="color: {isSuccess ? 'green' : 'red'}">
      {message}
    </p>
  {/if}
</div>
