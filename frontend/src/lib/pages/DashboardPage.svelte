<script>
  import AdminLayout from '../components/AdminLayout.svelte';
  import Breadcrumbs from '../components/Breadcrumbs.svelte';
  import UserProfile from '../UserProfile.svelte';
  import ApiTester from '../ApiTester.svelte';
  import { authStore } from '../stores/authStore.js';

  $: ({ user } = $authStore);
</script>

<AdminLayout activeSection="dashboard">
  <Breadcrumbs />

  <div class="">
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Conteúdo Principal -->
      <div class="lg:col-span-2">
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title text-2xl">Dashboard</h2>
            <p class="text-base-content">Bem-vindo ao ProcStudio!</p>

            <!-- Stats do usuário -->
            <UserProfile {user} />

            <!-- Cards de ações rápidas -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
              <div class="card bg-primary text-primary-content">
                <div class="card-body">
                  <h3 class="card-title">📄 Documentos</h3>
                  <p>Gerencie seus documentos</p>
                  <div class="card-actions justify-end">
                    <button class="btn btn-sm">Acessar</button>
                  </div>
                </div>
              </div>

              <div class="card bg-secondary text-secondary-content">
                <div class="card-body">
                  <h3 class="card-title">👥 Equipes</h3>
                  <p>Colabore com sua equipe</p>
                  <div class="card-actions justify-end">
                    <button class="btn btn-sm">Acessar</button>
                  </div>
                </div>
              </div>

              <div class="card bg-accent text-accent-content">
                <div class="card-body">
                  <h3 class="card-title">📊 Relatórios</h3>
                  <p>Visualize seus dados</p>
                  <div class="card-actions justify-end">
                    <button class="btn btn-sm">Acessar</button>
                  </div>
                </div>
              </div>

              <div class="card bg-neutral text-neutral-content">
                <div class="card-body">
                  <h3 class="card-title">⚙️ Configurações</h3>
                  <p>Ajuste suas preferências</p>
                  <div class="card-actions justify-end">
                    <button class="btn btn-sm">Acessar</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="lg:col-span-1">
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h3 class="card-title text-lg">Ferramentas de Desenvolvimento</h3>
            <ApiTester />
          </div>
        </div>
      </div>
    </div>
  </div>
</AdminLayout>
