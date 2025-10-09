<script>
  import { onMount, onDestroy } from 'svelte';
  import { authStore } from './lib/stores/authStore';
  import { usersCacheStore } from './lib/stores/usersCacheStore';
  import { router } from './lib/router/router.svelte';
  import { routes } from './lib/router/routes';
  import SessionTimeout from './lib/components/SessionTimeout.svelte';
  import ProfileCompletionEnhanced from './lib/pages/ProfileCompletionEnhanced.svelte';
  
  // Initialize router with routes
  router.setRoutes(routes);
  
  // Reactive state using Svelte 5 patterns
  let currentRoute = $derived(router.currentRoute);
  let routeParams = $derived(router.params);
  let isNavigating = $derived(router.isNavigating);
  
  // Auth state
  let { isAuthenticated, showProfileCompletion, profileData, missingFields } = $state(authStore);
  
  // Dynamic component loading
  let CurrentComponent = $state(null);
  let componentError = $state(null);
  
  // Load component when route changes
  $effect(async () => {
    if (!currentRoute?.route) {
      CurrentComponent = null;
      return;
    }
    
    componentError = null;
    
    try {
      const component = currentRoute.route.component;
      
      // Handle lazy-loaded components
      if (typeof component === 'function') {
        const module = await component();
        CurrentComponent = module.default;
      } else {
        CurrentComponent = component;
      }
    } catch (error) {
      console.error('Failed to load component:', error);
      componentError = error;
      CurrentComponent = null;
    }
  });
  
  function handleProfileCompletion(completionResult) {
    authStore.completeProfile(completionResult);
  }
  
  function handleProfileCompletionClose() {
    authStore.closeProfileCompletion();
  }
  
  onMount(async () => {
    await authStore.init();
    
    // Initialize users cache if authenticated
    if (isAuthenticated) {
      usersCacheStore.initialize().catch((error) => {
        console.error('Failed to initialize users cache:', error);
      });
    }
    
    // Handle initial navigation
    if (isAuthenticated && router.currentPath === '/') {
      router.navigate('/dashboard');
    }
  });
  
  onDestroy(() => {
    router.destroy();
  });
</script>

<!-- Session Timeout Handler -->
<SessionTimeout timeoutMinutes={60} warningMinutes={5} />

<!-- Loading indicator -->
{#if isNavigating}
  <div class="fixed top-0 left-0 right-0 z-50">
    <div class="h-1 bg-primary animate-pulse"></div>
  </div>
{/if}

<!-- Route content -->
<main class="min-h-screen">
  {#if componentError}
    <div class="hero min-h-screen bg-base-200">
      <div class="hero-content text-center">
        <div class="max-w-md">
          <h1 class="text-5xl font-bold">Erro ao carregar página</h1>
          <p class="py-6">Ocorreu um erro ao carregar esta página. Por favor, tente novamente.</p>
          <button 
            class="btn btn-primary" 
            onclick={() => router.reload()}
          >
            Tentar Novamente
          </button>
          <button 
            class="btn btn-ghost" 
            onclick={() => router.navigate('/')}
          >
            Ir para Home
          </button>
        </div>
      </div>
    </div>
  {:else if CurrentComponent}
    <!-- Using key to force re-render on route change if needed -->
    {#key router.currentPath}
      <svelte:component this={CurrentComponent} params={routeParams} />
    {/key}
  {:else if !isNavigating}
    <!-- 404 Page -->
    <div class="hero min-h-screen bg-base-200">
      <div class="hero-content text-center">
        <div class="max-w-md">
          <h1 class="text-5xl font-bold">404</h1>
          <p class="py-6">Página não encontrada</p>
          <button 
            class="btn btn-primary" 
            onclick={() => router.navigate('/')}
          >
            Voltar ao Início
          </button>
        </div>
      </div>
    </div>
  {/if}
</main>

<!-- Profile Completion Modal -->
{#if showProfileCompletion}
  <ProfileCompletionEnhanced
    isOpen={showProfileCompletion}
    userData={profileData}
    {missingFields}
    onComplete={handleProfileCompletion}
    onClose={handleProfileCompletionClose}
  />
{/if}

<style>
  /* Add any global styles here */
</style>