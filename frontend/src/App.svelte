<script>
  import { onMount } from 'svelte';
  import { authStore } from './lib/stores/authStore.js';
  import { router } from './lib/stores/routerStore.js';
  import SessionTimeout from './lib/components/SessionTimeout.svelte';

  // Pages
  import LandingPage from './lib/pages/LandingPage.svelte';
  import LoginPage from './lib/pages/LoginPage.svelte';
  import RegisterPage from './lib/pages/RegisterPage.svelte';
  import DashboardPage from './lib/pages/DashboardPage.svelte';
  import TeamsPage from './lib/pages/TeamsPage.svelte';
  import AdminPage from './lib/pages/AdminPage.svelte';
  import SettingsPage from './lib/pages/SettingsPage.svelte';
  import ReportsPage from './lib/pages/ReportsPage.svelte';
  import TasksPage from './lib/pages/TasksPage.svelte';
  import WorksPage from './lib/pages/WorksPage.svelte';
  import CustomersPage from './lib/pages/CustomersPage.svelte';
  import CustomersNewPage from './lib/pages/CustomersNewPage.svelte';
  import ProfileCompletion from './lib/pages/ProfileCompletion.svelte';

  // Reactive stores
  $: ({ isAuthenticated, showProfileCompletion, profileData, missingFields } = $authStore);
  $: ({ currentPath } = $router);

  // Route component logic
  $: currentComponent = getComponent(currentPath, isAuthenticated);

  function getComponent(path, isAuth) {
    if (
      !isAuth &&
      (path === '/dashboard' ||
        path === '/teams' ||
        path === '/admin' ||
        path === '/settings' ||
        path === '/reports' ||
        path === '/tasks' ||
        path === '/works' ||
        path === '/customers' ||
        path === '/customers/new' ||
        path === '/documents')
    ) {
      router.navigate('/login');
      return LoginPage;
    }

    const routes = {
      '/': LandingPage,
      '/login': LoginPage,
      '/register': RegisterPage,
      '/dashboard': DashboardPage,
      '/teams': TeamsPage,
      '/admin': AdminPage,
      '/settings': SettingsPage,
      '/reports': ReportsPage,
      '/tasks': TasksPage,
      '/works': WorksPage,
      '/customers': CustomersPage,
      '/customers/new': CustomersNewPage
    };

    return routes[path] || LandingPage;
  }

  function handleProfileCompletion(completionResult) {
    authStore.completeProfile(completionResult);
  }

  function handleProfileCompletionClose() {
    authStore.closeProfileCompletion();
  }

  onMount(async () => {
    await authStore.init();
    // Redirecionar usuário autenticado para dashboard se estiver na landing
    if ($authStore.isAuthenticated && $router.currentPath === '/') {
      router.navigate('/dashboard');
    }

    // Listen for browser navigation
    window.addEventListener('popstate', () => {
      // Force re-evaluation of the current component
      router.navigate(window.location.pathname);
    });
  });
</script>

<!-- Session Timeout Handler -->
<SessionTimeout timeoutMinutes={60} warningMinutes={5} />

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
