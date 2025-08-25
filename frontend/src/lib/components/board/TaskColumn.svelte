<script lang="ts">
  import { boardStore } from '$lib/stores/boardStore';
  import { dragStore, createDragData, parseDragData, dragClasses } from '$lib/stores/dragStore';
  import TaskCard from './TaskCard.svelte';
  import ColumnHeader from './ColumnHeader.svelte';
  import AddTaskButton from './AddTaskButton.svelte';
  import type { Column, Task, MoveTaskDto } from '$lib/types/board.types';

  export let column: Column;

  $: dragState = $dragStore;
  $: tasks = column.tasks.sort((a, b) => a.position - b.position);
  $: isWipLimitExceeded = column.wipLimit && tasks.length >= column.wipLimit;
  $: canDropTask = dragState.isDragging && dragState.draggedTask !== null;
  $: isTargetColumn = dragState.targetColumnId === column.id;

  let isDragOver = false;
  let dropPosition = 0;

  // Task drag and drop handlers
  function handleTaskDragOver(event: DragEvent) {
    if (!canDropTask) {
      return;
    }

    event.preventDefault();
    event.dataTransfer!.dropEffect = 'move';

    isDragOver = true;
    dragStore.setTargetColumn(column.id);

    // Calculate drop position based on mouse position
    const rect = (event.currentTarget as HTMLElement).getBoundingClientRect();
    const y = event.clientY - rect.top;
    const taskElements = Array.from(event.currentTarget!.querySelectorAll('[data-task-id]'));

    let position = 0;
    for (let i = 0; i < taskElements.length; i++) {
      const taskRect = taskElements[i].getBoundingClientRect();
      const taskY = taskRect.top - rect.top;
      if (y > taskY + taskRect.height / 2) {
        position = i + 1;
      } else {
        break;
      }
    }

    dropPosition = position;
    dragStore.setDropPosition(position);
  }

  function handleTaskDragLeave(event: DragEvent) {
    // Only hide drag over state if we're actually leaving the column
    const rect = (event.currentTarget as HTMLElement).getBoundingClientRect();
    const x = event.clientX;
    const y = event.clientY;

    if (x < rect.left || x > rect.right || y < rect.top || y > rect.bottom) {
      isDragOver = false;
      dragStore.setTargetColumn(null);
      dragStore.setDropPosition(null);
    }
  }

  function handleTaskDrop(event: DragEvent) {
    event.preventDefault();

    const dragData = parseDragData(event.dataTransfer!);
    if (!dragData || dragData.type !== 'task' || !dragState.sourceColumnId) {
      return;
    }

    const task = dragData.data as Task;
    const sourceColumnId = dragState.sourceColumnId;

    // Don't drop on same position
    if (sourceColumnId === column.id && task.position === dropPosition) {
      dragStore.endDrag();
      isDragOver = false;
      return;
    }

    const moveData: MoveTaskDto = {
      taskId: task.id,
      sourceColumnId,
      targetColumnId: column.id,
      position: dropPosition
    };

    boardStore.moveTask(moveData);
    dragStore.endDrag();
    isDragOver = false;
  }

  function handleTaskDragEnd() {
    dragStore.endDrag();
    isDragOver = false;
  }

  // Add task handler
  function handleAddTask(taskTitle: string) {
    if (!taskTitle.trim()) {
      return;
    }

    boardStore.addTask(column.id, {
      title: taskTitle.trim(),
      columnId: column.id
    });
  }
</script>

<div class="w-80 bg-base-200 rounded-lg shadow-sm flex flex-col max-h-full">
  <!-- Column Header -->
  <ColumnHeader {column} taskCount={tasks.length} />

  <!-- Tasks Container -->
  <div
    role="region"
    aria-label={`Tarefas da coluna ${column.title}`}
    class="flex-1 p-3 overflow-y-auto min-h-32 transition-colors duration-200"
    class:bg-primary={isDragOver && canDropTask}
    class:bg-opacity-10={isDragOver && canDropTask}
    class:ring-2={isDragOver && canDropTask}
    class:ring-primary={isDragOver && canDropTask}
    on:dragover={handleTaskDragOver}
    on:dragleave={handleTaskDragLeave}
    on:drop={handleTaskDrop}
    on:dragend={handleTaskDragEnd}
  >
    {#if tasks.length === 0}
      <!-- Empty state -->
      <div class="text-center py-8 text-base-content/50">
        {#if canDropTask && isDragOver}
          <div class="border-2 border-dashed border-primary rounded-lg p-4">
            <p class="text-primary font-medium">Solte a tarefa aqui</p>
          </div>
        {:else}
          <p>Nenhuma tarefa</p>
        {/if}
      </div>
    {:else}
      <div class="space-y-2">
        {#each tasks as task, index (task.id)}
          <!-- Drop zone before task -->
          {#if canDropTask && isDragOver && dropPosition === index}
            <div class="h-2 bg-primary bg-opacity-20 rounded border-2 border-dashed border-primary"></div>
          {/if}

          <TaskCard {task} />
        {/each}

        <!-- Drop zone after last task -->
        {#if canDropTask && isDragOver && dropPosition === tasks.length}
          <div class="h-2 bg-primary bg-opacity-20 rounded border-2 border-dashed border-primary"></div>
        {/if}
      </div>
    {/if}
  </div>

  <!-- Add Task Section -->
  <div class="p-3 pt-0">
    <AddTaskButton onAddTask={handleAddTask} disabled={isWipLimitExceeded} />

    {#if isWipLimitExceeded}
      <div class="mt-2">
        <div class="alert alert-warning alert-sm">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="stroke-current shrink-0 h-4 w-4"
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
          <span class="text-xs">Limite WIP atingido</span>
        </div>
      </div>
    {/if}
  </div>
</div>

<style>
  /* Smooth transitions for drag states */
  .transition-colors {
    transition-property: background-color, border-color, color, fill, stroke;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 200ms;
  }

  /* Custom scrollbar for tasks container */
  .overflow-y-auto::-webkit-scrollbar {
    width: 6px;
  }

  .overflow-y-auto::-webkit-scrollbar-track {
    background: hsl(var(--b3));
    border-radius: 9999px;
  }

  .overflow-y-auto::-webkit-scrollbar-thumb {
    background: hsl(var(--bc) / 0.2);
    border-radius: 9999px;
  }

  .overflow-y-auto::-webkit-scrollbar-thumb:hover {
    background: hsl(var(--bc) / 0.3);
  }
</style>
