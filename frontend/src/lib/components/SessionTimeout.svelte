<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { authStore } from '../stores/authStore';
  import { router } from '../stores/routerStore';

  interface Props {
    timeoutMinutes?: number;
    warningMinutes?: number;
  }

  let {
    timeoutMinutes = 30,
    warningMinutes = 5
  }: Props = $props();

  let timeoutId;
  let warningId;
  let showWarning = $state(false);
  let remainingTime = $state(warningMinutes);

  let isAuthenticated = $derived($authStore.isAuthenticated);

  function resetTimer() {
    clearTimeout(timeoutId);
    clearTimeout(warningId);
    showWarning = false;
    remainingTime = warningMinutes;

    if (isAuthenticated) {
      warningId = setTimeout(
        () => {
          showWarning = true;
          startCountdown();
        },
        (timeoutMinutes - warningMinutes) * 60 * 1000
      );

      timeoutId = setTimeout(
        () => {
          handleTimeout();
        },
        timeoutMinutes * 60 * 1000
      );
    }
  }

  function startCountdown() {
    const interval = setInterval(() => {
      remainingTime--;
      if (remainingTime <= 0) {
        clearInterval(interval);
      }
    }, 60000);
  }

  function handleTimeout() {
    showWarning = false;
    authStore.logout();
    window.sessionStorage.setItem(
      'authError',
      'Sua sessão expirou. Por favor, faça login novamente.'
    );
    router.navigate('/login');
  }

  function extendSession() {
    resetTimer();
  }

  onMount(() => {
    if (isAuthenticated) {
      resetTimer();

      const events = ['mousedown', 'keydown', 'scroll', 'touchstart'];
      events.forEach((event) => {
        document.addEventListener(event, resetTimer);
      });

      return () => {
        events.forEach((event) => {
          document.removeEventListener(event, resetTimer);
        });
      };
    }
  });

  onDestroy(() => {
    clearTimeout(timeoutId);
    clearTimeout(warningId);
  });

  $effect(() => {
    if (isAuthenticated) {
      resetTimer();
    } else {
      clearTimeout(timeoutId);
      clearTimeout(warningId);
    }
  });
</script>

{#if showWarning}
  <div class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-in fade-in duration-300">
    <div class="bg-white rounded-2xl shadow-2xl max-w-md w-full p-8 animate-in zoom-in-95 slide-in-from-bottom-4 duration-300">
      <div class="flex items-center justify-center w-12 h-12 rounded-full bg-amber-100 mb-6 mx-auto">
        <svg
          class="w-6 h-6 text-amber-600"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
      </div>

      <h3 class="text-2xl font-bold text-gray-900 text-center mb-2">
        Sessão Expirando
      </h3>
      <p class="text-gray-600 text-center mb-6">
        Sua sessão expirará em <span class="font-bold text-amber-600">{remainingTime}</span>
        <span class="text-gray-600">{remainingTime === 1 ? 'minuto' : 'minutos'}</span>. Deseja continuar?
      </p>

      <div class="bg-amber-50 border border-amber-200 rounded-lg p-4 mb-6">
        <p class="text-sm text-amber-900">
          Por sua segurança, a sessão será encerrada automaticamente após {timeoutMinutes} minutos de inatividade.
        </p>
      </div>

      <div class="flex gap-3">
        <button
          class="flex-1 px-6 py-3 rounded-lg font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
          onclick={() => authStore.logout()}
        >
          Sair
        </button>
        <button
          class="flex-1 px-6 py-3 rounded-lg font-medium bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white hover:shadow-lg hover:shadow-[#0277EE]/30 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
          onclick={extendSession}
        >
          Continuar Sessão
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  @keyframes slideInFromBottom {
    from {
      transform: translateY(16px);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }

  @keyframes zoomIn {
    from {
      transform: scale(0.95);
      opacity: 0;
    }
    to {
      transform: scale(1);
      opacity: 1;
    }
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  :global(.animate-in) {
    animation: fadeIn 0.3s ease-out;
  }

  :global(.fade-in) {
    animation: fadeIn 0.3s ease-out;
  }

  :global(.duration-300) {
    animation-duration: 0.3s;
  }

  :global(.zoom-in-95) {
    animation: zoomIn 0.3s ease-out;
  }

  :global(.slide-in-from-bottom-4) {
    animation: slideInFromBottom 0.3s ease-out;
  }
</style>
