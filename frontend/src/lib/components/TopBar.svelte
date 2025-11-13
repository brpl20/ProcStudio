<script lang="ts">
  import { authStore } from '../stores/authStore';
  import { userProfileStore, currentUserProfile } from '../stores/userProfileStore';
  import { usersCacheStore } from '../stores/usersCacheStore';
  import { router } from '../stores/routerStore';
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

  const userId = $derived(currentUser?.data?.id);
  const cachedAvatarUrl = $derived(userId ? usersCacheStore.getAvatarUrlByUserId(userId) : null);

  const userDisplayName = $derived(getUserDisplayName(userProfile, currentUser, isLoadingProfile));
  const userInitials = $derived(getUserInitials(userDisplayName));
  const userAvatarUrl = $derived(cachedAvatarUrl || userProfile?.attributes?.avatar_url || userProfile?.attributes?.avatar);

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

<header class="bg-white border-b border-gray-200/50 shadow-sm sticky top-0 z-40">
  <div class="px-6 py-4 flex items-center justify-between">
    <!-- Left Section -->
    <div class="flex items-center gap-4">
      {#if showMenuButton}
        <label for="admin-drawer" class="btn btn-ghost btn-circle lg:hidden hover:bg-gray-100">
          <Icon name="hamburger" className="h-5 w-5 text-[#01013D]" />
        </label>
      {/if}
      
      <button
        class="font-bold text-2xl bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent hover:opacity-80 transition-opacity duration-200"
        onclick={(e) => {
          e.preventDefault();
          router.navigate('/dashboard');
        }}
      >
        {WebsiteName}
      </button>
    </div>

    <!-- Right Section -->
    <div class="flex items-center gap-6">
      {#if isAuthenticated}
        <!-- User Dropdown -->
        <div class="relative group">
          <button
            class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-gray-50 transition-all duration-200 group-hover:shadow-md"
          >
            <div class="text-right hidden sm:flex flex-col items-end">
              <div class="text-sm font-semibold text-[#01013D]">{userDisplayName}</div>
              <div class="text-xs text-gray-500 truncate max-w-[150px]">{currentUser?.data?.email}</div>
            </div>
            
            <div class="w-11 h-11 rounded-full bg-gradient-to-br from-[#0277EE] to-[#01013D] flex items-center justify-center border-2 border-[#eef0ef] shadow-md hover:shadow-lg transition-all duration-200">
              {#if userAvatarUrl}
                <img
                  src={userAvatarUrl}
                  alt={userDisplayName}
                  class="rounded-full w-11 h-11 object-cover"
                />
              {:else}
                <span class="text-xs font-bold text-white">{userInitials}</span>
              {/if}
            </div>
          </button>

          <!-- Dropdown Menu -->
          <div class="absolute right-0 mt-2 w-64 bg-white rounded-xl shadow-xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 overflow-hidden z-50 border border-gray-100">
            <div class="px-4 py-4 bg-gradient-to-r from-[#01013D] via-[#0277EE] to-[#0277EE]">
              <div class="flex items-center gap-3">
                <div class="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center border-2 border-white/40">
                  {#if userAvatarUrl}
                    <img
                      src={userAvatarUrl}
                      alt={userDisplayName}
                      class="rounded-full w-12 h-12 object-cover"
                    />
                  {:else}
                    <span class="text-sm font-bold text-white">{userInitials}</span>
                  {/if}
                </div>
                <div>
                  <div class="text-sm font-semibold text-white">{userDisplayName}</div>
                  <div class="text-xs text-white/80">{currentUser?.data?.email}</div>
                </div>
              </div>
            </div>

            <div class="py-2">
              <button
                class="w-full px-4 py-3 flex items-center gap-3 text-[#01013D] hover:bg-[#eef0ef] transition-colors duration-150 text-sm font-medium group/btn"
                onclick={(e) => {
                  e.preventDefault();
                  router.navigate('/settings');
                }}
              >
                <div class="w-8 h-8 rounded-lg bg-gray-100 group-hover/btn:bg-[#0277EE] group-hover/btn:text-white flex items-center justify-center transition-all duration-200">
                  <Icon name="settings" className="h-4 w-4" />
                </div>
                <span>Configurações</span>
              </button>

              <button
                class="w-full px-4 py-3 flex items-center gap-3 text-[#01013D] hover:bg-red-50 transition-colors duration-150 text-sm font-medium group/btn border-t border-gray-100"
                onclick={handleLogout}
              >
                <div class="w-8 h-8 rounded-lg bg-gray-100 group-hover/btn:bg-red-100 group-hover/btn:text-red-600 flex items-center justify-center transition-all duration-200">
                  <Icon name="logout" className="h-4 w-4" />
                </div>
                <span>Sair</span>
              </button>
            </div>
          </div>
        </div>
      {/if}
    </div>
  </div>
</header>
