<script lang="ts">
  import { boardStore, totalTasks } from '$lib/stores/boardStore';
  import type { Board } from '$lib/types/board.types';

  export let board: Board;

  $: taskCount = $totalTasks;

  let isEditingTitle = false;
  let titleInput: HTMLInputElement;
  let newTitle = board.title;

  // Title editing handlers
  function startEditingTitle() {
    isEditingTitle = true;
    newTitle = board.title;
    setTimeout(() => titleInput?.focus(), 0);
  }

  function saveTitle() {
    if (newTitle.trim() && newTitle.trim() !== board.title) {
      // TODO: Update board title via API
      board.title = newTitle.trim();
    }
    isEditingTitle = false;
  }

  function cancelEditTitle() {
    newTitle = board.title;
    isEditingTitle = false;
  }

  function handleTitleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      saveTitle();
    } else if (event.key === 'Escape') {
      cancelEditTitle();
    }
  }

  // Board actions
  function handleBoardSettings() {
    // TODO: Open board settings modal
    console.log('Open board settings');
  }

  function handleAddColumn() {
    const columnTitle = prompt('Nome da nova coluna:');
    if (columnTitle?.trim()) {
      boardStore.addColumn(columnTitle.trim());
    }
  }

  function handleBoardFilter() {
    // TODO: Open filter modal
    console.log('Open board filters');
  }

  function handleExportBoard() {
    // TODO: Implement board export
    console.log('Export board');
  }
</script>

<div class="p-4 bg-base-100">
  <div class="flex items-center justify-between flex-wrap gap-4">
    <!-- Left section: Title and stats -->
    <div class="flex items-center gap-4 flex-1 min-w-0">
      <!-- Board Title -->
      <div class="flex items-center gap-2 min-w-0">
        {#if isEditingTitle}
          <input
            bind:this={titleInput}
            bind:value={newTitle}
            on:blur={saveTitle}
            on:keydown={handleTitleKeydown}
            class="input input-ghost text-2xl font-bold bg-transparent border-none p-0 focus:ring-2 focus:ring-primary"
            placeholder="Nome do quadro"
            maxlength="100"
          />
        {:else}
          <h1
            class="text-2xl font-bold cursor-pointer hover:text-primary transition-colors truncate"
            on:click={startEditingTitle}
            title="Clique para editar"
          >
            {board.title}
          </h1>
        {/if}

        <button
          class="btn btn-ghost btn-sm"
          on:click={startEditingTitle}
          title="Editar título do quadro"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
            />
          </svg>
        </button>
      </div>

      <!-- Board Stats -->
      <div class="flex items-center gap-4 text-sm text-base-content/70">
        <div class="flex items-center gap-1">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
            />
          </svg>
          <span>{taskCount} {taskCount === 1 ? 'tarefa' : 'tarefas'}</span>
        </div>

        <div class="flex items-center gap-1">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7m0 10a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 00-2-2h-2a2 2 0 00-2 2"
            />
          </svg>
          <span>{board.columns.length} {board.columns.length === 1 ? 'coluna' : 'colunas'}</span>
        </div>
      </div>
    </div>

    <!-- Right section: Actions -->
    <div class="flex items-center gap-2 flex-shrink-0">
      <!-- Filter Button -->
      <button class="btn btn-ghost btn-sm" on:click={handleBoardFilter} title="Filtrar tarefas">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.707A1 1 0 013 7V4z"
          />
        </svg>
        <span class="hidden sm:inline">Filtrar</span>
      </button>

      <!-- Add Column Button -->
      <button
        class="btn btn-primary btn-sm"
        on:click={handleAddColumn}
        title="Adicionar nova coluna"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 6v6m0 0v6m0-6h6m-6 0H6"
          />
        </svg>
        <span class="hidden sm:inline">Nova Coluna</span>
      </button>

      <!-- Board Menu Dropdown -->
      <div class="dropdown dropdown-end">
        <button class="btn btn-ghost btn-sm" tabindex="0">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"
            />
          </svg>
        </button>
        <ul class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
          <li>
            <button on:click={handleBoardSettings}>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
                />
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>
              Configurações do Quadro
            </button>
          </li>
          <li>
            <button on:click={handleExportBoard}>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
              Exportar Quadro
            </button>
          </li>
          <div class="divider my-1"></div>
          <li>
            <a href="/help" target="_blank">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              Ajuda
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>

  <!-- Board Description (if exists) -->
  {#if board.description}
    <div class="mt-3">
      <p class="text-base-content/70 text-sm leading-relaxed">
        {board.description}
      </p>
    </div>
  {/if}
</div>

<style>
  /* Smooth transitions */
  .transition-colors {
    transition-property: color, background-color, border-color, text-decoration-color, fill, stroke;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 200ms;
  }

  /* Input styling for title editing */
  .input-ghost:focus {
    background-color: transparent;
    outline: none;
    box-shadow: 0 0 0 2px hsl(var(--p));
    border-radius: 0.375rem;
  }

  /* Dropdown menu improvements */
  .dropdown-content {
    box-shadow:
      0 10px 15px -3px rgba(0, 0, 0, 0.1),
      0 4px 6px -2px rgba(0, 0, 0, 0.05);
    border: 1px solid hsl(var(--b3));
  }
</style>
