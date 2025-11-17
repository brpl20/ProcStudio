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
      if (typeof window !== 'undefined') {
        window.sessionStorage.setItem('redirectAfterLogin', window.location.pathname);
        window.sessionStorage.setItem('authError', message);
      }
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
  <div class="w-full min-h-screen bg-gradient-to-br from-[#01013D]/5 via-white to-[#0277EE]/5 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] p-8 sm:p-10">
        <div class="flex justify-center mb-6">
          <div class="w-16 h-16 rounded-full bg-gradient-to-br from-[#0277EE]/20 to-[#01013D]/20 flex items-center justify-center">
            <svg class="w-8 h-8 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
          </div>
        </div>

        <h1 class="text-2xl font-bold text-[#01013D] text-center mb-2">
          Acesso Restrito
        </h1>
        
        <div class="bg-amber-50 border-l-4 border-amber-500 rounded-lg p-4 mb-8">
          <div class="flex gap-3">
            <svg class="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
            <div>
              <p class="text-amber-900 font-semibold text-sm">{message}</p>
            </div>
          </div>
        </div>

        <button 
          class="w-full px-6 py-3 rounded-xl font-semibold bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white hover:shadow-lg hover:shadow-[#0277EE]/30 transition-all duration-300 flex items-center justify-center gap-2"
          onclick={() => router.navigate(redirectTo)}
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
          </svg>
          Fazer Login
        </button>

        <p class="text-center text-gray-500 text-sm mt-6">
          Se você acredita que isso é um erro, entre em contato com o suporte.
        </p>
      </div>
    </div>
  </div>
{/if}
