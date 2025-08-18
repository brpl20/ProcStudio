<script>
  import Register from './lib/Register.svelte';
  import Login from './lib/Login.svelte';
  import ProfileCompletion from './lib/ProfileCompletion.svelte';
  import Teams from './lib/Teams.svelte';
  import { api } from './lib/api';

  let isAuthenticated = false;
  let user = null;
  let currentView = 'login'; // 'login' ou 'register'
  let currentPage = 'home'; // 'home' ou 'teams'
  let showProfileCompletion = false;
  let profileData = null;
  let missingFields = [];

  // Verifica se já está logado ao carregar a página
  function checkAuth() {
    isAuthenticated = api.isAuthenticated();
  }

  function handleLoginSuccess(userData) {
    isAuthenticated = true;
    user = userData;
    // Verifica se precisa completar o perfil
    // Desabilitado por enquanto TD: Reabilitar no futuro quando
    // Trabalhar com a rota de registro/login
    // if (userData.needs_profile_completion) {
    //     showProfileCompletion = true;
    //     profileData = userData;
    //     missingFields = userData.missing_fields || [];
    // }
  }

  function handleProfileCompletion(completionResult) {
    showProfileCompletion = false;
    profileData = null;
    missingFields = [];
    // Pode atualizar dados do usuário se necessário
    if (completionResult.user) {
      user = { ...user, ...completionResult.user };
    }
  }

  function handleProfileCompletionClose() {
    // Se fechar sem completar, faz logout
    handleLogout();
  }

  function handleLogout() {
    api.logout();
    isAuthenticated = false;
    user = null;
    showProfileCompletion = false;
    profileData = null;
    missingFields = [];
  }

  function switchView() {
    currentView = currentView === 'login' ? 'register' : 'login';
  }

  // Funções de navegação
  function navigateToTeams() {
    currentPage = 'teams';
  }

  function navigateToHome() {
    currentPage = 'home';
  }

  // Estados para renderização de dados
  let connectionTestResult = null;
  let adminsListResult = null;
  let isTestingConnection = false;
  let isTestingAdmins = false;

  // Função para testar conexão com API
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
        error: error.message,
        message: 'Erro ao conectar com API'
      };
    } finally {
      isTestingConnection = false;
    }
  }

  // Função para testar endpoint de listar admins
  async function testListAdmins() {
    isTestingAdmins = true;
    adminsListResult = null;

    try {
      const data = await api.getAdmins();
      adminsListResult = {
        success: true,
        data: data,
        count: Array.isArray(data) ? data.length : data.data ? data.data.length : 0,
        message: 'Lista de admins carregada com sucesso!'
      };
    } catch (error) {
      adminsListResult = {
        success: false,
        error: error.message,
        message: 'Erro ao buscar admins'
      };
    } finally {
      isTestingAdmins = false;
    }
  }

  // Verifica autenticação ao carregar
  checkAuth();
</script>

