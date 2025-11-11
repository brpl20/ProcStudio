<script>
  import { onMount } from 'svelte';
  import { router } from '../stores/routerStore';
  import Icon from '../icons/icons.svelte';

  export let error = null;
  export let message = 'Algo deu errado. Por favor, tente novamente.';
  export let showRetry = true;
  export let showHome = true;

  function handleRetry() {
    window.location.reload();
  }

  function handleGoHome() {
    router.navigate('/dashboard');
  }
</script>

{#if error}
  <div class="hero min-h-screen bg-base-200">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <h1 class="text-5xl font-bold mb-4">Oops!</h1>
        <div class="alert alert-error mb-6">
          <Icon name="error" className="stroke-current shrink-0 h-6 w-6" />
          <span>{message}</span>
        </div>

        {#if error.message}
          <div class="text-sm text-base-content/70 mb-6">
            Detalhes: {error.message}
          </div>
        {/if}

        <div class="flex gap-2 justify-center">
          {#if showRetry}
            <button class="btn btn-primary" onclick={handleRetry}> Tentar Novamente </button>
          {/if}

          {#if showHome}
            <button class="btn btn-outline" onclick={handleGoHome}> Ir para Início </button>
          {/if}
        </div>
      </div>
    </div>
  </div>
{:else}
  <slot />
{/if}
