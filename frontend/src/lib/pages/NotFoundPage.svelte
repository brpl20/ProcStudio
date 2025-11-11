<script lang="ts">
  import { router } from '../stores/routerStore';
  import Icon from '../icons/icons.svelte';

  function goHome() {
    router.navigate('/');
  }

  function goBack() {
    router.back();
  }
</script>

<div class="min-h-screen flex items-center justify-center bg-base-200">
  <div class="text-center">
    <h1 class="text-9xl font-bold text-primary">404</h1>
    <p class="text-2xl font-semibold mt-4">Página não encontrada</p>
    <p class="text-base-content/70 mt-2">
      A página que você está procurando não existe ou foi movida.
    </p>

    <div class="flex gap-4 justify-center mt-8">
      <button class="btn btn-primary" onclick={goHome}>
        <Icon name="home" className="h-5 w-5 mr-2" />
        Ir para Home
      </button>
      <button class="btn btn-outline" onclick={goBack}>
        <Icon name="arrow-left" className="h-5 w-5 mr-2" />
        Voltar
      </button>
    </div>
  </div>
</div>
