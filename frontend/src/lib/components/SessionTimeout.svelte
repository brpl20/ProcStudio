<script>
  import { onMount, onDestroy } from 'svelte';
  import { authStore } from '../stores/authStore.js';
  import { router } from '../stores/routerStore.js';

  export let timeoutMinutes = 30; // Default 30 minutes
  export let warningMinutes = 5; // Show warning 5 minutes before timeout

  let timeoutId;
  let warningId;
  let showWarning = false;
  let remainingTime = warningMinutes;

  $: isAuthenticated = $authStore.isAuthenticated;

  function resetTimer() {
    clearTimeout(timeoutId);
    clearTimeout(warningId);
    showWarning = false;
    remainingTime = warningMinutes;

    if (isAuthenticated) {
      // Set warning timer
      warningId = setTimeout(
        () => {
          showWarning = true;
          startCountdown();
        },
        (timeoutMinutes - warningMinutes) * 60 * 1000
      );

      // Set logout timer
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
    }, 60000); // Update every minute
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

      // Reset timer on user activity
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

  $: if (isAuthenticated) {
    resetTimer();
  } else {
    clearTimeout(timeoutId);
    clearTimeout(warningId);
  }
</script>

{#if showWarning}
  <div class="modal modal-open">
    <div class="modal-box">
      <h3 class="font-bold text-lg">Sessão Expirando</h3>
      <p class="py-4">
        Sua sessão expirará em {remainingTime}
        {remainingTime === 1 ? 'minuto' : 'minutos'}. Deseja continuar?
      </p>
      <div class="modal-action">
        <button class="btn btn-primary" on:click={extendSession}> Continuar Sessão </button>
        <button class="btn btn-ghost" on:click={() => authStore.logout()}> Sair </button>
      </div>
    </div>
  </div>
{/if}
