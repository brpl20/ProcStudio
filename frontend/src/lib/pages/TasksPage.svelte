<script lang="ts">
  import { onMount } from 'svelte';
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import Icon from '../icons.svelte';
  import { authStore } from '../stores/authStore.js';

  interface Task {
    id: number;
    title: string;
    description?: string;
    status: 'pending' | 'in_progress' | 'completed';
    priority: 'low' | 'medium' | 'high';
    dueDate?: string;
    assignedTo?: string;
    createdAt: string;
    updatedAt: string;
  }

  let tasks: Task[] = [];
  let isLoading = false;
  let error = '';
  let success = '';
  let showNewTaskForm = false;

  // New task form fields
  let newTaskTitle = '';
  let newTaskDescription = '';
  let newTaskStatus = 'pending';
  let newTaskPriority = 'medium';
  let newTaskDueDate = '';

  // Edit task state
  let editingTask: Task | null = null;
  let editTitle = '';
  let editDescription = '';
  let editStatus = '';
  let editPriority = '';
  let editDueDate = '';

  const { user } = $authStore;

  async function loadTasks(): Promise<void> {
    isLoading = true;
    error = '';

    try {
      // Simulated tasks data - replace with actual API call
      tasks = [
        {
          id: 1,
          title: 'Revisar contrato cliente ABC',
          description: 'Análise detalhada das cláusulas contratuais',
          status: 'in_progress',
          priority: 'high',
          dueDate: '2024-02-15',
          assignedTo: 'João Silva',
          createdAt: '2024-01-10',
          updatedAt: '2024-01-15'
        },
        {
          id: 2,
          title: 'Preparar documentos para audiência',
          description: 'Organizar peças processuais',
          status: 'pending',
          priority: 'medium',
          dueDate: '2024-02-20',
          assignedTo: 'Maria Santos',
          createdAt: '2024-01-12',
          updatedAt: '2024-01-12'
        }
      ];
    } catch (err) {
      error = 'Erro ao carregar tarefas: ' + (err as Error).message;
    } finally {
      isLoading = false;
    }
  }

  async function addTask(): Promise<void> {
    if (!newTaskTitle.trim()) {
      error = 'Título da tarefa é obrigatório';
      return;
    }

    isLoading = true;
    error = '';

    try {
      const newTask: Task = {
        id: Date.now(),
        title: newTaskTitle,
        description: newTaskDescription,
        status: newTaskStatus as Task['status'],
        priority: newTaskPriority as Task['priority'],
        dueDate: newTaskDueDate || undefined,
        assignedTo: (user as any)?.data?.name || 'Usuário',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };

      tasks = [newTask, ...tasks];
      success = 'Tarefa criada com sucesso!';
      resetNewTaskForm();
    } catch (err) {
      error = 'Erro ao criar tarefa: ' + (err as Error).message;
    } finally {
      isLoading = false;
    }
  }

  async function saveEditTask(): Promise<void> {
    if (!editingTask || !editTitle.trim()) {
      error = 'Título da tarefa é obrigatório';
      return;
    }

    isLoading = true;
    error = '';

    try {
      tasks = tasks.map((task) =>
        task.id === editingTask?.id
          ? {
              ...task,
              title: editTitle,
              description: editDescription,
              status: editStatus as Task['status'],
              priority: editPriority as Task['priority'],
              dueDate: editDueDate || undefined,
              updatedAt: new Date().toISOString()
            }
          : task
      );

      success = 'Tarefa atualizada com sucesso!';
      cancelEdit();
    } catch (err) {
      error = 'Erro ao atualizar tarefa: ' + (err as Error).message;
    } finally {
      isLoading = false;
    }
  }

  async function deleteTask(taskId: number): Promise<void> {
    if (!(globalThis as any).confirm('Tem certeza que deseja excluir esta tarefa?')) {
      return;
    }

    isLoading = true;
    error = '';

    try {
      tasks = tasks.filter((task) => task.id !== taskId);
      success = 'Tarefa excluída com sucesso!';
    } catch (err) {
      error = 'Erro ao excluir tarefa: ' + (err as Error).message;
    } finally {
      isLoading = false;
    }
  }

  function startEdit(task: Task): void {
    editingTask = task;
    editTitle = task.title;
    editDescription = task.description || '';
    editStatus = task.status;
    editPriority = task.priority;
    editDueDate = task.dueDate || '';
  }

  function cancelEdit(): void {
    editingTask = null;
    editTitle = '';
    editDescription = '';
    editStatus = '';
    editPriority = '';
    editDueDate = '';
  }

  function resetNewTaskForm(): void {
    newTaskTitle = '';
    newTaskDescription = '';
    newTaskStatus = 'pending';
    newTaskPriority = 'medium';
    newTaskDueDate = '';
    showNewTaskForm = false;
  }

  function getStatusBadge(status: Task['status']): string {
    const badges = {
      pending: 'badge-warning',
      in_progress: 'badge-info',
      completed: 'badge-success'
    };
    return badges[status] || 'badge-neutral';
  }

  function getPriorityBadge(priority: Task['priority']): string {
    const badges = {
      low: 'badge-ghost',
      medium: 'badge-warning',
      high: 'badge-error'
    };
    return badges[priority] || 'badge-neutral';
  }

  function getStatusLabel(status: Task['status']): string {
    const labels = {
      pending: 'Pendente',
      in_progress: 'Em Andamento',
      completed: 'Concluída'
    };
    return labels[status] || status;
  }

  function getPriorityLabel(priority: Task['priority']): string {
    const labels = {
      low: 'Baixa',
      medium: 'Média',
      high: 'Alta'
    };
    return labels[priority] || priority;
  }

  onMount(() => {
    loadTasks();
  });

  // Clear success/error messages after 5 seconds
  $: if (success || error) {
    setTimeout(() => {
      success = '';
      error = '';
    }, 5000);
  }