<main>
  <div>
    <h1>ProcStudio</h1>
  </div>
  {#if isAuthenticated}
    <!-- Navegação -->
    <nav>
      <button on:click={navigateToHome} disabled={currentPage === 'home'}> 🏠 Home </button>
      <button on:click={navigateToTeams} disabled={currentPage === 'teams'}> 👥 Times </button>
      <button on:click={handleLogout}> 🚪 Sair </button>
    </nav>

    <!-- Conteúdo das páginas -->
    {#if currentPage === 'teams'}
      <Teams />
    {:else}
      <!-- Página Home -->
      <div>
        <h2>Bem-vindo!</h2>
        <p>Você está logado com sucesso.</p>
        {#if user}
          <p>E-mail: {user.email || 'N/A'}</p>
          <p>Tipo: Admin</p>
          {#if user.name}
            <p>Nome: {user.name} {user.last_name || ''}</p>
          {/if}
          {#if user.oab}
            <p>OAB: {user.oab}</p>
          {/if}
        {/if}

        <h3>Testes da API</h3>

        <div>
          <h4>Métodos Gerais</h4>
          <button on:click={testApiConnection} disabled={isTestingConnection}>
            {isTestingConnection ? 'Testando...' : 'Testar Conexão API'}
          </button>
        </div>

        <div>
          <h4>Métodos de Usuários: Admins</h4>
          <button on:click={testListAdmins} disabled={isTestingAdmins}>
            {isTestingAdmins ? 'Carregando...' : 'Listar Admins'}
          </button>
        </div>

        <div>
          <h4>Métodos de Super Admins</h4>
          <p>Em desenvolvimento...</p>
        </div>

        <hr />

        {#if connectionTestResult}
          <div>
            <h4>{connectionTestResult.success ? 'OK' : 'ERRO'} - {connectionTestResult.message}</h4>
            {#if connectionTestResult.success && connectionTestResult.data}
              <pre>{JSON.stringify(connectionTestResult.data, null, 2)}</pre>
            {:else if connectionTestResult.error}
              <p>Erro: {connectionTestResult.error}</p>
            {/if}
          </div>
        {/if}

        {#if adminsListResult}
          <div>
            <h4>{adminsListResult.success ? 'OK' : 'ERRO'} - {adminsListResult.message}</h4>
            {#if adminsListResult.success}
              <p>Total: {adminsListResult.count}</p>

              <h5>DEBUG - Resposta Completa:</h5>
              <pre>{JSON.stringify(adminsListResult.data, null, 2)}</pre>

              {#if adminsListResult.data && (Array.isArray(adminsListResult.data) ? adminsListResult.data : adminsListResult.data.data)}
                <h5>Admins Processados:</h5>
                {#each Array.isArray(adminsListResult.data) ? adminsListResult.data : adminsListResult.data.data || [] as admin}
                  {@const profileId = admin.relationships?.profile_admin?.data?.id}
                  {@const included = Array.isArray(adminsListResult.data)
                    ? null
                    : adminsListResult.data.included}
                  {@const profile = included?.find((p) => p.id === profileId)}
                  <div>
                    <h5>Admin #{admin.id}</h5>
                    <p>Email: {admin.attributes?.access_email || 'N/A'}</p>
                    <p>Status: {admin.attributes?.status || 'N/A'}</p>
                    <p>Deleted (Admin): {String(admin.attributes?.deleted)}</p>
                    <p>Profile ID: {profileId || 'N/A'}</p>

                    {#if profile}
                      <h6>Profile Details:</h6>
                      <p>
                        Nome: {profile.attributes?.name || 'N/A'}
                        {profile.attributes?.last_name || ''}
                      </p>
                      <p>Role: {profile.attributes?.role || 'N/A'}</p>
                      <p>Deleted (Profile): {String(profile.attributes?.deleted)}</p>
                      <p>Phones: {profile.attributes?.phones?.length || 0}</p>
                      <p>Bank Accounts: {profile.attributes?.bank_accounts?.length || 0}</p>
                      <p>Emails: {profile.attributes?.emails?.length || 0}</p>
                    {:else}
                      <p>
                        Profile não encontrado no included. Included length: {included?.length || 0}
                      </p>
                    {/if}
                    <hr />
                  </div>
                {/each}
              {/if}
            {:else if adminsListResult.error}
              <p>Erro: {adminsListResult.error}</p>
            {/if}
          </div>
        {/if}
      </div>
    {/if}
  {:else}
    <div>
      <h2>Autenticação</h2>
      {#if currentView === 'login'}
        <Login onLoginSuccess={handleLoginSuccess} />
        <p>
          Não tem conta?
          <button on:click={switchView}>Registrar-se</button>
        </p>
      {:else}
        <Register />
        <p>
          Já tem conta?
          <button on:click={switchView}>Fazer login</button>
        </p>
      {/if}
      <div>
        <h3>Testes da API</h3>

        <div>
          <button on:click={testApiConnection} disabled={isTestingConnection}>
            {isTestingConnection ? 'Testando...' : 'Testar Conexão API'}
          </button>
          <button on:click={testListAdmins} disabled={isTestingAdmins}>
            {isTestingAdmins ? 'Carregando...' : 'Listar Admins'}
          </button>
        </div>

        {#if connectionTestResult}
          <div>
            <h4>{connectionTestResult.success ? 'OK' : 'ERRO'} - {connectionTestResult.message}</h4>
            {#if connectionTestResult.success && connectionTestResult.data}
              <pre>{JSON.stringify(connectionTestResult.data, null, 2)}</pre>
            {:else if connectionTestResult.error}
              <p>Erro: {connectionTestResult.error}</p>
            {/if}
          </div>
        {/if}

        {#if adminsListResult}
          <div>
            <h4>{adminsListResult.success ? 'OK' : 'ERRO'} - {adminsListResult.message}</h4>
            {#if adminsListResult.success}
              <p>Total: {adminsListResult.count}</p>

              <h5>DEBUG - Resposta Completa:</h5>
              <pre>{JSON.stringify(adminsListResult.data, null, 2)}</pre>

              {#if adminsListResult.data && (Array.isArray(adminsListResult.data) ? adminsListResult.data : adminsListResult.data.data)}
                <h5>Admins Processados:</h5>
                {#each Array.isArray(adminsListResult.data) ? adminsListResult.data : adminsListResult.data.data || [] as admin}
                  {@const profileId = admin.relationships?.profile_admin?.data?.id}
                  {@const included = Array.isArray(adminsListResult.data)
                    ? null
                    : adminsListResult.data.included}
                  {@const profile = included?.find((p) => p.id === profileId)}
                  <div>
                    <h5>Admin #{admin.id}</h5>
                    <p>Email: {admin.attributes?.access_email || 'N/A'}</p>
                    <p>Status: {admin.attributes?.status || 'N/A'}</p>
                    <p>Deleted (Admin): {String(admin.attributes?.deleted)}</p>
                    <p>Profile ID: {profileId || 'N/A'}</p>

                    {#if profile}
                      <h6>Profile Details:</h6>
                      <p>
                        Nome: {profile.attributes?.name || 'N/A'}
                        {profile.attributes?.last_name || ''}
                      </p>
                      <p>Role: {profile.attributes?.role || 'N/A'}</p>
                      <p>Deleted (Profile): {String(profile.attributes?.deleted)}</p>
                      <p>Phones: {profile.attributes?.phones?.length || 0}</p>
                      <p>Bank Accounts: {profile.attributes?.bank_accounts?.length || 0}</p>
                      <p>Emails: {profile.attributes?.emails?.length || 0}</p>
                    {:else}
                      <p>
                        Profile não encontrado no included. Included length: {included?.length || 0}
                      </p>
                    {/if}
                    <hr />
                  </div>
                {/each}
              {/if}
            {:else if adminsListResult.error}
              <p>Erro: {adminsListResult.error}</p>
            {/if}
          </div>
        {/if}
      </div>
    </div>
  {/if}
</main>

<!-- Modal de Completar Perfil -->
{#if showProfileCompletion}
  <ProfileCompletion
    isOpen={showProfileCompletion}
    userData={profileData}
    {missingFields}
    onComplete={handleProfileCompletion}
    onClose={handleProfileCompletionClose}
  />
{/if}

<style>
</style>
