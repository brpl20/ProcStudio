<script lang="ts">
  import { onMount } from 'svelte';
  import { authStore } from '../stores/authStore';
  import { router } from '../stores/routerStore';
  import Icon from '../icons/icons.svelte';

  let {
    requireAuth = true,
    redirectTo = '/login',
    message = 'Você precisa estar autenticado para acessar esta página.',
    children
  }: {
    requireAuth?: boolean;
    redirectTo?: string;
    message?: string;
  } = $props();

  let isAuthenticated = $derived($authStore.isAuthenticated);

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

  $effect(() => {
    if (requireAuth) {
      checkAuth();
    }
  });
</script>

{#if !requireAuth || isAuthenticated}
  {@render children()}
{:else}
  <div class="hero min-h-screen bg-base-200">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <div class="alert alert-warning">
          <Icon name="warning" className="stroke-current shrink-0 h-6 w-6" />
          <span>{message}</span>
        </div>
        <div class="mt-4">
          <button class="btn btn-primary" onclick={() => router.navigate(redirectTo)}>
            Fazer Login
          </button>
        </div>
      </div>
    </div>
  </div>
{/if}
