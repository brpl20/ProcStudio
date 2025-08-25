<script lang="ts">
  import { onMount, createEventDispatcher } from 'svelte';
  import { boardStore } from '$lib/stores/boardStore';
  import type { Task, TaskStatus, TaskPriority } from '$lib/types/board.types';
  import { formatDate, isOverdue, isDueToday } from '$lib/utils/date';

  const dispatch = createEventDispatcher();

  export let boardId: string;

  $: boardState = $boardStore;
  $: currentBoard = boardState.currentBoard;
  $: allTasks = getAllTasks();

  // Sorting and filtering state
  let sortColumn: 'title' | 'status' | 'priority' | 'dueDate' | 'assignedTo' = 'title';
  let sortDirection: 'asc' | 'desc' = 'asc';
  let filterStatus: TaskStatus | 'all' = 'all';
  let filterPriority: TaskPriority | 'all' = 'all';
  let searchQuery = '';

  // Pagination
  let currentPage = 1;
  let itemsPerPage = 10;

  $: filteredTasks = filterAndSortTasks(allTasks);
  $: paginatedTasks = paginateTasks(filteredTasks);
  $: totalPages = Math.ceil(filteredTasks.length / itemsPerPage);

  onMount(() => {
    if (!currentBoard) {
      boardStore.initBoard(boardId);
    }
  });

  function getAllTasks(): Task[] {
    if (!currentBoard) {
      return [];
    }
    return currentBoard.columns.flatMap((column) => column.tasks);
  }

  function filterAndSortTasks(tasks: Task[]): Task[] {
    let filtered = [...tasks];

    // Apply search filter
    if (searchQuery) {
      filtered = filtered.filter(
        (task) =>
          task.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
          task.description?.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }

    // Apply status filter
    if (filterStatus !== 'all') {
      filtered = filtered.filter((task) => task.status === filterStatus);
    }

    // Apply priority filter
    if (filterPriority !== 'all') {
      filtered = filtered.filter((task) => task.priority === filterPriority);
    }

    // Sort tasks
    filtered.sort((a, b) => {
      let comparison = 0;

      switch (sortColumn) {
      case 'title':
        comparison = a.title.localeCompare(b.title);
        break;
      case 'status':
        comparison = a.status.localeCompare(b.status);
        break;
      case 'priority':
        const priorityOrder = { low: 1, medium: 2, high: 3, critical: 4 };
        comparison = priorityOrder[a.priority] - priorityOrder[b.priority];
        break;
      case 'dueDate':
        const dateA = a.dueDate ? new Date(a.dueDate).getTime() : 0;
        const dateB = b.dueDate ? new Date(b.dueDate).getTime() : 0;
        comparison = dateA - dateB;
        break;
      case 'assignedTo':
        const assignedA = a.assignedTo?.[0] || '';
        const assignedB = b.assignedTo?.[0] || '';
        comparison = assignedA.localeCompare(assignedB);
        break;
      }

      return sortDirection === 'asc' ? comparison : -comparison;
    });

    return filtered;
  }

  function paginateTasks(tasks: Task[]): Task[] {
    const start = (currentPage - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    return tasks.slice(start, end);
  }

  function handleSort(column: typeof sortColumn) {
    if (sortColumn === column) {
      sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      sortColumn = column;
      sortDirection = 'asc';
    }
  }

  function handleEditTask(task: Task) {
    boardStore.selectTask(task.id);
    dispatch('taskUpdated', task);
  }

  function handleDeleteTask(taskId: string) {
    if (confirm('Tem certeza que deseja excluir esta tarefa?')) {
      const task = allTasks.find((t) => t.id === taskId);
      if (task) {
        const column = currentBoard?.columns.find((col) => col.tasks.some((t) => t.id === taskId));
        if (column) {
          boardStore.deleteTask(column.id, taskId);
          dispatch('taskDeleted', taskId);
        }
      }
    }
  }

  function getStatusBadgeClass(status: TaskStatus) {
    switch (status) {
    case 'completed':
      return 'badge-success';
    case 'in_progress':
      return 'badge-info';
    case 'cancelled':
      return 'badge-error';
    default:
      return 'badge-warning';
    }
  }

  function getPriorityBadgeClass(priority: TaskPriority) {
    switch (priority) {
    case 'critical':
      return 'badge-error';
    case 'high':
      return 'badge-warning';
    case 'medium':
      return 'badge-info';
    default:
      return 'badge-ghost';
    }
  }

  function getStatusLabel(status: TaskStatus) {
    switch (status) {
    case 'completed':
      return 'Concluído';
    case 'in_progress':
      return 'Em Progresso';
    case 'cancelled':
      return 'Cancelado';
    default:
      return 'Pendente';
    }
  }

  function getPriorityLabel(priority: TaskPriority) {
    switch (priority) {
    case 'critical':
      return 'Crítica';
    case 'high':
      return 'Alta';
    case 'medium':
      return 'Média';
    default:
      return 'Baixa';
    }
  }

  function goToPage(page: number) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
    }
  }
