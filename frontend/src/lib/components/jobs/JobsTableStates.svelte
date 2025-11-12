<script lang="ts">
  import Icon from '../../icons/icons.svelte';

  interface Props {
    type: 'loading' | 'error' | 'empty' | 'no-results';
    error?: string | null;
    searchTerm?: string;
    onRetry?: () => void;
  }

  const { type, error = null, searchTerm = '', onRetry = () => {} }: Props = $props();
</script>

{#if type === 'loading'}
  <div class="text-center py-8">
    <div class="loading loading-spinner loading-md text-primary"></div>
    <p class="text-base-content/70 mt-4">Carregando jobs...</p>
  </div>
{:else if type === 'error'}
  <div class="alert alert-error">
    <Icon name="error" className="h-6 w-6" />
    <div>
      <h3 class="font-bold">Erro ao carregar jobs</h3>
      <div class="text-xs">{error}</div>
    </div>
    <button onclick={onRetry} class="btn btn-sm">Tentar novamente</button>
  </div>
{:else if type === 'empty'}
  <div class="hero bg-base-200 rounded-lg py-8">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <p class="py-6 text-lg">Nenhum job encontrado</p>
        <p class="text-base-content/60">Os jobs aparecerão aqui quando forem criados.</p>
      </div>
    </div>
  </div>
{:else if type === 'no-results'}
  <div class="alert alert-info">
    <Icon name="info" className="h-6 w-6" />
    <span>Nenhum job encontrado para "{searchTerm}"</span>
  </div>
{/if}