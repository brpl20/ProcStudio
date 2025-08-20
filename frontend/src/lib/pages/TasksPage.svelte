<script>
  import AdminLayout from '../components/AdminLayout.svelte';
  
  let tasks = [
    { id: 1, title: 'Implementar autenticação', status: 'completed', priority: 'high', assignee: 'João Silva', dueDate: '2025-01-20' },
    { id: 2, title: 'Criar dashboard', status: 'in_progress', priority: 'medium', assignee: 'Maria Santos', dueDate: '2025-01-25' },
    { id: 3, title: 'Otimizar performance', status: 'pending', priority: 'low', assignee: 'Pedro Costa', dueDate: '2025-01-30' },
    { id: 4, title: 'Testes unitários', status: 'pending', priority: 'high', assignee: 'Ana Silva', dueDate: '2025-02-01' }
  ];
  
  let newTaskTitle = '';
  let newTaskPriority = 'medium';
  let newTaskAssignee = '';
  let showNewTaskForm = false;
  
  function addTask() {
    if (newTaskTitle.trim()) {
      const newTask = {
        id: tasks.length + 1,
        title: newTaskTitle,
        status: 'pending',
        priority: newTaskPriority,
        assignee: newTaskAssignee,
        dueDate: new Date().toISOString().split('T')[0]
      };
      tasks = [...tasks, newTask];
      newTaskTitle = '';
      newTaskAssignee = '';
      showNewTaskForm = false;
    }
  }
  
  function updateTaskStatus(taskId, newStatus) {
    tasks = tasks.map(task => 
      task.id === taskId ? { ...task, status: newStatus } : task
    );
  }
  
  function deleteTask(taskId) {
    tasks = tasks.filter(task => task.id !== taskId);
  }
  
  function getStatusBadge(status) {
    switch (status) {
      case 'completed':
        return 'badge-success';
      case 'in_progress':
        return 'badge-warning';
      case 'pending':
        return 'badge-error';
      default:
        return 'badge-ghost';
    }
  }
  
  function getStatusText(status) {
    switch (status) {
      case 'completed':
        return 'Concluída';
      case 'in_progress':
        return 'Em Progresso';
      case 'pending':
        return 'Pendente';
      default:
        return status;
    }
  }
  
  function getPriorityBadge(priority) {
    switch (priority) {
      case 'high':
        return 'badge-error';
      case 'medium':
        return 'badge-warning';
      case 'low':
        return 'badge-info';
      default:
        return 'badge-ghost';
    }
  }
  
  function getPriorityText(priority) {
    switch (priority) {
      case 'high':
        return 'Alta';
      case 'medium':
        return 'Média';
      case 'low':
        return 'Baixa';
      default:
        return priority;
    }
  }
</script>

<AdminLayout activeSection="tasks">
  <div class="container mx-auto">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-6">
          <h2 class="card-title text-3xl">✅ Tarefas</h2>
          <button 
            class="btn btn-primary" 
            on:click={() => showNewTaskForm = !showNewTaskForm}
          >
            ➕ Nova Tarefa
          </button>
        </div>
        
        <!-- Formulário para nova tarefa -->
        {#if showNewTaskForm}
          <div class="card bg-base-200 mb-6">
            <div class="card-body">
              <h3 class="card-title">Criar Nova Tarefa</h3>
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Título</span>
                  </label>
                  <input 
                    type="text" 
                    placeholder="Digite o título da tarefa" 
                    class="input input-bordered" 
                    bind:value={newTaskTitle}
                  />
                </div>
                
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Prioridade</span>
                  </label>
                  <select class="select select-bordered" bind:value={newTaskPriority}>
                    <option value="low">Baixa</option>
                    <option value="medium">Média</option>
                    <option value="high">Alta</option>
                  </select>
                </div>
                
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Responsável</span>
                  </label>
                  <input 
                    type="text" 
                    placeholder="Nome do responsável" 
                    class="input input-bordered" 
                    bind:value={newTaskAssignee}
                  />
                </div>
              </div>
              
              <div class="card-actions justify-end mt-4">
                <button class="btn btn-outline" on:click={() => showNewTaskForm = false}>
                  Cancelar
                </button>
                <button class="btn btn-primary" on:click={addTask}>
                  Criar Tarefa
                </button>
              </div>
            </div>
          </div>
        {/if}
        
        <!-- Estatísticas -->
        <div class="stats shadow mb-6">
          <div class="stat">
            <div class="stat-figure text-primary">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
              </svg>
            </div>
            <div class="stat-title">Total</div>
            <div class="stat-value text-primary">{tasks.length}</div>
            <div class="stat-desc">Tarefas cadastradas</div>
          </div>
          
          <div class="stat">
            <div class="stat-figure text-secondary">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
            </div>
            <div class="stat-title">Concluídas</div>
            <div class="stat-value text-secondary">{tasks.filter(t => t.status === 'completed').length}</div>
            <div class="stat-desc">Tarefas finalizadas</div>
          </div>
          
          <div class="stat">
            <div class="stat-figure text-info">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4"></path>
              </svg>
            </div>
            <div class="stat-title">Em Progresso</div>
            <div class="stat-value text-info">{tasks.filter(t => t.status === 'in_progress').length}</div>
            <div class="stat-desc">Tarefas ativas</div>
          </div>
        </div>
        
        <!-- Lista de tarefas -->
        <div class="overflow-x-auto">
          <table class="table table-zebra w-full">
            <thead>
              <tr>
                <th>ID</th>
                <th>Tarefa</th>
                <th>Status</th>
                <th>Prioridade</th>
                <th>Responsável</th>
                <th>Data Limite</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              {#each tasks as task}
                <tr>
                  <th>{task.id}</th>
                  <td class="font-medium">{task.title}</td>
                  <td>
                    <div class="badge {getStatusBadge(task.status)}">
                      {getStatusText(task.status)}
                    </div>
                  </td>
                  <td>
                    <div class="badge {getPriorityBadge(task.priority)}">
                      {getPriorityText(task.priority)}
                    </div>
                  </td>
                  <td>{task.assignee}</td>
                  <td>{task.dueDate}</td>
                  <td>
                    <div class="flex gap-2">
                      {#if task.status === 'pending'}
                        <button 
                          class="btn btn-xs btn-primary"
                          on:click={() => updateTaskStatus(task.id, 'in_progress')}
                        >
                          Iniciar
                        </button>
                      {:else if task.status === 'in_progress'}
                        <button 
                          class="btn btn-xs btn-success"
                          on:click={() => updateTaskStatus(task.id, 'completed')}
                        >
                          Concluir
                        </button>
                      {/if}
                      <button 
                        class="btn btn-xs btn-error"
                        on:click={() => deleteTask(task.id)}
                      >
                        Excluir
                      </button>
                    </div>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
        
        {#if tasks.length === 0}
          <div class="text-center py-8">
            <p class="text-base-content opacity-60">Nenhuma tarefa cadastrada ainda.</p>
            <button 
              class="btn btn-primary mt-4" 
              on:click={() => showNewTaskForm = true}
            >
              Criar sua primeira tarefa
            </button>
          </div>
        {/if}
      </div>
    </div>
  </div>
</AdminLayout>