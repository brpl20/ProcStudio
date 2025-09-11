<script>
  import { onMount } from 'svelte';
  import { authStore } from '../stores/authStore';
  import { router } from '../stores/routerStore.js';
  import Icon from '../icons/icons.svelte';

  export let requireAuth = true;
  export let redirectTo = '/login';
  export let message = 'Você precisa estar autenticado para acessar esta página.';

  $: isAuthenticated = $authStore.isAuthenticated;

  onMount(() => {
    checkAuth();
  });

  function checkAuth() {
    if (requireAuth && !isAuthenticated) {
      // Store the intended destination
      if (typeof window !== 'undefined') {
        window.sessionStorage.setItem('redirectAfterLogin', window.location.pathname);
      }
      // Show error message
      if (message && typeof window !== 'undefined') {
        window.sessionStorage.setItem('authError', message);
      }
      // Redirect to login
      router.navigate(redirectTo);
    }
  }

  $: if (requireAuth) {
    checkAuth();
  }
</script>

{#if !requireAuth || isAuthenticated}
  <slot />
{:else}
  <div class="hero min-h-screen bg-base-200">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <div class="alert alert-warning">
          <Icon name="warning" className="stroke-current shrink-0 h-6 w-6" />
          <span>{message}</span>
        </div>
        <div class="mt-4">
          <button class="btn btn-primary" on:click={() => router.navigate(redirectTo)}>
            Fazer Login
          </button>
        </div>
      </div>
    </div>
  </div>
{/if}
