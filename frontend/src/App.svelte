<script lang="ts">
  import Register from './lib/Register.svelte';
  import Login from './lib/Login.svelte';
  import ProfileCompletion from './lib/ProfileCompletion.svelte';
  import Teams from './lib/Teams.svelte';
  import api from './lib/api';
  import type { LoginResponse, RegisterResponse, UsersListResponse } from './lib/api';

  let isAuthenticated = false;
  let user: LoginResponse | null = null;
  let currentView = 'login'; // 'login' ou 'register'
  let currentPage = 'home'; // 'home' ou 'teams'
  let showProfileCompletion = false;
  let profileData: any = null;
  let missingFields: string[] = [];

  // Verifica se já está logado ao carregar a página
  function checkAuth() {
    isAuthenticated = api.auth.isAuthenticated();
  }

  function handleLoginSuccess(userData: LoginResponse) {
    isAuthenticated = true;
    user = userData;
    // Verifica se precisa completar o perfil
    if (userData.data.needs_profile_completion) {
      showProfileCompletion = true;
      profileData = userData.data;
      missingFields = userData.data.missing_fields || [];
    }
  }

  function handleRegisterSuccess(registerData: RegisterResponse) {
    console.log('Registration successful:', registerData);
    // Após registro, volta para login
    currentView = 'login';
  }

  function handleProfileCompletion(completionResult: any) {
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

  async function handleLogout() {
    try {
      await api.auth.logout();
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      isAuthenticated = false;
      user = null;
      showProfileCompletion = false;
      profileData = null;
      missingFields = [];
    }
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
  let connectionTestResult: any = null;
  let usersListResult: any = null;
  let isTestingConnection = false;
  let isTestingUsers = false;

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
    } catch (error: any) {
      console.error('API connection test error:', error);
      connectionTestResult = {
        success: false,
        error: error?.message || error?.data?.message || 'Erro desconhecido',
        message: 'Erro ao conectar com API'
      };
    } finally {
      isTestingConnection = false;
    }
  }

  // Função para testar endpoint de listar usuários (formerly admins)
  async function testListUsers() {
    isTestingUsers = true;
    usersListResult = null;

    try {
      const data: UsersListResponse = await api.users.getUsers();
      usersListResult = {
        success: true,
        data: data,
        count: data.data ? data.data.length : 0,
        message: 'Lista de usuários carregada com sucesso!'
      };
    } catch (error: any) {
      console.error('Users list error:', error);
      usersListResult = {
        success: false,
        error: error?.message || error?.data?.message || 'Erro desconhecido',
        message: 'Erro ao buscar usuários'
      };
    } finally {
      isTestingUsers = false;
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
        {#if user && user.data}
          <p>Tipo: Usuário</p>
          {#if user.data.name}
            <p>Nome: {user.data.name} {user.data.last_name || ''}</p>
          {/if}
          {#if user.data.role}
            <p>Role: {user.data.role}</p>
          {/if}
          {#if user.data.oab}
            <p>OAB: {user.data.oab}</p>
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
          <h4>Métodos de Usuários</h4>
          <button on:click={testListUsers} disabled={isTestingUsers}>
            {isTestingUsers ? 'Carregando...' : 'Listar Usuários'}
          </button>
        </div>

        <div>
          <h4>Métodos de Law Areas e Powers</h4>
          <p>Em desenvolvimento... (disponível na nova API modular)</p>
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

        {#if usersListResult}
          <div>
            <h4>{usersListResult.success ? 'OK' : 'ERRO'} - {usersListResult.message}</h4>
            {#if usersListResult.success}
              <p>Total: {usersListResult.count}</p>

              <h5>DEBUG - Resposta Completa:</h5>
              <pre>{JSON.stringify(usersListResult.data, null, 2)}</pre>

              {#if usersListResult.data && usersListResult.data.data}
                <h5>Usuários Processados:</h5>
                {#each usersListResult.data.data as user}
                  {@const profileId = user.relationships?.user_profile?.data?.id}
                  {@const included = usersListResult.data.included}
                  {@const profile = included?.find((p) => p.id === profileId)}
                  <div>
                    <h5>Usuário #{user.id}</h5>
                    <p>Email: {user.attributes?.access_email || 'N/A'}</p>
                    <p>Status: {user.attributes?.status || 'N/A'}</p>
                    <p>Deleted (User): {String(user.attributes?.deleted)}</p>
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
            {:else if usersListResult.error}
              <p>Erro: {usersListResult.error}</p>
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
        <Register onRegisterSuccess={handleRegisterSuccess} />
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
          <button on:click={testListUsers} disabled={isTestingUsers}>
            {isTestingUsers ? 'Carregando...' : 'Listar Usuários'}
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

        {#if usersListResult}
          <div>
            <h4>{usersListResult.success ? 'OK' : 'ERRO'} - {usersListResult.message}</h4>
            {#if usersListResult.success}
              <p>Total: {usersListResult.count}</p>

              <h5>DEBUG - Resposta Completa:</h5>
              <pre>{JSON.stringify(usersListResult.data, null, 2)}</pre>

              {#if usersListResult.data && usersListResult.data.data}
                <h5>Usuários Processados:</h5>
                {#each usersListResult.data.data as user}
                  {@const profileId = user.relationships?.user_profile?.data?.id}
                  {@const included = usersListResult.data.included}
                  {@const profile = included?.find((p) => p.id === profileId)}
                  <div>
                    <h5>Usuário #{user.id}</h5>
                    <p>Email: {user.attributes?.access_email || 'N/A'}</p>
                    <p>Status: {user.attributes?.status || 'N/A'}</p>
                    <p>Deleted (User): {String(user.attributes?.deleted)}</p>
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
            {:else if usersListResult.error}
              <p>Erro: {usersListResult.error}</p>
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
