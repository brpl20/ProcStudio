<script>
  import { onMount } from 'svelte';
  import { authStore } from './lib/stores/authStore';
  import { usersCacheStore } from './lib/stores/usersCacheStore';
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
  import JobsPage from './lib/pages/JobsPage.svelte';
  import WorksPage from './lib/pages/WorksPage.svelte';
  import CustomersPage from './lib/pages/CustomersPage.svelte';
  import CustomersNewPage from './lib/pages/CustomersNewPage.svelte';
  import CustomersEditPage from './lib/pages/CustomersEditPage.svelte';
  import CustomerProfilePage from './lib/pages/CustomerProfilePage.svelte';
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

    // Extract ID from paths like /teams/advogados/123
    const advogadoViewMatch = path.match(/\/teams\/advogados\/(\d+)/);
    if (advogadoViewMatch) {
      return { id: advogadoViewMatch[1] };
    }

    // Extract ID from paths like /teams/escritorios/123
    const escritorioViewMatch = path.match(/\/teams\/escritorios\/(\d+)/);
    if (escritorioViewMatch) {
      return { id: escritorioViewMatch[1] };
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
      '/jobs',
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
      '/jobs': JobsPage,
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
    
    // Initialize users cache if authenticated
    if ($authStore.isAuthenticated) {
      // eslint-disable-next-line no-console
      console.log('Initializing users cache...');
      usersCacheStore.initialize().catch(error => {
        // eslint-disable-next-line no-console
        console.error('Failed to initialize users cache:', error);
      });
    }
    
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
