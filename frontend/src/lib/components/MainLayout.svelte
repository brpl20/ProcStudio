<script>
  import { WebsiteName } from '../config.js';
  import { authStore } from '../stores/authStore';
  import { router } from '../stores/routerStore';
  import logoProcStudio from '../../assets/procstudio_logotipo_horizontal_sem_fundo.png'; 

  export let showFooter = true;

  $: isAuthenticated = $authStore.isAuthenticated;
  $: currentPath = router.currentPath;

  function handleLogout() {
    authStore.logout();
    router.navigate('/');
  }

  let mobileMenuOpen = false;

  function toggleMobileMenu() {
    mobileMenuOpen = !mobileMenuOpen;
  }

  function closeMobileMenu() {
    mobileMenuOpen = false;
  }
</script>

<div class="min-h-screen flex flex-col bg-[#eef0ef]">
  <!-- Navbar -->
  <nav class="sticky top-0 z-50 bg-white/95 backdrop-blur-md shadow-sm border-b border-gray-100">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-20">
        <!-- Logo -->
        <div class="flex-shrink-0">
          <a
            href="/"
            on:click|preventDefault={() => { router.navigate('/'); closeMobileMenu(); }}
            class="flex items-center group"
          >
            <div class="text-3xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent">
              <img 
                src={logoProcStudio} 
                alt="Logotipo do ProcStudio" 
              class="h-14 w-auto"
              />
            </div>
          </a>
        </div>

        <!-- Desktop Navigation -->
        <div class="hidden md:flex items-center space-x-1">
          {#if !isAuthenticated}
            <a
              href="/login"
              on:click|preventDefault={() => router.navigate('/login')}
              class="px-6 py-2.5 text-[#01013D] font-semibold rounded-lg hover:bg-[#eef0ef] transition-all duration-300 {currentPath === '/login' ? 'bg-[#eef0ef]' : ''}"
            >
              Login
            </a>
            <a
              href="/register"
              on:click|preventDefault={() => router.navigate('/register')}
              class="ml-2 px-6 py-2.5 bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-semibold rounded-lg hover:shadow-lg hover:scale-105 transition-all duration-300"
            >
              Cadastrar
            </a>
          {:else}
            <a
              href="/dashboard"
              on:click|preventDefault={() => router.navigate('/dashboard')}
              class="px-6 py-2.5 text-[#01013D] font-semibold rounded-lg hover:bg-[#eef0ef] transition-all duration-300 {currentPath === '/dashboard' ? 'bg-[#eef0ef]' : ''}"
            >
              Dashboard
            </a>
            <a
              href="/teams"
              on:click|preventDefault={() => router.navigate('/teams')}
              class="px-6 py-2.5 text-[#01013D] font-semibold rounded-lg hover:bg-[#eef0ef] transition-all duration-300 {currentPath === '/teams' ? 'bg-[#eef0ef]' : ''}"
            >
              Teams
            </a>
            <button
              class="ml-2 px-6 py-2.5 text-[#01013D] font-semibold rounded-lg border-2 border-[#01013D] hover:bg-[#01013D] hover:text-white transition-all duration-300"
              on:click={handleLogout}
            >
              Logout
            </button>
          {/if}
        </div>

        <!-- Mobile menu button -->
        <div class="md:hidden">
          <button
            on:click={toggleMobileMenu}
            class="inline-flex items-center justify-center p-2 rounded-lg text-[#01013D] hover:bg-[#eef0ef] transition-colors duration-300"
            aria-expanded={mobileMenuOpen}
          >
            <svg
              class="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              {#if mobileMenuOpen}
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              {:else}
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                />
              {/if}
            </svg>
          </button>
        </div>
      </div>

      <!-- Mobile menu -->
      {#if mobileMenuOpen}
        <div class="md:hidden pb-4 animate-slide-down">
          <div class="flex flex-col space-y-2">
            {#if !isAuthenticated}
              <a
                href="/login"
                on:click|preventDefault={() => { router.navigate('/login'); closeMobileMenu(); }}
                class="px-4 py-3 text-[#01013D] font-semibold rounded-lg hover:bg-[#eef0ef] transition-all duration-300 {currentPath === '/login' ? 'bg-[#eef0ef]' : ''}"
              >
                Login
              </a>
              <a
                href="/register"
                on:click|preventDefault={() => { router.navigate('/register'); closeMobileMenu(); }}
                class="px-4 py-3 bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-semibold rounded-lg text-center hover:shadow-lg transition-all duration-300"
              >
                Cadastrar
              </a>
            {:else}
              <a
                href="/dashboard"
                on:click|preventDefault={() => { router.navigate('/dashboard'); closeMobileMenu(); }}
                class="px-4 py-3 text-[#01013D] font-semibold rounded-lg hover:bg-[#eef0ef] transition-all duration-300 {currentPath === '/dashboard' ? 'bg-[#eef0ef]' : ''}"
              >
                Dashboard
              </a>
              <a
                href="/teams"
                on:click|preventDefault={() => { router.navigate('/teams'); closeMobileMenu(); }}
                class="px-4 py-3 text-[#01013D] font-semibold rounded-lg hover:bg-[#eef0ef] transition-all duration-300 {currentPath === '/teams' ? 'bg-[#eef0ef]' : ''}"
              >
                Teams
              </a>
              <button
                class="px-4 py-3 text-[#01013D] font-semibold rounded-lg border-2 border-[#01013D] hover:bg-[#01013D] hover:text-white transition-all duration-300 text-left"
                on:click={() => { handleLogout(); closeMobileMenu(); }}
              >
                Logout
              </button>
            {/if}
          </div>
        </div>
      {/if}
    </div>
  </nav>

  <!-- Main content -->
  <main class="flex-1">
    <slot />
  </main>

  <!-- Footer -->
  {#if showFooter}
    <footer class="bg-white border-t border-gray-100 mt-auto">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-12">
          <!-- Brand -->
          <div class="space-y-4">
            <h3 class="text-3xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent">
              {WebsiteName}
            </h3>
            <p class="text-gray-600 text-lg leading-relaxed">
              Professional Resource Center API Platform
            </p>
            <p class="text-sm text-gray-500">
              Transformando a gestão jurídica com tecnologia de ponta
            </p>
          </div>

          <!-- Navigation -->
          <div>
            <h4 class="text-lg font-bold text-[#01013D] mb-4">Navegação</h4>
            <ul class="space-y-3">
              <li>
                <a
                  href="/"
                  on:click|preventDefault={() => router.navigate('/')}
                  class="text-gray-600 hover:text-[#0277EE] transition-colors duration-300 flex items-center group"
                >
                  <span class="w-1.5 h-1.5 bg-[#0277EE] rounded-full mr-2 opacity-0 group-hover:opacity-100 transition-opacity"></span>
                  Home
                </a>
              </li>
              <li>
                <a
                  href="/dashboard"
                  on:click|preventDefault={() => router.navigate('/dashboard')}
                  class="text-gray-600 hover:text-[#0277EE] transition-colors duration-300 flex items-center group"
                >
                  <span class="w-1.5 h-1.5 bg-[#0277EE] rounded-full mr-2 opacity-0 group-hover:opacity-100 transition-opacity"></span>
                  Dashboard
                </a>
              </li>
              <li>
                <a
                  href="/teams"
                  on:click|preventDefault={() => router.navigate('/teams')}
                  class="text-gray-600 hover:text-[#0277EE] transition-colors duration-300 flex items-center group"
                >
                  <span class="w-1.5 h-1.5 bg-[#0277EE] rounded-full mr-2 opacity-0 group-hover:opacity-100 transition-opacity"></span>
                  Teams
                </a>
              </li>
            </ul>
          </div>

          <!-- Contact/Info -->
          <div>
            <h4 class="text-lg font-bold text-[#01013D] mb-4">Contato</h4>
            <ul class="space-y-3 text-gray-600">
              <li class="flex items-center">
                <svg class="w-5 h-5 mr-2 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                </svg>
                contato@procstudio.com
              </li>
              <li class="flex items-center">
                <svg class="w-5 h-5 mr-2 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                Brasil
              </li>
            </ul>
          </div>
        </div>

        <div class="border-t border-gray-200 mt-12 pt-8 text-center">
          <p class="text-gray-500 text-sm">
            © {new Date().getFullYear()} {WebsiteName}. Todos os direitos reservados.
          </p>
        </div>
      </div>
    </footer>
  {/if}
</div>

<style>
  @keyframes slide-down {
    from {
      opacity: 0;
      transform: translateY(-10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .animate-slide-down {
    animation: slide-down 0.3s ease-out;
  }
</style>
