<script>
  export let user = null;
</script>

{#if user && user.data}
  <div class="stats shadow mt-4">
    <div class="stat">
      <div class="stat-title">Tipo</div>
      <div class="stat-value text-sm">Usuário</div>
    </div>
    
    {#if user.data.name}
      <div class="stat">
        <div class="stat-title">Nome</div>
        <div class="stat-value text-sm">{user.data.name} {user.data.last_name || ''}</div>
      </div>
    {/if}
    
    {#if user.data.role}
      <div class="stat">
        <div class="stat-title">Role</div>
        <div class="stat-value text-sm">{user.data.role}</div>
      </div>
    {/if}
    
    {#if user.data.oab}
      <div class="stat">
        <div class="stat-title">OAB</div>
        <div class="stat-value text-sm">{user.data.oab}</div>
      </div>
    {/if}
  </div>
{/if}