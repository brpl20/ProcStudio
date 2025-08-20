<script>
  import api from './api';
  
  let connectionTestResult = null;
  let usersListResult = null;
  let isTestingConnection = false;
  let isTestingUsers = false;

  async function testApiConnection() {
    isTestingConnection = true;
    connectionTestResult = null;

    try {
      const data = await api.testConnection();
      connectionTestResult = {
        success: true,
        data: data,
        message: 'API está funcionando!'
      };
    } catch (error) {
      connectionTestResult = {
        success: false,
        error: error?.message || error?.data?.message || 'Erro desconhecido',
        message: 'Erro ao conectar com API'
      };
    } finally {
      isTestingConnection = false;
    }
  }

  async function testListUsers() {
    isTestingUsers = true;
    usersListResult = null;

    try {
      const data = await api.users.getUsers();
      usersListResult = {
        success: true,
        data: data,
        count: data.data ? data.data.length : 0,
        message: 'Lista de usuários carregada com sucesso!'
      };
    } catch (error) {
      usersListResult = {
        success: false,
        error: error?.message || error?.data?.message || 'Erro desconhecido',
        message: 'Erro ao buscar usuários'
      };
    } finally {
      isTestingUsers = false;
    }
  }
</script>

<div>
  <h3 class="text-xl font-semibold mt-6 mb-4">Testes da API</h3>

  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
    <div class="card bg-base-200">
      <div class="card-body">
        <h4 class="card-title text-lg">Métodos Gerais</h4>
        <div class="card-actions justify-end">
          <button 
            class="btn btn-secondary" 
            class:loading={isTestingConnection} 
            on:click={testApiConnection} 
            disabled={isTestingConnection}
          >
            {isTestingConnection ? 'Testando...' : 'Testar Conexão API'}
          </button>
        </div>
      </div>
    </div>

    <div class="card bg-base-200">
      <div class="card-body">
        <h4 class="card-title text-lg">Métodos de Usuários</h4>
        <div class="card-actions justify-end">
          <button 
            class="btn btn-accent" 
            class:loading={isTestingUsers} 
            on:click={testListUsers} 
            disabled={isTestingUsers}
          >
            {isTestingUsers ? 'Carregando...' : 'Listar Usuários'}
          </button>
        </div>
      </div>
    </div>

    <div class="card bg-base-200">
      <div class="card-body">
        <h4 class="card-title text-lg">Law Areas e Powers</h4>
        <p class="text-sm opacity-70">Em desenvolvimento...</p>
      </div>
    </div>
  </div>

  <div class="divider"></div>

  {#if connectionTestResult}
    <div class="alert mb-4" class:alert-success={connectionTestResult.success} class:alert-error={!connectionTestResult.success}>
      <h4 class="text-lg font-semibold">{connectionTestResult.success ? '✅ OK' : '❌ ERRO'} - {connectionTestResult.message}</h4>
      {#if connectionTestResult.success && connectionTestResult.data}
        <div class="mockup-code mt-4">
          <pre><code>{JSON.stringify(connectionTestResult.data, null, 2)}</code></pre>
        </div>
      {:else if connectionTestResult.error}
        <p class="mt-2">Erro: {connectionTestResult.error}</p>
      {/if}
    </div>
  {/if}

  {#if usersListResult}
    <div class="alert mb-4" class:alert-success={usersListResult.success} class:alert-error={!usersListResult.success}>
      <h4 class="text-lg font-semibold">{usersListResult.success ? '✅ OK' : '❌ ERRO'} - {usersListResult.message}</h4>
      {#if usersListResult.success}
        <p class="mt-2">Total: {usersListResult.count}</p>
        <div class="collapse collapse-arrow bg-base-100 mt-4">
          <input type="checkbox" />
          <div class="collapse-title text-md font-medium">
            Ver detalhes dos usuários
          </div>
          <div class="collapse-content">
            {#if usersListResult.data && usersListResult.data.data}
              {#each usersListResult.data.data as user}
                {@const profileId = user.relationships?.user_profile?.data?.id}
                {@const included = usersListResult.data.included}
                {@const profile = included?.find((p) => p.id === profileId)}
                <div class="card bg-base-200 mb-2">
                  <div class="card-body compact">
                    <h5 class="card-title text-sm">Usuário #{user.id}</h5>
                    <p class="text-xs">Email: {user.attributes?.access_email || 'N/A'}</p>
                    <p class="text-xs">Status: {user.attributes?.status || 'N/A'}</p>
                    {#if profile}
                      <p class="text-xs">Nome: {profile.attributes?.name || 'N/A'} {profile.attributes?.last_name || ''}</p>
                      <p class="text-xs">Role: {profile.attributes?.role || 'N/A'}</p>
                    {/if}
                  </div>
                </div>
              {/each}
            {/if}
          </div>
        </div>
      {:else if usersListResult.error}
        <p class="mt-2">Erro: {usersListResult.error}</p>
      {/if}
    </div>
  {/if}
</div>