<script lang="ts">
  import { boardStore } from '$lib/stores/boardStore';
  import type { Column } from '$lib/types/board.types';

  export let column: Column;
  export let taskCount: number;

  let isEditingTitle = false;
  let titleInput: HTMLInputElement;
  let newTitle = column.title;

  // Title editing handlers
  function startEditingTitle() {
    isEditingTitle = true;
    newTitle = column.title;
    setTimeout(() => titleInput?.focus(), 0);
  }

  function saveTitle() {
    if (newTitle.trim() && newTitle.trim() !== column.title) {
      boardStore.updateColumn(column.id, { title: newTitle.trim() });
    }
    isEditingTitle = false;
  }

  function cancelEditTitle() {
    newTitle = column.title;
    isEditingTitle = false;
  }

  function handleTitleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      saveTitle();
    } else if (event.key === 'Escape') {
      cancelEditTitle();
    }
  }

  // Column actions
  function handleColumnSettings() {
    // TODO: Open column settings modal
    console.log('Open column settings for:', column.id);
  }

  function handleDeleteColumn() {
    if (taskCount > 0) {
      alert(
        'Não é possível excluir uma coluna que contém tarefas. Mova ou exclua as tarefas primeiro.'
      );
      return;
    }

    if (confirm(`Tem certeza que deseja excluir a coluna "${column.title}"?`)) {
      boardStore.deleteColumn(column.id);
    }
  }

  $: wipStatus = column.wipLimit ? `${taskCount}/${column.wipLimit}` : taskCount.toString();
  $: isWipExceeded = column.wipLimit && taskCount > column.wipLimit;
</script>

<div class="p-3 border-b border-base-300 bg-base-100 rounded-t-lg">
  <div class="flex items-center justify-between gap-2">
    <!-- Column Title -->
    <div class="flex items-center gap-2 flex-1 min-w-0">
      <!-- Color indicator -->
      <div
        class="w-3 h-3 rounded-full flex-shrink-0"
        style="background-color: {column.color}"
      ></div>

      {#if isEditingTitle}
        <input
          bind:this={titleInput}
          bind:value={newTitle}
          on:blur={saveTitle}
          on:keydown={handleTitleKeydown}
          class="input input-ghost input-sm bg-transparent border-none p-0 font-semibold flex-1 min-w-0"
          placeholder="Nome da coluna"
          maxlength="50"
        />
      {:else}
        <h3
          class="font-semibold text-sm cursor-pointer hover:text-primary transition-colors truncate flex-1"
          on:click={startEditingTitle}
          title="Clique para editar"
        >
          {column.title}
        </h3>
      {/if}
    </div>

    <!-- Task Count and Actions -->
    <div class="flex items-center gap-2 flex-shrink-0">
      <!-- Task count with WIP limit -->
      <div
        class="badge badge-sm"
        class:badge-warning={isWipExceeded}
        class:badge-ghost={!isWipExceeded}
        title={column.wipLimit ? `Limite WIP: ${column.wipLimit}` : 'Número de tarefas'}
      >
        {wipStatus}
      </div>

      <!-- Column Menu -->
      <div class="dropdown dropdown-end">
        <button class="btn btn-ghost btn-xs" tabindex="0" title="Opções da coluna">
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"
            />
          </svg>
        </button>
        <ul class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-48">
          <li>
            <button on:click={startEditingTitle}>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                />
              </svg>
              Renomear
            </button>
          </li>
          <li>
            <button on:click={handleColumnSettings}>
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
              Configurações
            </button>
          </li>
          <div class="divider my-1"></div>
          <li>
            <button
              on:click={handleDeleteColumn}
              class="text-error hover:bg-error hover:text-error-content"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                />
              </svg>
              Excluir Coluna
            </button>
          </li>
        </ul>
      </div>
    </div>
  </div>

  <!-- WIP Limit Warning -->
  {#if isWipExceeded}
    <div class="mt-2">
      <div class="alert alert-warning alert-sm">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="stroke-current shrink-0 h-3 w-3"
          fill="none"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 15.5c-.77.833.192 2.5 1.732 2.5z"
          />
        </svg>
        <span class="text-xs">Limite WIP excedido!</span>
      </div>
    </div>
  {/if}
</div>

<style>
  .transition-colors {
    transition-property: color, background-color, border-color;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 200ms;
  }
</style>
