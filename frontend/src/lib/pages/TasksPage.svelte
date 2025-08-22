<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import BoardView from '../components/board/BoardView.svelte';
  import TableView from '../components/board/TableView.svelte';
  import { boardStore } from '../stores/boardStore';
  import api from '../api/index';
  import type {
    Task as BoardTask,
    CreateTaskDto,
    TaskStatus,
    TaskPriority
  } from '../types/board.types';

  // Legacy API integration - map jobs to board tasks
  let isLoading = false;
  let error = '';
  let success = '';

  // View state
  let currentView: 'board' | 'list' = 'board';

  $: boardState = $boardStore;
  $: currentBoard = boardState.currentBoard;

  onMount(async () => {
    await loadTasksFromAPI();
  });

  // Load tasks from the existing API and populate board
  async function loadTasksFromAPI() {
    isLoading = true;
    error = '';

    try {
      const result = await api.jobs.getJobs();

      if (result.success) {
        const jobs = result.data || [];

        // Initialize board with empty columns if not exists
        if (!currentBoard) {
          await boardStore.initBoard('1');
        }

        // Clear existing tasks
        if (currentBoard) {
          for (const column of currentBoard.columns) {
            column.tasks = [];
          }
        }

        // Map jobs to board tasks and distribute to columns based on status
        for (const job of jobs) {
          const boardTask = mapJobToBoardTask(job);
          const targetColumn = getColumnForStatus(boardTask.status);

          if (targetColumn) {
            boardStore.addTask(targetColumn.id, {
              title: boardTask.title,
              description: boardTask.description,
              status: boardTask.status,
              priority: boardTask.priority,
              columnId: targetColumn.id,
              assignedTo: boardTask.assignedTo,
              dueDate: boardTask.dueDate
            });
          }
        }

        success = 'Tarefas carregadas com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao carregar tarefas';
      }
    } catch (err) {
      console.error('Error loading tasks:', err);
      error = 'Erro ao carregar tarefas';
    } finally {
      isLoading = false;
    }
  }

  // Map legacy job structure to board task
  function mapJobToBoardTask(job: any): BoardTask {
    return {
      id: job.id?.toString() || '',
      columnId: '',
      title: job.title || '',
      description: job.description || undefined,
      status: (job.status as TaskStatus) || 'pending',
      priority: (job.priority as TaskPriority) || 'medium',
      position: 0,
      assignedTo: job.assigned_to ? [job.assigned_to.toString()] : undefined,
      dueDate: job.deadline ? new Date(job.deadline) : undefined,
      createdAt: job.created_at ? new Date(job.created_at) : new Date(),
      updatedAt: job.updated_at ? new Date(job.updated_at) : new Date(),
      createdBy: job.created_by?.toString() || 'unknown'
    };
  }

  // Get target column based on task status
  function getColumnForStatus(status: TaskStatus) {
    if (!currentBoard) {
      return null;
    }

    const statusToColumnMap: Record<TaskStatus, string> = {
      pending: 'A Fazer',
      in_progress: 'Em Progresso',
      completed: 'Concluído',
      cancelled: 'Cancelado'
    };

    const targetTitle = statusToColumnMap[status];
    return currentBoard.columns.find((col) => col.title === targetTitle) || currentBoard.columns[0];
  }

  // API integration functions
  async function createTaskInAPI(task: BoardTask): Promise<boolean> {
    try {
      const taskData = {
        title: task.title,
        description: task.description || undefined,
        priority: task.priority,
        assigned_to: task.assignedTo?.[0] ? parseInt(task.assignedTo[0]) : undefined,
        deadline: task.dueDate?.toISOString() || undefined,
        status: task.status
      };

      const result = await api.jobs.createJob(taskData);

      if (result.success) {
        success = 'Tarefa criada com sucesso';
        setTimeout(() => (success = ''), 3000);
        return true;
      } else {
        error = result.message || 'Erro ao criar tarefa';
        return false;
      }
    } catch (err) {
      console.error('Error creating task:', err);
      error = 'Erro ao criar tarefa';
      return false;
    }
  }

  async function updateTaskInAPI(task: BoardTask): Promise<boolean> {
    try {
      const taskData = {
        title: task.title,
        description: task.description || undefined,
        priority: task.priority,
        assigned_to: task.assignedTo?.[0] ? parseInt(task.assignedTo[0]) : undefined,
        deadline: task.dueDate?.toISOString() || undefined,
        status: task.status
      };

      const result = await api.jobs.updateJob(parseInt(task.id), taskData);

      if (result.success) {
        success = 'Tarefa atualizada com sucesso';
        setTimeout(() => (success = ''), 3000);
        return true;
      } else {
        error = result.message || 'Erro ao atualizar tarefa';
        return false;
      }
    } catch (err) {
      console.error('Error updating task:', err);
      error = 'Erro ao atualizar tarefa';
      return false;
    }
  }

  async function deleteTaskFromAPI(taskId: string): Promise<boolean> {
    try {
      const result = await api.jobs.deleteJob(parseInt(taskId));

      if (result.success) {
        success = 'Tarefa excluída com sucesso';
        setTimeout(() => (success = ''), 3000);
        return true;
      } else {
        error = result.message || 'Erro ao excluir tarefa';
        return false;
      }
    } catch (err) {
      console.error('Error deleting task:', err);
      error = 'Erro ao excluir tarefa';
      return false;
    }
  }

  // Enhanced board event handlers
  function handleTaskCreated(event: CustomEvent) {
    const task = event.detail as BoardTask;
    createTaskInAPI(task);
  }

  function handleTaskUpdated(event: CustomEvent) {
    const task = event.detail as BoardTask;
    updateTaskInAPI(task);
  }

  function handleTaskDeleted(event: CustomEvent) {
    const taskId = event.detail as string;
    deleteTaskFromAPI(taskId);
  }

  function handleTaskMoved(event: CustomEvent) {
    const { task, targetStatus } = event.detail;

    // Update status based on target column
    const updatedTask = { ...task, status: targetStatus };
    updateTaskInAPI(updatedTask);
  }

  // View toggle
  function toggleView(view: 'board' | 'list') {
    currentView = view;
  }

  // Refresh function
  async function refreshData() {
    await loadTasksFromAPI();
  }
