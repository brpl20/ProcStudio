<script>
  import AdminLayout from '../components/AdminLayout.svelte';
</script>

<AdminLayout activeSection="reports">
  <div class="container mx-auto">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title text-3xl mb-6">📊 Relatórios</h2>
        
        <!-- Filtros -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Período</span>
            </label>
            <select class="select select-bordered">
              <option>Últimos 7 dias</option>
              <option>Últimos 30 dias</option>
              <option>Últimos 3 meses</option>
              <option>Último ano</option>
            </select>
          </div>
          
          <div class="form-control">
            <label class="label">
              <span class="label-text">Tipo</span>
            </label>
            <select class="select select-bordered">
              <option>Todos</option>
              <option>Usuários</option>
              <option>Equipes</option>
              <option>Tarefas</option>
            </select>
          </div>
          
          <div class="form-control">
            <label class="label">
              <span class="label-text">Status</span>
            </label>
            <select class="select select-bordered">
              <option>Todos</option>
              <option>Ativo</option>
              <option>Inativo</option>
              <option>Pendente</option>
            </select>
          </div>
          
          <div class="form-control">
            <label class="label">
              <span class="label-text">Ações</span>
            </label>
            <button class="btn btn-primary">Gerar Relatório</button>
          </div>
        </div>
        
        <!-- Cards de estatísticas -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div class="stat bg-primary text-primary-content rounded-lg">
            <div class="stat-figure">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
              </svg>
            </div>
            <div class="stat-title">Total de Usuários</div>
            <div class="stat-value">31K</div>
            <div class="stat-desc">Jan 1st - Fev 1st</div>
          </div>
          
          <div class="stat bg-secondary text-secondary-content rounded-lg">
            <div class="stat-figure">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
            </div>
            <div class="stat-title">Novos Usuários</div>
            <div class="stat-value">4,200</div>
            <div class="stat-desc">↗︎ 400 (22%)</div>
          </div>
          
          <div class="stat bg-accent text-accent-content rounded-lg">
            <div class="stat-figure">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4"></path>
              </svg>
            </div>
            <div class="stat-title">Tarefas Concluídas</div>
            <div class="stat-value">1,200</div>
            <div class="stat-desc">↘︎ 90 (14%)</div>
          </div>
          
          <div class="stat bg-info text-info-content rounded-lg">
            <div class="stat-figure">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4"></path>
              </svg>
            </div>
            <div class="stat-title">Taxa de Sucesso</div>
            <div class="stat-value">86%</div>
            <div class="stat-desc">↗︎ 12% from last month</div>
          </div>
        </div>
        
        <!-- Gráfico placeholder -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div class="card bg-base-200">
            <div class="card-body">
              <h3 class="card-title">📈 Crescimento de Usuários</h3>
              <div class="h-64 bg-base-300 rounded flex items-center justify-center">
                <p class="text-base-content opacity-60">Gráfico de crescimento aqui</p>
              </div>
            </div>
          </div>
          
          <div class="card bg-base-200">
            <div class="card-body">
              <h3 class="card-title">🎯 Performance de Tarefas</h3>
              <div class="h-64 bg-base-300 rounded flex items-center justify-center">
                <p class="text-base-content opacity-60">Gráfico de performance aqui</p>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Tabela de dados -->
        <div class="divider mt-8"></div>
        <h3 class="text-xl font-semibold mb-4">📋 Dados Detalhados</h3>
        
        <div class="overflow-x-auto">
          <table class="table table-zebra w-full">
            <thead>
              <tr>
                <th>ID</th>
                <th>Nome</th>
                <th>Tipo</th>
                <th>Status</th>
                <th>Data</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <th>1</th>
                <td>João Silva</td>
                <td>Usuário</td>
                <td><div class="badge badge-success">Ativo</div></td>
                <td>2025-01-15</td>
                <td><button class="btn btn-ghost btn-xs">Ver</button></td>
              </tr>
              <tr>
                <th>2</th>
                <td>Maria Santos</td>
                <td>Admin</td>
                <td><div class="badge badge-success">Ativo</div></td>
                <td>2025-01-14</td>
                <td><button class="btn btn-ghost btn-xs">Ver</button></td>
              </tr>
              <tr>
                <th>3</th>
                <td>Pedro Costa</td>
                <td>Usuário</td>
                <td><div class="badge badge-warning">Pendente</div></td>
                <td>2025-01-13</td>
                <td><button class="btn btn-ghost btn-xs">Ver</button></td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <!-- Botões de exportação -->
        <div class="card-actions justify-end mt-6">
          <button class="btn btn-outline">📄 Exportar PDF</button>
          <button class="btn btn-outline">📊 Exportar Excel</button>
          <button class="btn btn-primary">📧 Enviar por Email</button>
        </div>
      </div>
    </div>
  </div>
</AdminLayout>