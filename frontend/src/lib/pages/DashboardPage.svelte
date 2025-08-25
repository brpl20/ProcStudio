<script>
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import Breadcrumbs from '../components/Breadcrumbs.svelte';
  import UserProfile from '../UserProfile.svelte';
  // import ApiTester from '../ApiTester.svelte';
  import { authStore } from '../stores/authStore.js';

  $: ({ user } = $authStore);
</script>

<AuthSidebar activeSection="dashboard">
  <Breadcrumbs />

  <div class="">
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Conteúdo Principal -->
      <div class="lg:col-span-2">
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h2 class="card-title text-2xl">Dashboard</h2>
            <p class="text-base-content">Bem-vindo ao ProcStudio!</p>
            <p class="text-base-content">Dashboard: Todo</p>

            <!-- Stats do usuário -->
            <UserProfile {user} />

            <!-- Cards de ações rápidas -->
          </div>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
