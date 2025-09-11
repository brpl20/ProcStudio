<script>
  import { WebsiteName } from '../config.js';
  import { authStore } from '../stores/authStore';
  import { router } from '../stores/routerStore.js';

  export let showFooter = true;

  $: isAuthenticated = $authStore.isAuthenticated;
  $: currentPath = $router.currentPath;

  function handleLogout() {
    authStore.logout();
    router.navigate('/');
  }
</script>

<div class="min-h-screen flex flex-col">
  <!-- Navbar -->
  <div class="navbar bg-base-100 container mx-auto">
    <div class="flex-1">
      <a
        class="btn btn-ghost normal-case text-xl"
        href="/"
        on:click|preventDefault={() => router.navigate('/')}
      >
        {WebsiteName}
      </a>
    </div>
    <div class="flex-none">
      <ul class="menu menu-horizontal px-1 hidden sm:flex font-bold text-lg">
        {#if !isAuthenticated}
          <li class="md:mx-2">
            <a
              href="/login"
              on:click|preventDefault={() => router.navigate('/login')}
              class:active={currentPath === '/login'}>Login</a
            >
          </li>
          <li class="md:mx-2">
            <a
              href="/register"
              on:click|preventDefault={() => router.navigate('/register')}
              class:active={currentPath === '/register'}>Register</a
            >
          </li>
        {:else}
          <li class="md:mx-2">
            <a
              href="/dashboard"
              on:click|preventDefault={() => router.navigate('/dashboard')}
              class:active={currentPath === '/dashboard'}>Dashboard</a
            >
          </li>
          <li class="md:mx-2">
            <a
              href="/teams"
              on:click|preventDefault={() => router.navigate('/teams')}
              class:active={currentPath === '/teams'}>Teams</a
            >
          </li>
          <li class="md:mx-2">
            <button class="btn btn-ghost" on:click={handleLogout}>Logout</button>
          </li>
        {/if}
      </ul>

      <!-- Mobile menu -->
      <div class="dropdown dropdown-end sm:hidden">
        <!-- svelte-ignore a11y_label_has_associated_control -->
        <!-- svelte-ignore a11y_no_noninteractive_tabindex -->
        <label tabindex="0" class="btn btn-ghost btn-circle">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 6h16M4 12h16M4 18h7"
            />
          </svg>
        </label>
        <!-- svelte-ignore a11y_no_noninteractive_tabindex -->
        <ul
          tabindex="0"
          class="menu menu-lg dropdown-content mt-3 z-[1] p-2 shadow-sm bg-base-100 rounded-box w-52 font-bold"
        >
          {#if !isAuthenticated}
            <li>
              <a href="/login" on:click|preventDefault={() => router.navigate('/login')}>Login</a>
            </li>
            <li>
              <a href="/register" on:click|preventDefault={() => router.navigate('/register')}
                >Register</a
              >
            </li>
          {:else}
            <li>
              <a href="/dashboard" on:click|preventDefault={() => router.navigate('/dashboard')}
                >Dashboard</a
              >
            </li>
            <li>
              <a href="/teams" on:click|preventDefault={() => router.navigate('/teams')}>Teams</a>
            </li>
            <li><button on:click={handleLogout}>Logout</button></li>
          {/if}
        </ul>
      </div>
    </div>
  </div>

  <!-- Main content -->
  <div class="flex-1 container mx-auto px-4 py-8">
    <slot />
  </div>

  <!-- Footer -->
  {#if showFooter}
    <div class="mt-auto">
      <div class="border-t max-w-[1000px] mx-auto"></div>
      <footer
        class="footer md:footer-horizontal p-10 gap-x-48 lg:gap-x-64 xl:gap-x-96 place-content-center text-base"
      >
        <nav>
          <span class="footer-title opacity-80">Navigation</span>
          <a
            class="link link-hover mb-1"
            href="/"
            on:click|preventDefault={() => router.navigate('/')}>Home</a
          >
          <a
            class="link link-hover my-1"
            href="/dashboard"
            on:click|preventDefault={() => router.navigate('/dashboard')}>Dashboard</a
          >
          <a
            class="link link-hover my-1"
            href="/teams"
            on:click|preventDefault={() => router.navigate('/teams')}>Teams</a
          >
        </nav>
        <aside>
          <span class="footer-title opacity-80">About</span>
          <div class="max-w-[260px]">
            <div class="font-bold text-2xl mb-1">{WebsiteName}</div>
            <div class="font-light">Professional Resource Center API Platform</div>
          </div>
        </aside>
      </footer>
    </div>
  {/if}
</div>

<style>
  .active {
    background-color: var(--color-primary, #180042);
    color: var(--color-primary-content, #fefbf6);
  }
</style>
