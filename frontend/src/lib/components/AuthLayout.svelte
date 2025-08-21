<script>
  import { WebsiteName } from '../config.js';
</script>

<div class="min-h-screen bg-base-100 flex flex-col">
  <!-- Header simples -->
  <div class="navbar bg-base-100 border-b">
    <div class="flex-1">
      <a class="btn btn-ghost normal-case text-xl" href="/">
        {WebsiteName}
      </a>
    </div>
  </div>

  <!-- Conteúdo centralizado -->
  <div class="flex-1 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <slot />
    </div>
  </div>

  <!-- Footer minimalista -->
  <div class="text-center py-6 text-sm opacity-60">
    <p>&copy; 2025 {WebsiteName}. Todos os direitos reservados.</p>
  </div>
</div>