<script>
  import { WebsiteName } from '../config.js';
    import logoProcStudio from '../../assets/procstudio_logotipo_vertical_sem_fundo.png'; 

</script>

<div class="min-h-screen bg-gradient-to-br from-[#eef0ef] via-white to-[#eef0ef] flex flex-col relative overflow-hidden">
  <!-- Background decorative elements -->
  <div class="absolute inset-0 overflow-hidden pointer-events-none">
    <div class="absolute top-0 right-0 w-96 h-96 bg-[#0277EE] rounded-full mix-blend-multiply filter blur-3xl opacity-10"></div>
    <div class="absolute bottom-0 left-0 w-80 h-80 bg-[#01013D] rounded-full mix-blend-multiply filter blur-3xl opacity-10"></div>
  </div>

  <!-- Header -->
  <header class="relative z-10 border-b border-white/20 backdrop-blur-sm">
    <nav class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
      <a
        href="/"
        class="flex items-center group"
      >
        <div class="text-3xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent">
          <img 
                src={logoProcStudio} 
                alt="Logotipo do ProcStudio" 
              class="h-20 w-auto"
              />
        </div>
      </a>
      <div class="flex items-center space-x-4">
        <span class="hidden sm:block text-gray-600 text-sm font-medium">Plataforma de Gestão Jurídica</span>
      </div>
    </nav>
  </header>

  <!-- Main Content -->
  <main class="relative z-10 flex-1 flex items-center justify-center px-4 py-12">
    <slot />
  </main>

  <!-- Footer -->
  <footer class="relative z-10 border-t border-white/20 backdrop-blur-sm bg-white/30">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="flex flex-col sm:flex-row items-center justify-between space-y-4 sm:space-y-0">
        <p class="text-gray-600 text-sm font-medium">
          © 2025 {WebsiteName}. Todos os direitos reservados.
        </p>
        <div class="flex items-center space-x-6 text-sm text-gray-600">
          <a href="#" class="hover:text-[#0277EE] transition-colors duration-300">Privacidade</a>
          <a href="#" class="hover:text-[#0277EE] transition-colors duration-300">Termos</a>
          <a href="#" class="hover:text-[#0277EE] transition-colors duration-300">Contato</a>
        </div>
      </div>
    </div>
  </footer>
</div>

<style>
  :global(body) {
    overflow-x: hidden;
  }
</style>