</script>

<AuthSidebar>
  <div class="h-full flex flex-col bg-base-100">
    <!-- Header with view controls -->
    <div class="sticky top-0 z-30 bg-base-100 border-b border-base-300 shadow-sm">
      <div class="p-4">
        <div class="flex items-center justify-between flex-wrap gap-4">
          <div class="flex items-center gap-4">
            <h1 class="text-3xl font-bold flex items-center gap-2">📋 Gerenciamento de Tarefas</h1>

            <!-- View Toggle -->
            <div class="join">
              <button
                class="join-item btn btn-sm"
                class:btn-active={currentView === 'board'}
                on:click={() => toggleView('board')}
              >
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7m0 10a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 00-2-2h-2a2 2 0 00-2 2"
                  />
                </svg>
                Quadro
              </button>
              <button
                class="join-item btn btn-sm"
                class:btn-active={currentView === 'list'}
                on:click={() => toggleView('list')}
              >
                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 6h16M4 10h16M4 14h16M4 18h16"
                  />
                </svg>
                Lista
              </button>
            </div>
          </div>

          <!-- Action buttons -->
          <div class="flex items-center gap-2">
            <button
              class="btn btn-outline btn-sm"
              class:loading={isLoading}
              on:click={refreshData}
              disabled={isLoading}
              title="Atualizar dados"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                />
              </svg>
              {#if !isLoading}Atualizar{/if}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Messages -->
    {#if error}
      <div class="p-4">
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
            <button class="btn btn-sm btn-ghost" on:click={() => (error = '')}> Dispensar </button>
          </div>
        </div>
      </div>
    {/if}

    {#if success}
      <div class="p-4">
        <div class="alert alert-success">
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
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>{success}</span>
        </div>
      </div>
    {/if}

    <!-- Main Content -->
    <div class="flex-1 overflow-hidden">
      {#if currentView === 'board'}
        <BoardView
          boardId="1"
          on:taskCreated={handleTaskCreated}
          on:taskUpdated={handleTaskUpdated}
          on:taskDeleted={handleTaskDeleted}
          on:taskMoved={handleTaskMoved}
        />
      {:else if currentView === 'list'}
        <!-- Table View -->
        <TableView
          boardId="1"
          on:taskCreated={handleTaskCreated}
          on:taskUpdated={handleTaskUpdated}
          on:taskDeleted={handleTaskDeleted}
          on:taskMoved={handleTaskMoved}
        />
      {/if}
    </div>
  </div>
</AuthSidebar>

<style>
  /* Ensure full height layout */
  :global(html, body) {
    height: 100%;
  }

  .btn-active {
    background-color: hsl(var(--p));
    color: hsl(var(--pc));
  }
</style>
