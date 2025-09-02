<script lang="ts">
  import { boardStore } from '$lib/stores/boardStore';
  import { dragStore, createDragData } from '$lib/stores/dragStore';
  import type { Task, TaskPriority, TaskStatus } from '$lib/types/board.types';
  import { formatDate } from '$lib/utils/date';

  export let task: Task;

  $: dragState = $dragStore;
  $: isDragging = dragState.isDragging && dragState.draggedTask?.id === task.id;

  // Priority colors
  const priorityColors: Record<TaskPriority, string> = {
    low: 'badge-info',
    medium: 'badge-warning',
    high: 'badge-error',
    urgent: 'badge-error badge-outline'
  };

  // Status colors
  const statusColors: Record<TaskStatus, string> = {
    pending: 'badge-ghost',
    in_progress: 'badge-primary',
    completed: 'badge-success',
    cancelled: 'badge-error'
  };

  // Priority labels
  const priorityLabels: Record<TaskPriority, string> = {
    low: 'Baixa',
    medium: 'Média',
    high: 'Alta',
    urgent: 'Urgente'
  };

  // Status labels
  const statusLabels: Record<TaskStatus, string> = {
    pending: 'Pendente',
    in_progress: 'Em Progresso',
    completed: 'Concluída',
    cancelled: 'Cancelada'
  };

  // Drag handlers
  function handleDragStart(event: DragEvent) {
    if (!event.dataTransfer) {
      return;
    }

    dragStore.startTaskDrag(task, task.columnId);
    event.dataTransfer.setData('application/json', createDragData('task', task));
    event.dataTransfer.effectAllowed = 'move';
  }

  function handleDragEnd() {
    dragStore.endDrag();
  }

  // Task actions
  function handleTaskClick() {
    boardStore.selectTask(task.id);
  }

  function handleEditTask() {
    // TODO: Open task edit modal
    console.log('Edit task:', task.id);
  }

  function handleDeleteTask() {
    if (window.confirm('Tem certeza que deseja excluir esta tarefa?')) {
      boardStore.deleteTask(task.id);
    }
  }

  // Quick status update
  function handleStatusToggle() {
    const newStatus: TaskStatus = task.status === 'completed' ? 'pending' : 'completed';
    boardStore.updateTask(task.id, { status: newStatus });
  }

  // Format date helper
  function formatDueDate(date: Date): string {
    const now = new Date();
    const diffDays = Math.ceil((date.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

    if (diffDays < 0) {
      return 'Atrasada';
    }
    if (diffDays === 0) {
      return 'Hoje';
    }
    if (diffDays === 1) {
      return 'Amanhã';
    }
    return formatDate(date);
  }

  function getDueDateClass(date: Date): string {
    const now = new Date();
    const diffDays = Math.ceil((date.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

    if (diffDays < 0) {
      return 'text-error';
    }
    if (diffDays === 0) {
      return 'text-warning';
    }
    return 'text-base-content/70';
  }
</script>

<div
  class="card card-compact bg-base-100 shadow-sm border border-base-300 cursor-pointer hover:shadow-md transition-all duration-200 group"
  class:opacity-50={isDragging}
  class:cursor-move={isDragging}
  draggable="true"
  data-task-id={task.id}
  on:dragstart={handleDragStart}
  on:dragend={handleDragEnd}
  on:click={handleTaskClick}
  role="button"
  tabindex="0"
  on:keydown={(e) => e.key === 'Enter' && handleTaskClick()}
>
  <div class="card-body p-3">
    <!-- Task Title -->
    <h4 class="card-title text-sm font-medium line-clamp-2 mb-2">
      {task.title}
    </h4>

    <!-- Task Description (if exists) -->
    {#if task.description}
      <p class="text-xs text-base-content/70 line-clamp-2 mb-2">
        {task.description}
      </p>
    {/if}

    <!-- Tags/Labels Row -->
    <div class="flex flex-wrap gap-1 mb-2">
      <!-- Priority Badge -->
      <div class="badge badge-xs {priorityColors[task.priority]}">
        {priorityLabels[task.priority]}
      </div>

      <!-- Status Badge -->
      <div class="badge badge-xs {statusColors[task.status]}">
        {statusLabels[task.status]}
      </div>

      <!-- Custom Labels -->
      {#if task.labels}
        {#each task.labels as label}
          <div
            class="badge badge-xs"
            style="background-color: {label.color}20; color: {label.color}; border-color: {label.color}40;"
          >
            {label.name}
          </div>
        {/each}
      {/if}
    </div>

    <!-- Due Date (if exists) -->
    {#if task.dueDate}
      <div class="flex items-center gap-1 mb-2">
        <svg
          class="w-3 h-3 {getDueDateClass(task.dueDate)}"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
          />
        </svg>
        <span class="text-xs {getDueDateClass(task.dueDate)}">
          {formatDueDate(task.dueDate)}
        </span>
      </div>
    {/if}

    <!-- Assigned Users (if exists) -->
    {#if task.assignedTo && task.assignedTo.length > 0}
      <div class="flex items-center gap-1 mb-2">
        <svg
          class="w-3 h-3 text-base-content/50"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
          />
        </svg>
        <div class="flex -space-x-1">
          {#each task.assignedTo.slice(0, 3) as userId}
            <div class="avatar placeholder">
              <div class="bg-neutral text-neutral-content rounded-full w-5 h-5">
                <span class="text-xs">{userId.charAt(0).toUpperCase()}</span>
              </div>
            </div>
          {/each}
          {#if task.assignedTo.length > 3}
            <div class="avatar placeholder">
              <div class="bg-base-300 text-base-content rounded-full w-5 h-5">
                <span class="text-xs">+{task.assignedTo.length - 3}</span>
              </div>
            </div>
          {/if}
        </div>
      </div>
    {/if}

    <!-- Attachments/Comments indicators -->
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-2">
        <!-- Attachments -->
        {#if task.attachments && task.attachments.length > 0}
          <div class="flex items-center gap-1 text-xs text-base-content/50">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"
              />
            </svg>
            <span>{task.attachments.length}</span>
          </div>
        {/if}

        <!-- Comments -->
        {#if task.comments && task.comments.length > 0}
          <div class="flex items-center gap-1 text-xs text-base-content/50">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              />
            </svg>
            <span>{task.comments.length}</span>
          </div>
        {/if}
      </div>

      <!-- Quick Actions (visible on hover) -->
      <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
        <!-- Complete/Uncomplete Toggle -->
        <button
          class="btn btn-ghost btn-xs"
          class:text-success={task.status === 'completed'}
          on:click|stopPropagation={handleStatusToggle}
          title={task.status === 'completed' ? 'Marcar como pendente' : 'Marcar como concluída'}
          aria-label={task.status === 'completed'
            ? 'Marcar como pendente'
            : 'Marcar como concluída'}
        >
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 13l4 4L19 7"
            />
          </svg>
        </button>

        <!-- Edit Button -->
        <button
          class="btn btn-ghost btn-xs"
          on:click|stopPropagation={handleEditTask}
          title="Editar tarefa"
          aria-label="Editar tarefa"
        >
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
            />
          </svg>
        </button>

        <!-- Delete Button -->
        <button
          class="btn btn-ghost btn-xs text-error hover:bg-error hover:text-error-content"
          on:click|stopPropagation={handleDeleteTask}
          title="Excluir tarefa"
          aria-label="Excluir tarefa"
        >
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
            />
          </svg>
        </button>
      </div>
    </div>
  </div>
</div>

<style>
  /* Line clamp utilities */
  .line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  /* Smooth transitions */
  .transition-all {
    transition-property: all;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 200ms;
  }

  .transition-opacity {
    transition-property: opacity;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 200ms;
  }
</style>