</script>

<AuthSidebar activeSection="tasks">
  <div class="container mx-auto py-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">
            <Icon name="tasks" className="h-8 w-8" />
            Tarefas
          </h2>
          <button
            class="btn btn-primary"
            onclick={() => (showNewTaskForm = !showNewTaskForm)}
            disabled={isLoading}
          >
            <Icon name="tasks" className="h-4 w-4" />
            Nova Tarefa
          </button>
        </div>

        <!-- Error Message -->
        {#if error}
          <div class="alert alert-error mb-4">
            <span>{error}</span>
          </div>
        {/if}

        <!-- Success Message -->
        {#if success}
          <div class="alert alert-success mb-4">
            <span>{success}</span>
          </div>
        {/if}

        <!-- New Task Form -->
        {#if showNewTaskForm}
          <div class="card bg-base-200 shadow mb-6">
            <div class="card-body">
              <h3 class="card-title">Nova Tarefa</h3>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label" for="task-title">
                    <span class="label-text">Título *</span>
                  </label>
                  <input
                    id="task-title"
                    type="text"
                    placeholder="Digite o título da tarefa"
                    class="input input-bordered"
                    bind:value={newTaskTitle}
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label" for="task-due-date">
                    <span class="label-text">Data de Vencimento</span>
                  </label>
                  <input
                    id="task-due-date"
                    type="date"
                    class="input input-bordered"
                    bind:value={newTaskDueDate}
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label" for="task-status">
                    <span class="label-text">Status</span>
                  </label>
                  <select
                    id="task-status"
                    class="select select-bordered"
                    bind:value={newTaskStatus}
                    disabled={isLoading}
                  >
                    <option value="pending">Pendente</option>
                    <option value="in_progress">Em Andamento</option>
                    <option value="completed">Concluída</option>
                  </select>
                </div>

                <div class="form-control">
                  <label class="label" for="task-priority">
                    <span class="label-text">Prioridade</span>
                  </label>
                  <select
                    id="task-priority"
                    class="select select-bordered"
                    bind:value={newTaskPriority}
                    disabled={isLoading}
                  >
                    <option value="low">Baixa</option>
                    <option value="medium">Média</option>
                    <option value="high">Alta</option>
                  </select>
                </div>

                <div class="form-control md:col-span-2">
                  <label class="label" for="task-description">
                    <span class="label-text">Descrição</span>
                  </label>
                  <textarea
                    id="task-description"
                    class="textarea textarea-bordered"
                    placeholder="Digite a descrição da tarefa"
                    bind:value={newTaskDescription}
                    disabled={isLoading}
                  ></textarea>
                </div>
              </div>

              <div class="card-actions justify-end mt-4">
                <button class="btn btn-ghost" onclick={resetNewTaskForm} disabled={isLoading}>
                  Cancelar
                </button>
                <button
                  class="btn btn-primary"
                  onclick={addTask}
                  disabled={isLoading || !newTaskTitle.trim()}
                >
                  {#if isLoading}
                    <span class="loading loading-spinner loading-sm"></span>
                  {/if}
                  Criar Tarefa
                </button>
              </div>
            </div>
          </div>
        {/if}

        <!-- Loading State -->
        {#if isLoading && tasks.length === 0}
          <div class="flex justify-center py-8">
            <span class="loading loading-spinner loading-lg"></span>
          </div>
        {/if}

        <!-- Tasks List -->
        {#if tasks.length > 0}
          <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
              <thead>
                <tr>
                  <th>Título</th>
                  <th>Descrição</th>
                  <th>Status</th>
                  <th>Prioridade</th>
                  <th>Vencimento</th>
                  <th>Responsável</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {#each tasks as task (task.id)}
                  <tr>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <input
                          type="text"
                          class="input input-sm input-bordered w-full"
                          bind:value={editTitle}
                          disabled={isLoading}
                        />
                      {:else}
                        <div class="font-semibold">{task.title}</div>
                      {/if}
                    </td>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <textarea
                          class="textarea textarea-sm textarea-bordered w-full"
                          bind:value={editDescription}
                          disabled={isLoading}
                        ></textarea>
                      {:else}
                        <div class="text-sm">
                          {task.description || '-'}
                        </div>
                      {/if}
                    </td>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <select
                          class="select select-sm select-bordered"
                          bind:value={editStatus}
                          disabled={isLoading}
                        >
                          <option value="pending">Pendente</option>
                          <option value="in_progress">Em Andamento</option>
                          <option value="completed">Concluída</option>
                        </select>
                      {:else}
                        <span class="badge {getStatusBadge(task.status)}">
                          {getStatusLabel(task.status)}
                        </span>
                      {/if}
                    </td>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <select
                          class="select select-sm select-bordered"
                          bind:value={editPriority}
                          disabled={isLoading}
                        >
                          <option value="low">Baixa</option>
                          <option value="medium">Média</option>
                          <option value="high">Alta</option>
                        </select>
                      {:else}
                        <span class="badge {getPriorityBadge(task.priority)}">
                          {getPriorityLabel(task.priority)}
                        </span>
                      {/if}
                    </td>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <input
                          type="date"
                          class="input input-sm input-bordered"
                          bind:value={editDueDate}
                          disabled={isLoading}
                        />
                      {:else}
                        {task.dueDate || '-'}
                      {/if}
                    </td>
                    <td>{task.assignedTo || '-'}</td>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <div class="flex gap-2">
                          <button
                            class="btn btn-sm btn-success"
                            onclick={saveEditTask}
                            disabled={isLoading}
                          >
                            <Icon name="success" className="h-4 w-4" />
                          </button>
                          <button
                            class="btn btn-sm btn-ghost"
                            onclick={cancelEdit}
                            disabled={isLoading}
                          >
                            <Icon name="error" className="h-4 w-4" />
                          </button>
                        </div>
                      {:else}
                        <div class="flex gap-2">
                          <button
                            class="btn btn-sm btn-ghost"
                            onclick={() => startEdit(task)}
                            disabled={isLoading}
                          >
                            <Icon name="settings" className="h-4 w-4" />
                          </button>
                          <button
                            class="btn btn-sm btn-error"
                            onclick={() => deleteTask(task.id)}
                            disabled={isLoading}
                          >
                            <Icon name="error" className="h-4 w-4" />
                          </button>
                        </div>
                      {/if}
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        {:else if !isLoading}
          <div class="text-center py-8">
            <p class="text-lg opacity-70">Nenhuma tarefa encontrada</p>
            <p class="text-sm opacity-50">Clique em "Nova Tarefa" para começar</p>
          </div>
        {/if}

        <div class="card-actions justify-end mt-6">
          <button class="btn btn-primary" onclick={loadTasks} disabled={isLoading}>
            {#if isLoading}
              <span class="loading loading-spinner loading-sm"></span>
            {/if}
            Atualizar
          </button>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