</script>

<div class="p-4 h-full overflow-auto">
  <!-- Filters and Search -->
  <div class="card bg-base-100 shadow-xl mb-4">
    <div class="card-body">
      <div class="flex flex-wrap gap-4 items-end">
        <!-- Search -->
        <div class="form-control flex-1 min-w-[200px]">
          <label class="label" for="search">
            <span class="label-text">Buscar</span>
          </label>
          <input
            id="search"
            type="text"
            placeholder="Buscar tarefas..."
            class="input input-bordered"
            bind:value={searchQuery}
          />
        </div>

        <!-- Status Filter -->
        <div class="form-control">
          <label class="label" for="status-filter">
            <span class="label-text">Status</span>
          </label>
          <select id="status-filter" class="select select-bordered" bind:value={filterStatus}>
            <option value="all">Todos</option>
            <option value="pending">Pendente</option>
            <option value="in_progress">Em Progresso</option>
            <option value="completed">Concluído</option>
            <option value="cancelled">Cancelado</option>
          </select>
        </div>

        <!-- Priority Filter -->
        <div class="form-control">
          <label class="label" for="priority-filter">
            <span class="label-text">Prioridade</span>
          </label>
          <select id="priority-filter" class="select select-bordered" bind:value={filterPriority}>
            <option value="all">Todas</option>
            <option value="critical">Crítica</option>
            <option value="high">Alta</option>
            <option value="medium">Média</option>
            <option value="low">Baixa</option>
          </select>
        </div>

        <!-- Items per page -->
        <div class="form-control">
          <label class="label" for="items-per-page">
            <span class="label-text">Itens por página</span>
          </label>
          <select id="items-per-page" class="select select-bordered" bind:value={itemsPerPage}>
            <option value={10}>10</option>
            <option value={25}>25</option>
            <option value={50}>50</option>
            <option value={100}>100</option>
          </select>
        </div>
      </div>

      <!-- Results count -->
      <div class="text-sm text-base-content/70 mt-2">
        Mostrando {paginatedTasks.length} de {filteredTasks.length} tarefas
      </div>
    </div>
  </div>

  <!-- Table -->
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body p-0">
      <div class="overflow-x-auto">
        <table class="table table-zebra">
          <thead>
            <tr>
              <th>
                <button
                  class="btn btn-ghost btn-xs gap-1"
                  on:click={() => handleSort('title')}
                >
                  Título
                  {#if sortColumn === 'title'}
                    <span class="text-primary">
                      {sortDirection === 'asc' ? '↑' : '↓'}
                    </span>
                  {/if}
                </button>
              </th>
              <th>
                <button
                  class="btn btn-ghost btn-xs gap-1"
                  on:click={() => handleSort('status')}
                >
                  Status
                  {#if sortColumn === 'status'}
                    <span class="text-primary">
                      {sortDirection === 'asc' ? '↑' : '↓'}
                    </span>
                  {/if}
                </button>
              </th>
              <th>
                <button
                  class="btn btn-ghost btn-xs gap-1"
                  on:click={() => handleSort('priority')}
                >
                  Prioridade
                  {#if sortColumn === 'priority'}
                    <span class="text-primary">
                      {sortDirection === 'asc' ? '↑' : '↓'}
                    </span>
                  {/if}
                </button>
              </th>
              <th>
                <button
                  class="btn btn-ghost btn-xs gap-1"
                  on:click={() => handleSort('dueDate')}
                >
                  Prazo
                  {#if sortColumn === 'dueDate'}
                    <span class="text-primary">
                      {sortDirection === 'asc' ? '↑' : '↓'}
                    </span>
                  {/if}
                </button>
              </th>
              <th>
                <button
                  class="btn btn-ghost btn-xs gap-1"
                  on:click={() => handleSort('assignedTo')}
                >
                  Responsável
                  {#if sortColumn === 'assignedTo'}
                    <span class="text-primary">
                      {sortDirection === 'asc' ? '↓' : '↑'}
                    </span>
                  {/if}
                </button>
              </th>
              <th>Coluna</th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody>
            {#if paginatedTasks.length === 0}
              <tr>
                <td colspan="7" class="text-center py-8 text-base-content/50">
                  Nenhuma tarefa encontrada
                </td>
              </tr>
            {:else}
              {#each paginatedTasks as task (task.id)}
                <tr class="hover">
                  <td>
                    <div class="flex flex-col">
                      <span class="font-medium">{task.title}</span>
                      {#if task.description}
                        <span class="text-xs text-base-content/70 truncate max-w-xs">
                          {task.description}
                        </span>
                      {/if}
                    </div>
                  </td>
                  <td>
                    <span class="badge {getStatusBadgeClass(task.status)} badge-sm">
                      {getStatusLabel(task.status)}
                    </span>
                  </td>
                  <td>
                    <span class="badge {getPriorityBadgeClass(task.priority)} badge-sm">
                      {getPriorityLabel(task.priority)}
                    </span>
                  </td>
                  <td>
                    {#if task.dueDate}
                      <div class="flex flex-col">
                        <span
                          class:text-error={isOverdue(task.dueDate)}
                          class:text-warning={isDueToday(task.dueDate)}
                        >
                          {formatDate(task.dueDate)}
                        </span>
                        {#if isOverdue(task.dueDate)}
                          <span class="text-xs text-error">Atrasado</span>
                        {:else if isDueToday(task.dueDate)}
                          <span class="text-xs text-warning">Hoje</span>
                        {/if}
                      </div>
                    {:else}
                      <span class="text-base-content/50">-</span>
                    {/if}
                  </td>
                  <td>
                    {#if task.assignedTo && task.assignedTo.length > 0}
                      <div class="avatar-group -space-x-6">
                        {#each task.assignedTo.slice(0, 3) as assignee}
                          <div class="avatar placeholder">
                            <div class="bg-neutral text-neutral-content rounded-full w-8">
                              <span class="text-xs">{assignee.substring(0, 2).toUpperCase()}</span>
                            </div>
                          </div>
                        {/each}
                        {#if task.assignedTo.length > 3}
                          <div class="avatar placeholder">
                            <div class="bg-neutral text-neutral-content rounded-full w-8">
                              <span class="text-xs">+{task.assignedTo.length - 3}</span>
                            </div>
                          </div>
                        {/if}
                      </div>
                    {:else}
                      <span class="text-base-content/50">-</span>
                    {/if}
                  </td>
                  <td>
                    {#each currentBoard?.columns || [] as column}
                      {#if column.tasks.some((t) => t.id === task.id)}
                        <div class="flex items-center gap-1">
                          <div
                            class="w-3 h-3 rounded-full"
                            style="background-color: {column.color}"
                          ></div>
                          <span class="text-sm">{column.title}</span>
                        </div>
                      {/if}
                    {/each}
                  </td>
                  <td>
                    <div class="flex gap-1">
                      <button
                        class="btn btn-ghost btn-xs"
                        on:click={() => handleEditTask(task)}
                        title="Editar"
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
                      <button
                        class="btn btn-ghost btn-xs text-error"
                        on:click={() => handleDeleteTask(task.id)}
                        title="Excluir"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                          />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              {/each}
            {/if}
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      {#if totalPages > 1}
        <div class="flex justify-center p-4">
          <div class="join">
            <button
              class="join-item btn btn-sm"
              on:click={() => goToPage(currentPage - 1)}
              disabled={currentPage === 1}
            >
              «
            </button>

            {#each Array(totalPages) as _, i}
              {#if i + 1 === 1 || i + 1 === totalPages || (i + 1 >= currentPage - 2 && i + 1 <= currentPage + 2)}
                <button
                  class="join-item btn btn-sm"
                  class:btn-active={currentPage === i + 1}
                  on:click={() => goToPage(i + 1)}
                >
                  {i + 1}
                </button>
              {:else if i + 1 === currentPage - 3 || i + 1 === currentPage + 3}
                <button class="join-item btn btn-sm btn-disabled">...</button>
              {/if}
            {/each}

            <button
              class="join-item btn btn-sm"
              on:click={() => goToPage(currentPage + 1)}
              disabled={currentPage === totalPages}
            >
              »
            </button>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>