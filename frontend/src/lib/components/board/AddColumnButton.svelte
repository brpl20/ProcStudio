<script lang="ts">
  import { boardStore } from '$lib/stores/boardStore';

  let isAdding = false;
  let columnTitle = '';
  let selectedColor = '#6b7280';
  let inputElement: HTMLInputElement;

  // Predefined color options
  const colorOptions = [
    { name: 'Cinza', value: '#6b7280' },
    { name: 'Vermelho', value: '#ef4444' },
    { name: 'Laranja', value: '#f59e0b' },
    { name: 'Amarelo', value: '#eab308' },
    { name: 'Verde', value: '#10b981' },
    { name: 'Azul', value: '#3b82f6' },
    { name: 'Índigo', value: '#6366f1' },
    { name: 'Rosa', value: '#ec4899' },
    { name: 'Roxo', value: '#8b5cf6' }
  ];

  function startAdding() {
    isAdding = true;
    setTimeout(() => inputElement?.focus(), 0);
  }

  function cancelAdding() {
    isAdding = false;
    columnTitle = '';
    selectedColor = '#6b7280';
  }

  function handleSubmit() {
    if (columnTitle.trim()) {
      boardStore.addColumn(columnTitle.trim(), selectedColor);
      columnTitle = '';
      selectedColor = '#6b7280';
      isAdding = false;
    }
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      handleSubmit();
    } else if (event.key === 'Escape') {
      cancelAdding();
    }
  }
</script>

{#if isAdding}
  <div class="w-80 bg-base-200 rounded-lg shadow-sm p-4">
    <div class="space-y-4">
      <!-- Column Title Input -->
      <div>
        <label class="label label-text font-medium">Nome da coluna</label>
        <input
          bind:this={inputElement}
          bind:value={columnTitle}
          on:keydown={handleKeydown}
          class="input input-bordered w-full"
          placeholder="Ex: A Fazer, Em Progresso..."
          maxlength="50"
        />
      </div>

      <!-- Color Picker -->
      <div>
        <label class="label label-text font-medium">Cor</label>
        <div class="flex flex-wrap gap-2">
          {#each colorOptions as color}
            <button
              class="w-8 h-8 rounded-full border-2 transition-all duration-200"
              class:border-base-content={selectedColor === color.value}
              class:border-base-300={selectedColor !== color.value}
              class:scale-110={selectedColor === color.value}
              style="background-color: {color.value}"
              on:click={() => (selectedColor = color.value)}
              title={color.name}
            >
              {#if selectedColor === color.value}
                <svg class="w-4 h-4 text-white mx-auto" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    fill-rule="evenodd"
                    d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                    clip-rule="evenodd"
                  />
                </svg>
              {/if}
            </button>
          {/each}
        </div>
      </div>

      <!-- Actions -->
      <div class="flex items-center justify-between gap-2">
        <div class="flex items-center gap-2">
          <button
            class="btn btn-primary btn-sm"
            on:click={handleSubmit}
            disabled={!columnTitle.trim()}
          >
            Criar Coluna
          </button>
          <button class="btn btn-ghost btn-sm" on:click={cancelAdding}> Cancelar </button>
        </div>

        <div class="text-xs text-base-content/50">
          {columnTitle.length}/50
        </div>
      </div>
    </div>
  </div>
{:else}
  <div class="w-80">
    <button
      class="btn btn-ghost w-full h-32 border-2 border-dashed border-base-300 hover:border-primary hover:bg-primary/5 transition-all duration-200 rounded-lg"
      on:click={startAdding}
    >
      <div class="flex flex-col items-center gap-2 text-base-content/70">
        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 6v6m0 0v6m0-6h6m-6 0H6"
          />
        </svg>
        <span class="font-medium">Adicionar Nova Coluna</span>
      </div>
    </button>
  </div>
{/if}

<style>
  .transition-all {
    transition-property: all;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 200ms;
  }

  .scale-110 {
    transform: scale(1.1);
  }
</style>
