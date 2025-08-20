<script>
  import AdminLayout from '../components/AdminLayout.svelte';
</script>

<AdminLayout activeSection="admin">
  <div class="container mx-auto">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title text-3xl mb-6">⚙️ Administração</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <!-- Usuários -->
          <div class="card bg-primary text-primary-content">
            <div class="card-body">
              <h3 class="card-title">👥 Usuários</h3>
              <p>Gerenciar usuários do sistema</p>
              <div class="card-actions justify-end">
                <button class="btn btn-sm">Gerenciar</button>
              </div>
            </div>
          </div>
          
          <!-- Permissões -->
          <div class="card bg-secondary text-secondary-content">
            <div class="card-body">
              <h3 class="card-title">🔐 Permissões</h3>
              <p>Controle de acesso e permissões</p>
              <div class="card-actions justify-end">
                <button class="btn btn-sm">Configurar</button>
              </div>
            </div>
          </div>
          
          <!-- Sistema -->
          <div class="card bg-accent text-accent-content">
            <div class="card-body">
              <h3 class="card-title">🔧 Sistema</h3>
              <p>Configurações do sistema</p>
              <div class="card-actions justify-end">
                <button class="btn btn-sm">Acessar</button>
              </div>
            </div>
          </div>
          
          <!-- Logs -->
          <div class="card bg-info text-info-content">
            <div class="card-body">
              <h3 class="card-title">📋 Logs</h3>
              <p>Visualizar logs do sistema</p>
              <div class="card-actions justify-end">
                <button class="btn btn-sm">Ver Logs</button>
              </div>
            </div>
          </div>
          
          <!-- Backup -->
          <div class="card bg-warning text-warning-content">
            <div class="card-body">
              <h3 class="card-title">💾 Backup</h3>
              <p>Backup e restauração</p>
              <div class="card-actions justify-end">
                <button class="btn btn-sm">Backup</button>
              </div>
            </div>
          </div>
          
          <!-- Manutenção -->
          <div class="card bg-error text-error-content">
            <div class="card-body">
              <h3 class="card-title">🔨 Manutenção</h3>
              <p>Ferramentas de manutenção</p>
              <div class="card-actions justify-end">
                <button class="btn btn-sm">Acessar</button>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Stats do sistema -->
        <div class="divider mt-8"></div>
        <div class="stats shadow">
          <div class="stat">
            <div class="stat-figure text-primary">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"></path>
              </svg>
            </div>
            <div class="stat-title">Total de Usuários</div>
            <div class="stat-value text-primary">25</div>
            <div class="stat-desc">21% mais que o mês passado</div>
          </div>
          
          <div class="stat">
            <div class="stat-figure text-secondary">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="inline-block w-8 h-8 stroke-current">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
            </div>
            <div class="stat-title">Uptime</div>
            <div class="stat-value text-secondary">99.9%</div>
            <div class="stat-desc">Sistema estável</div>
          </div>
          
          <div class="stat">
            <div class="stat-figure text-primary">
              <div class="avatar online">
                <div class="w-16 rounded-full">
                  <div class="bg-primary w-16 h-16 rounded-full flex items-center justify-center text-primary-content font-bold text-xl">
                    A
                  </div>
                </div>
              </div>
            </div>
            <div class="stat-value">86%</div>
            <div class="stat-title">Uso do Sistema</div>
            <div class="stat-desc text-secondary">31 tarefas pendentes</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</AdminLayout>