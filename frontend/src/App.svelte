<script>
  import { onMount } from 'svelte';
  import { authStore } from './lib/stores/authStore.js';
  import { router } from './lib/stores/routerStore.js';

  // Pages
  import LandingPage from './lib/pages/LandingPage.svelte';
  import LoginPage from './lib/pages/LoginPage.svelte';
  import RegisterPage from './lib/pages/RegisterPage.svelte';
  import DashboardPage from './lib/pages/DashboardPage.svelte';
  import TeamsPage from './lib/pages/TeamsPage.svelte';
  import ProfileCompletion from './lib/ProfileCompletion.svelte';

  // Reactive stores
  $: ({ isAuthenticated, showProfileCompletion, profileData, missingFields } = $authStore);
  $: ({ currentPath } = $router);

  // Route component logic
  $: currentComponent = getComponent(currentPath, isAuthenticated);

  function getComponent(path, isAuth) {
    if (
      !isAuth &&
      (path === '/dashboard' || path === '/teams' || path === '/reports' || path === '/documents')
    ) {
      router.navigate('/login');
      return LoginPage;
    }

    const routes = {
      '/': LandingPage,
      '/login': LoginPage,
      '/register': RegisterPage,
      '/dashboard': DashboardPage,
      '/teams': TeamsPage
    };

    return routes[path] || LandingPage;
  }

  function handleProfileCompletion(completionResult) {
    authStore.completeProfile(completionResult);
  }

  function handleProfileCompletionClose() {
    authStore.closeProfileCompletion();
  }

  onMount(() => {
    authStore.init();
    // Redirecionar usuário autenticado para dashboard se estiver na landing
    if ($authStore.isAuthenticated && $router.currentPath === '/') {
      router.navigate('/dashboard');
    }
  });
</script>

<!-- Renderização do componente atual -->
<svelte:component this={currentComponent} />

<!-- Modal de Completar Perfil -->
{#if showProfileCompletion}
  <ProfileCompletion
    isOpen={showProfileCompletion}
    userData={profileData}
    {missingFields}
    onComplete={handleProfileCompletion}
    onClose={handleProfileCompletionClose}
  />
{/if}
