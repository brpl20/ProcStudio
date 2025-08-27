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
  import CustomersEditPage from './lib/pages/CustomersEditPage.svelte';
  import CustomerProfilePage from './pages/CustomerProfilePage.svelte';
  import ProfileCompletionEnhanced from './lib/pages/ProfileCompletionEnhanced.svelte';

  // Reactive stores
  $: ({ isAuthenticated, showProfileCompletion, profileData, missingFields } = $authStore);
  $: ({ currentPath } = $router);

  // Route component logic
  $: currentComponent = getComponent(currentPath, isAuthenticated);
  $: routeParams = extractRouteParams(currentPath);

  function extractRouteParams(path) {
    // Extract ID from paths like /customers/edit/123
    const editMatch = path.match(/\/customers\/edit\/(\d+)/);
    if (editMatch) {
      return { id: editMatch[1] };
    }

    // Extract ID from paths like /customers/profile/123
    const profileMatch = path.match(/\/customers\/profile\/(\d+)/);
    if (profileMatch) {
      return { customerId: parseInt(profileMatch[1]) };
    }

    return {};
  }

  function getComponent(path, isAuth) {
    // Check for protected routes
    const protectedPaths = [
      '/dashboard',
      '/teams',
      '/admin',
      '/settings',
      '/reports',
      '/tasks',
      '/works',
      '/customers',
      '/documents'
    ];

    const isProtected = protectedPaths.some((p) => path.startsWith(p));

    if (!isAuth && isProtected) {
      router.navigate('/login');
      return LoginPage;
    }

    // Check for dynamic routes
    if (path.match(/\/customers\/edit\/\d+/)) {
      return CustomersEditPage;
    }

    if (path.match(/\/customers\/profile\/\d+/)) {
      return CustomerProfilePage;
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
<svelte:component this={currentComponent} {...routeParams} />

<!-- Modal de Completar Perfil -->
{#if showProfileCompletion}
  <ProfileCompletionEnhanced
    isOpen={showProfileCompletion}
    userData={profileData}
    {missingFields}
    onComplete={handleProfileCompletion}
    onClose={handleProfileCompletionClose}
  />
{/if}
