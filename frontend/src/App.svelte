<script lang="ts">
  import { onMount } from 'svelte';
  import { authStore } from './lib/stores/authStore';
  import { usersCacheStore } from './lib/stores/usersCacheStore';
  import { router } from './lib/stores/routerStore';
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
  import UserConfigPage from './lib/pages/UserConfigPage.svelte';
  import ProfileCompletionEnhanced from './lib/pages/ProfileCompletionEnhanced.svelte';
  import OfficeCreationPage from './lib/pages/Office/OfficeCreationPage.svelte';
  import LawyersTestDebugPage from './lib/pages/LawyersTestDebugPage.svelte';
  import NotFoundPage from './lib/pages/NotFoundPage.svelte';

  $: ({ isAuthenticated, showProfileCompletion, profileData, missingFields } = $authStore);
  $: ({ currentPath, params } = $router);

  $: currentComponent = getComponent(currentPath);

  function getComponent(path: string) {
    if (path.match(/\/customers\/edit\/\d+/)) {
      return CustomersEditPage;
    }

    if (path.match(/\/customers\/profile\/\d+/)) {
      return CustomerProfilePage;
    }

    const routes: Record<string, any> = {
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
      '/customers/new': CustomersNewPage,
      '/user-config': UserConfigPage,
      '/lawyers-test': OfficeCreationPage,
      '/lawyers-test-debug': LawyersTestDebugPage
    };

    return routes[path] || NotFoundPage;
  }

  function handleProfileCompletion(completionResult) {
    authStore.completeProfile(completionResult);
  }

  function handleProfileCompletionClose() {
    authStore.closeProfileCompletion();
  }

  onMount(async () => {
    await authStore.init();

    if ($authStore.isAuthenticated) {
      usersCacheStore.initialize().catch((error) => {
        console.error('Failed to initialize users cache:', error);
      });

      if ($router.currentPath === '/' || $router.currentPath === '/login' || $router.currentPath === '/register') {
        await router.navigate('/dashboard', { skipGuards: true });
      }
    }
  });
</script>

<!-- Session Timeout Handler -->
<SessionTimeout timeoutMinutes={60} warningMinutes={5} />

<!-- Renderização do componente atual -->
<svelte:component this={currentComponent} {...params} />

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
