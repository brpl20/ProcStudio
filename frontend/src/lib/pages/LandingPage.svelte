<script>
  import MainLayout from '../components/MainLayout.svelte';
</script>

<MainLayout>
  <div class="hero min-h-[60vh]">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <h1 class="text-5xl font-bold text-primary mb-6">ProcStudio</h1>
        <h2 class="text-2xl text-base-content opacity-70 mb-8">Sistema em Desenvolvimento</h2>

        <div class="flex gap-4 justify-center">
          <button class="btn btn-primary btn-lg"> Saiba Mais </button>
          <button class="btn btn-outline btn-lg"> Contato </button>
        </div>
      </div>
    </div>
  </div>

  <div class="divider"></div>

  <!-- Features em desenvolvimento -->
  <section class="py-16">
    <div class="container mx-auto px-4">
      <h3 class="text-3xl font-bold text-center mb-12">Funcionalidades</h3>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div class="card bg-base-200 shadow-lg">
          <div class="card-body text-center">
            <div class="text-4xl mb-4">⚖️</div>
            <h4 class="card-title justify-center">Gestão Jurídica</h4>
            <p class="opacity-70">Em desenvolvimento...</p>
          </div>
        </div>

        <div class="card bg-base-200 shadow-lg">
          <div class="card-body text-center">
            <div class="text-4xl mb-4">👥</div>
            <h4 class="card-title justify-center">Equipes</h4>
            <p class="opacity-70">Em desenvolvimento...</p>
          </div>
        </div>

        <div class="card bg-base-200 shadow-lg">
          <div class="card-body text-center">
            <div class="text-4xl mb-4">📊</div>
            <h4 class="card-title justify-center">Relatórios</h4>
            <p class="opacity-70">Em desenvolvimento...</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</MainLayout>
