<script lang="ts">
  import { authStore } from '../stores/authStore.js';
  import { userProfileStore, currentUserProfile } from '../stores/userProfileStore.js';
  import { router } from '../stores/routerStore.js';
  import Icon from '../icons/icons.svelte';
  import { WebsiteName } from '../config.js';

  interface Props {
    showMenuButton?: boolean;
  }

  const { showMenuButton = true }: Props = $props();

  const isAuthenticated = $derived($authStore.isAuthenticated);
  const currentUser = $derived($authStore.user);
  const userProfile = $derived($currentUserProfile);
  const isLoadingProfile = $derived($userProfileStore.isLoading);

  // Computed user display properties
  const userDisplayName = $derived(getUserDisplayName(userProfile, currentUser, isLoadingProfile));
  const userInitials = $derived(getUserInitials(userDisplayName));

  function getUserDisplayName(profile: any, user: any, loading: boolean): string {
    if (loading) {
      return 'Carregando...';
    }

    if (profile?.attributes) {
      const firstName = profile.attributes.name || '';
      const lastName = profile.attributes.last_name || '';
      return `${firstName} ${lastName}`.trim() || 'Nome não definido';
    }

    if (user?.data) {
      const firstName = user.data.name || '';
      const lastName = user.data.last_name || '';
      return `${firstName} ${lastName}`.trim() || user.data.email || 'Usuário';
    }

    return 'Usuário';
  }

  function getUserInitials(name: string): string {
    return (
      name
        .split(' ')
        .map((n) => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2) || 'U'
    );
  }

  function handleLogout(): void {
    authStore.logout();
    router.navigate('/');
  }
</script>

<div class="navbar bg-base-100 shadow-lg border-b border-base-300">
  <div class="navbar-start">
    {#if showMenuButton}
      <label for="admin-drawer" class="btn btn-ghost btn-circle lg:hidden">
        <Icon name="hamburger" />
      </label>
    {/if}
    <a
      href="/dashboard"
      class="btn btn-ghost normal-case text-xl"
      onclick={(e) => {
        e.preventDefault();
        router.navigate('/dashboard');
      }}
    >
      {WebsiteName}
    </a>
  </div>

  <div class="navbar-center hidden lg:flex">
    <!-- Optional center content -->
  </div>

  <div class="navbar-end">
    {#if isAuthenticated}
      <div class="dropdown dropdown-end">
        <div role="button" class="btn btn-ghost btn-circle avatar">
          <div class="avatar placeholder">
            <div class="bg-primary text-primary-content rounded-full w-10">
              <span class="text-xl">{userInitials}</span>
            </div>
          </div>
        </div>
        <ul
          class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52"
        >
          <li class="menu-title">
            <span>{userDisplayName}</span>
          </li>
          <li>
            <a
              href="/settings"
              onclick={(e) => {
                e.preventDefault();
                router.navigate('/settings');
              }}
            >
              <Icon name="settings" />
              Configurações
            </a>
          </li>
          <li>
            <button onclick={handleLogout}>
              <Icon name="logout" />
              Sair
            </button>
          </li>
        </ul>
      </div>
    {/if}
  </div>
</div>
