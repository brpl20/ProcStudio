<script>
  import UserProfile from './UserProfile.svelte';
  import ApiTester from './ApiTester.svelte';
  
  export let user = null;
</script>

<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title text-2xl">Bem-vindo!</h2>
    <p class="text-base-content">Você está logado com sucesso.</p>
    
    <UserProfile {user} />
    
    <ApiTester />
  </div>
</div>