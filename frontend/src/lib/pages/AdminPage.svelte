<script>
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import CepTestForm from '../components/test/CepTestForm.svelte';
</script>

<AuthSidebar activeSection="admin">
  <div class="container mx-auto space-y-6">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title text-3xl mb-6">Super Admin</h2>
        <p>Todo: Quantidade de usuários</p>
        <p>Todo: Novos Usuários</p>
        <p>Todo: Desistentes</p>
        <p>Todo: Faturamento</p>
        <p>Todo: Ias</p>
      </div>
    </div>

    <!-- CEP Test Section -->
    <div class="divider">CEP Validator Test</div>
    <CepTestForm />
  </div>
</AuthSidebar>
