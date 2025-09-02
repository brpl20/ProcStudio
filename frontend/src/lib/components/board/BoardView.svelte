<script lang="ts">
  import { onMount } from 'svelte';
  import { boardStore, columns } from '$lib/stores/boardStore';
  import { dragStore, createDragData, parseDragData } from '$lib/stores/dragStore';
  import BoardHeader from './BoardHeader.svelte';
  import TaskColumn from './TaskColumn.svelte';
  import AddColumnButton from './AddColumnButton.svelte';

  export let boardId: string = '1';

  $: currentBoard = $boardStore.currentBoard;
  $: isLoading = $boardStore.isLoading;
  $: error = $boardStore.error;
  $: columnList = $columns;
  $: dragState = $dragStore;

  onMount(() => {
    boardStore.initBoard(boardId);
  });

  // Column drag and drop handlers
  function handleColumnDragStart(event: DragEvent, column: any) {
    if (!event.dataTransfer) {
      return;
    }

    dragStore.startColumnDrag(column);
    event.dataTransfer.setData('application/json', createDragData('column', column));
    event.dataTransfer.effectAllowed = 'move';
  }

  function handleColumnDragOver(event: DragEvent) {
    event.preventDefault();
    event.dataTransfer!.dropEffect = 'move';
  }

  function handleColumnDrop(event: DragEvent, targetIndex: number) {
    event.preventDefault();

    const dragData = parseDragData(event.dataTransfer!);
    if (!dragData || dragData.type !== 'column') {
      return;
    }

    const sourceIndex = columnList.findIndex((col) => col.id === dragData.data.id);
    if (sourceIndex !== -1 && sourceIndex !== targetIndex) {
      boardStore.reorderColumns(sourceIndex, targetIndex);
    }

    dragStore.endDrag();
  }

  function handleDragEnd() {
    dragStore.endDrag();
  }
</script>

{#if isLoading}
  <div class="flex justify-center items-center h-64">
    <span class="loading loading-spinner loading-lg"></span>
  </div>
{:else if error}
  <div class="alert alert-error">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="stroke-current shrink-0 h-6 w-6"
      fill="none"
      viewBox="0 0 24 24"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
    <span>{error}</span>
    <div>
      <button class="btn btn-sm btn-ghost" on:click={boardStore.clearError}>
        Tentar novamente
      </button>
    </div>
  </div>
{:else if currentBoard}
  <div class="flex flex-col h-full bg-base-100">
    <!-- Board Header -->
    <div class="sticky top-0 z-20 bg-base-100 border-b border-base-300 shadow-sm">
      <BoardHeader board={currentBoard} />
    </div>

    <!-- Columns Container -->
    <div class="flex-1 overflow-hidden">
      <div class="h-full overflow-x-auto overflow-y-hidden">
        <div class="flex h-full p-4 gap-4 min-w-max">
          {#each columnList as column, index (column.id)}
            <div
              class="flex-shrink-0"
              draggable="true"
              on:dragstart={(e) => handleColumnDragStart(e, column)}
              on:dragover={handleColumnDragOver}
              on:drop={(e) => handleColumnDrop(e, index)}
              on:dragend={handleDragEnd}
              class:opacity-50={dragState.isDragging && dragState.draggedColumn?.id === column.id}
            >
              <TaskColumn {column} />
            </div>
          {/each}

          <!-- Add Column Button -->
          <div class="flex-shrink-0">
            <AddColumnButton />
          </div>
        </div>
      </div>
    </div>
  </div>
{:else}
  <div class="flex justify-center items-center h-64">
    <div class="text-center">
      <h3 class="text-lg font-semibold mb-2">Nenhum quadro encontrado</h3>
      <p class="text-base-content/70">Crie um quadro para começar a organizar suas tarefas.</p>
    </div>
  </div>
{/if}

<style>
  :global(.column-drag-placeholder) {
    background-color: hsl(var(--b2));
    border-width: 2px;
    border-style: dashed;
    border-color: hsl(var(--p));
    border-radius: 0.5rem;
    min-width: 300px;
    height: 40px;
  }

  :global(.task-drag-over) {
    box-shadow:
      0 0 0 2px hsl(var(--b1)),
      0 0 0 4px hsl(var(--p));
  }
</style>
