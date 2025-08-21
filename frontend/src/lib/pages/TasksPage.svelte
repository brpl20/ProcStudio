<script>
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import api from '../api/index';
  import { onMount } from 'svelte';

  let tasks = [];
  let isLoading = false;
  let error = '';
  let success = '';

  // Form state
  let newTaskTitle = '';
  let newTaskDescription = '';
  let newTaskPriority = 'medium';
  let newTaskAssignedTo = '';
  let newTaskDueDate = '';
  let showNewTaskForm = false;

  // Edit state
  let editingTask = null;
  let editTitle = '';
  let editDescription = '';
  let editPriority = 'medium';
  let editAssignedTo = '';
  let editDueDate = '';

  onMount(() => {
    loadTasks();
  });

  async function loadTasks() {
    isLoading = true;
    error = '';

    try {
      const result = await api.jobs.getJobs();

      if (result.success) {
        tasks = result.data || [];
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

  async function addTask() {
    if (!newTaskTitle.trim()) {
      error = 'Título é obrigatório';
      return;
    }

    isLoading = true;
    error = '';

    try {
      const taskData = {
        title: newTaskTitle.trim(),
        description: newTaskDescription.trim() || undefined,
        priority: newTaskPriority,
        assigned_to: newTaskAssignedTo ? parseInt(newTaskAssignedTo) : undefined,
        deadline: newTaskDueDate || undefined,
        status: 'pending' // Default status
      };

      const result = await api.jobs.createJob(taskData);

      if (result.success) {
        await loadTasks(); // Reload tasks
        success = 'Tarefa criada com sucesso';
        resetNewTaskForm();
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao criar tarefa';
      }
    } catch (err) {
      console.error('Error creating task:', err);
      error = 'Erro ao criar tarefa';
    } finally {
      isLoading = false;
    }
  }

  async function updateTaskStatus(taskId, newStatus) {
    isLoading = true;
    error = '';

    try {
      const result = await api.jobs.updateJob(taskId, { status: newStatus });

      if (result.success) {
        await loadTasks(); // Reload tasks
        success = 'Status atualizado com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao atualizar status';
      }
    } catch (err) {
      console.error('Error updating task status:', err);
      error = 'Erro ao atualizar status';
    } finally {
      isLoading = false;
    }
  }

  async function saveEditTask() {
    if (!editTitle.trim()) {
      error = 'Título é obrigatório';
      return;
    }

    isLoading = true;
    error = '';

    try {
      const taskData = {
        title: editTitle.trim(),
        description: editDescription.trim() || undefined,
        priority: editPriority,
        assigned_to: editAssignedTo ? parseInt(editAssignedTo) : undefined,
        deadline: editDueDate || undefined
      };

      const result = await api.jobs.updateJob(editingTask.id, taskData);

      if (result.success) {
        await loadTasks(); // Reload tasks
        success = 'Tarefa atualizada com sucesso';
        cancelEdit();
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao atualizar tarefa';
      }
    } catch (err) {
      console.error('Error updating task:', err);
      error = 'Erro ao atualizar tarefa';
    } finally {
      isLoading = false;
    }
  }

  async function deleteTask(taskId) {
    if (!confirm('Tem certeza que deseja excluir esta tarefa?')) {
      return;
    }

    isLoading = true;
    error = '';

    try {
      const result = await api.jobs.deleteJob(taskId);

      if (result.success) {
        await loadTasks(); // Reload tasks
        success = 'Tarefa excluída com sucesso';
        setTimeout(() => (success = ''), 3000);
      } else {
        error = result.message || 'Erro ao excluir tarefa';
      }
    } catch (err) {
      console.error('Error deleting task:', err);
      error = 'Erro ao excluir tarefa';
    } finally {
      isLoading = false;
    }
  }

  function startEdit(task) {
    editingTask = task;
    editTitle = task.title;
    editDescription = task.description || '';
    editPriority = task.priority;
    editAssignedTo = task.assigned_to ? task.assigned_to.toString() : '';
    editDueDate = task.deadline ? task.deadline.split('T')[0] : '';
  }

  function cancelEdit() {
    editingTask = null;
    editTitle = '';
    editDescription = '';
    editPriority = 'medium';
    editAssignedTo = '';
    editDueDate = '';
  }

  function resetNewTaskForm() {
    newTaskTitle = '';
    newTaskDescription = '';
    newTaskPriority = 'medium';
    newTaskAssignedTo = '';
    newTaskDueDate = '';
    showNewTaskForm = false;
  }

  function getStatusBadge(status) {
    switch (status) {
      case 'completed':
        return 'badge-success';
      case 'in_progress':
        return 'badge-warning';
      case 'pending':
        return 'badge-error';
      case 'cancelled':
        return 'badge-neutral';
      default:
        return 'badge-ghost';
    }
  }

  function getPriorityBadge(priority) {
    switch (priority) {
      case 'urgent':
        return 'badge-error';
      case 'high':
        return 'badge-warning';
      case 'medium':
        return 'badge-info';
      case 'low':
        return 'badge-success';
      default:
        return 'badge-ghost';
    }
  }

  function getStatusLabel(status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'in_progress':
        return 'Em Progresso';
      case 'completed':
        return 'Concluída';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  function getPriorityLabel(priority) {
    switch (priority) {
      case 'low':
        return 'Baixa';
      case 'medium':
        return 'Média';
      case 'high':
        return 'Alta';
      case 'urgent':
        return 'Urgente';
      default:
        return priority;
    }
  }
</script>

<AuthSidebar>
  <div class="container mx-auto py-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">📋 Tarefas</h2>
          <button
            class="btn btn-primary"
            on:click={() => (showNewTaskForm = !showNewTaskForm)}
            disabled={isLoading}
          >
            + Nova Tarefa
          </button>
        </div>

        <!-- Messages -->
        {#if error}
          <div class="alert alert-error mb-4">
            <span>{error}</span>
          </div>
        {/if}

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
                  <label class="label">
                    <span class="label-text">Título *</span>
                  </label>
                  <input
                    type="text"
                    class="input input-bordered"
                    bind:value={newTaskTitle}
                    placeholder="Título da tarefa"
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Prioridade</span>
                  </label>
                  <select
                    class="select select-bordered"
                    bind:value={newTaskPriority}
                    disabled={isLoading}
                  >
                    <option value="low">Baixa</option>
                    <option value="medium">Média</option>
                    <option value="high">Alta</option>
                    <option value="urgent">Urgente</option>
                  </select>
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Atribuído para (ID do usuário)</span>
                  </label>
                  <input
                    type="number"
                    class="input input-bordered"
                    bind:value={newTaskAssignedTo}
                    placeholder="ID do usuário"
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Data de vencimento</span>
                  </label>
                  <input
                    type="date"
                    class="input input-bordered"
                    bind:value={newTaskDueDate}
                    disabled={isLoading}
                  />
                </div>

                <div class="form-control md:col-span-2">
                  <label class="label">
                    <span class="label-text">Descrição</span>
                  </label>
                  <textarea
                    class="textarea textarea-bordered"
                    bind:value={newTaskDescription}
                    placeholder="Descrição da tarefa"
                    disabled={isLoading}
                  ></textarea>
                </div>
              </div>

              <div class="card-actions justify-end mt-4">
                <button class="btn btn-ghost" on:click={resetNewTaskForm} disabled={isLoading}>
                  Cancelar
                </button>
                <button
                  class="btn btn-primary"
                  class:loading={isLoading}
                  on:click={addTask}
                  disabled={isLoading}
                >
                  Criar Tarefa
                </button>
              </div>
            </div>
          </div>
        {/if}

        <!-- Loading -->
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
                  <th>ID</th>
                  <th>Título</th>
                  <th>Status</th>
                  <th>Prioridade</th>
                  <th>Atribuído</th>
                  <th>Vencimento</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {#each tasks as task (task.id)}
                  <tr>
                    <td>{task.id}</td>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <input
                          type="text"
                          class="input input-sm input-bordered"
                          bind:value={editTitle}
                          disabled={isLoading}
                        />
                      {:else}
                        <div>
                          <div class="font-semibold">{task.title}</div>
                          {#if task.description}
                            <div class="text-sm opacity-70">{task.description}</div>
                          {/if}
                        </div>
                      {/if}
                    </td>
                    <td>
                      <select
                        class="select select-sm select-bordered"
                        value={task.status}
                        on:change={(e) => updateTaskStatus(task.id, e.target.value)}
                        disabled={isLoading}
                      >
                        <option value="pending">Pendente</option>
                        <option value="in_progress">Em Progresso</option>
                        <option value="completed">Concluída</option>
                        <option value="cancelled">Cancelada</option>
                      </select>
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
                          <option value="urgent">Urgente</option>
                        </select>
                      {:else}
                        <span class="badge {getPriorityBadge(task.priority)}"
                          >{getPriorityLabel(task.priority)}</span
                        >
                      {/if}
                    </td>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <input
                          type="number"
                          class="input input-sm input-bordered"
                          bind:value={editAssignedTo}
                          placeholder="User ID"
                          disabled={isLoading}
                        />
                      {:else}
                        {task.assigned_to || '-'}
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
                        {task.deadline ? new Date(task.deadline).toLocaleDateString('pt-BR') : '-'}
                      {/if}
                    </td>
                    <td>
                      {#if editingTask && editingTask.id === task.id}
                        <div class="flex gap-2">
                          <button
                            class="btn btn-sm btn-success"
                            on:click={saveEditTask}
                            disabled={isLoading}
                          >
                            Salvar
                          </button>
                          <button
                            class="btn btn-sm btn-ghost"
                            on:click={cancelEdit}
                            disabled={isLoading}
                          >
                            Cancelar
                          </button>
                        </div>
                      {:else}
                        <div class="flex gap-2">
                          <button
                            class="btn btn-sm btn-ghost"
                            on:click={() => startEdit(task)}
                            disabled={isLoading}
                          >
                            ✏️
                          </button>
                          <button
                            class="btn btn-sm btn-error"
                            on:click={() => deleteTask(task.id)}
                            disabled={isLoading}
                          >
                            🗑️
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

        <!-- Refresh Button -->
        <div class="card-actions justify-end mt-6">
          <button
            class="btn btn-outline"
            class:loading={isLoading}
            on:click={loadTasks}
            disabled={isLoading}
          >
            🔄 Atualizar
          </button>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
