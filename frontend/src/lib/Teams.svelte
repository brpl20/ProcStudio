<script lang="ts">
  import { api } from './api';

  // Estados para renderização de dados
  let myTeamResult = null;
  let teamByIdResult = null;
  let updateTeamResult = null;
  let teamMembersResult = null;

  // Estados de loading
  let isTestingMyTeam = false;
  let isTestingTeamById = false;
  let isUpdatingTeam = false;
  let isTestingMembers = false;

  // Inputs
  let teamIdInput = '';
  let updateTeamName = '';
  let updateTeamDescription = '';
  let currentTeamId = '';

  // Função para testar meu time
  async function testMyTeam() {
    isTestingMyTeam = true;
    myTeamResult = null;

    try {
      const data = await api.getMyTeam();
      myTeamResult = {
        success: true,
        data: data,
        message: 'Meu time carregado com sucesso!'
      };

      // Guarda o ID do time para usar no update
      if (data?.data?.id) {
        currentTeamId = data.data.id;
        updateTeamName = data.data.attributes?.name || '';
        updateTeamDescription = data.data.attributes?.description || '';
      }
    } catch (error) {
      myTeamResult = {
        success: false,
        error: error.message,
        message: 'Erro ao buscar meu time'
      };
    } finally {
      isTestingMyTeam = false;
    }
  }

  // Função para testar busca de time por ID
  async function testTeamById() {
    if (!teamIdInput.trim()) {
      teamByIdResult = {
        success: false,
        error: 'ID do time é obrigatório',
        message: 'Erro: ID vazio'
      };
      return;
    }

    isTestingTeamById = true;
    teamByIdResult = null;

    try {
      const data = await api.getTeamById(teamIdInput.trim());
      teamByIdResult = {
        success: true,
        data: data,
        message: `Time #${teamIdInput} carregado com sucesso!`
      };
    } catch (error) {
      teamByIdResult = {
        success: false,
        error: error.message,
        message: `Erro ao buscar time #${teamIdInput}`
      };
    } finally {
      isTestingTeamById = false;
    }
  }

  // Função para atualizar time
  async function updateTeam() {
    if (!currentTeamId) {
      updateTeamResult = {
        success: false,
        error: 'Busque seu time primeiro para obter o ID',
        message: 'Erro: ID do time não encontrado'
      };
      return;
    }

    if (!updateTeamName.trim()) {
      updateTeamResult = {
        success: false,
        error: 'Nome do time é obrigatório',
        message: 'Erro: Nome vazio'
      };
      return;
    }

    isUpdatingTeam = true;
    updateTeamResult = null;

    try {
      const data = await api.updateTeam(currentTeamId, {
        name: updateTeamName.trim(),
        description: updateTeamDescription.trim()
      });
      updateTeamResult = {
        success: true,
        data: data,
        message: 'Time atualizado com sucesso!'
      };
    } catch (error) {
      updateTeamResult = {
        success: false,
        error: error.message,
        message: 'Erro ao atualizar time'
      };
    } finally {
      isUpdatingTeam = false;
    }
  }

  // Função para buscar membros do time
  async function testTeamMembers() {
    isTestingMembers = true;
    teamMembersResult = null;

    try {
      const data = await api.getMyTeamMembers();
      teamMembersResult = {
        success: true,
        data: data,
        count: Array.isArray(data) ? data.length : data.data ? data.data.length : 0,
        message: 'Membros do time carregados com sucesso!'
      };
    } catch (error) {
      teamMembersResult = {
        success: false,
        error: error.message,
        message: 'Erro ao buscar membros do time'
      };
    } finally {
      isTestingMembers = false;
    }
  }
</script>

<div>
  <h1>Gerenciamento de Times</h1>

  <div>
    <h3>Operações com Times</h3>

    <!-- Meu Time -->
    <div>
      <h4>Meu Time</h4>
      <button on:click={testMyTeam} disabled={isTestingMyTeam}>
        {isTestingMyTeam ? 'Carregando...' : 'Buscar Meu Time'}
      </button>
    </div>

    <!-- Buscar Time por ID -->
    <div>
      <h4>Buscar Time por ID</h4>
      <input
        type="text"
        bind:value={teamIdInput}
        placeholder="ID do time"
        disabled={isTestingTeamById}
      />
      <button on:click={testTeamById} disabled={isTestingTeamById || !teamIdInput.trim()}>
        {isTestingTeamById ? 'Carregando...' : 'Buscar Time'}
      </button>
    </div>

    <!-- Atualizar Meu Time -->
    <div>
      <h4>Atualizar Meu Time</h4>
      <p>Current Team ID: {currentTeamId || 'Busque seu time primeiro'}</p>
      <div>
        <label>Nome:</label>
        <input
          type="text"
          bind:value={updateTeamName}
          placeholder="Nome do time"
          disabled={isUpdatingTeam}
        />
      </div>
      <div>
        <label>Descrição:</label>
        <textarea
          bind:value={updateTeamDescription}
          placeholder="Descrição do time"
          disabled={isUpdatingTeam}
          rows="3"
        ></textarea>
      </div>
      <button on:click={updateTeam} disabled={isUpdatingTeam || !currentTeamId}>
        {isUpdatingTeam ? 'Atualizando...' : 'Atualizar Time'}
      </button>
    </div>

    <!-- Membros do Time -->
    <div>
      <h4>Membros do Meu Time</h4>
      <button on:click={testTeamMembers} disabled={isTestingMembers}>
        {isTestingMembers ? 'Carregando...' : 'Buscar Membros'}
      </button>
    </div>
  </div>

  <!-- Resultados -->
  <div>
    <h3>Resultados</h3>

    <!-- Resultado do Meu Time -->
    {#if myTeamResult}
      <div>
        <h4>{myTeamResult.success ? 'OK' : 'ERRO'} - {myTeamResult.message}</h4>
        {#if myTeamResult.success && myTeamResult.data}
          <h5>DEBUG - Meu Time:</h5>
          <pre>{JSON.stringify(myTeamResult.data, null, 2)}</pre>

          {#if myTeamResult.data.data}
            <h5>Time Processado:</h5>
            <div>
              <p>ID: {myTeamResult.data.data.id}</p>
              <p>Nome: {myTeamResult.data.data.attributes?.name || 'N/A'}</p>
              <p>Descrição: {myTeamResult.data.data.attributes?.description || 'N/A'}</p>
              <p>Status: {myTeamResult.data.data.attributes?.status || 'N/A'}</p>
              <p>Deleted: {String(myTeamResult.data.data.attributes?.deleted)}</p>
              <p>Criado em: {myTeamResult.data.data.attributes?.created_at || 'N/A'}</p>
            </div>
          {/if}
        {:else if myTeamResult.error}
          <p>Erro: {myTeamResult.error}</p>
        {/if}
        <hr />
      </div>
    {/if}

    <!-- Resultado do Team por ID -->
    {#if teamByIdResult}
      <div>
        <h4>{teamByIdResult.success ? 'OK' : 'ERRO'} - {teamByIdResult.message}</h4>
        {#if teamByIdResult.success && teamByIdResult.data}
          <h5>DEBUG - Team por ID:</h5>
          <pre>{JSON.stringify(teamByIdResult.data, null, 2)}</pre>

          {#if teamByIdResult.data.data}
            <h5>Time Processado:</h5>
            <div>
              <p>ID: {teamByIdResult.data.data.id}</p>
              <p>Nome: {teamByIdResult.data.data.attributes?.name || 'N/A'}</p>
              <p>Descrição: {teamByIdResult.data.data.attributes?.description || 'N/A'}</p>
              <p>Status: {teamByIdResult.data.data.attributes?.status || 'N/A'}</p>
              <p>Deleted: {String(teamByIdResult.data.data.attributes?.deleted)}</p>
              <p>Criado em: {teamByIdResult.data.data.attributes?.created_at || 'N/A'}</p>
            </div>
          {/if}
        {:else if teamByIdResult.error}
          <p>Erro: {teamByIdResult.error}</p>
        {/if}
        <hr />
      </div>
    {/if}

    <!-- Resultado do Update Team -->
    {#if updateTeamResult}
      <div>
        <h4>{updateTeamResult.success ? 'OK' : 'ERRO'} - {updateTeamResult.message}</h4>
        {#if updateTeamResult.success && updateTeamResult.data}
          <h5>DEBUG - Team Atualizado:</h5>
          <pre>{JSON.stringify(updateTeamResult.data, null, 2)}</pre>
        {:else if updateTeamResult.error}
          <p>Erro: {updateTeamResult.error}</p>
        {/if}
        <hr />
      </div>
    {/if}

    <!-- Resultado dos Membros -->
    {#if teamMembersResult}
      <div>
        <h4>{teamMembersResult.success ? 'OK' : 'ERRO'} - {teamMembersResult.message}</h4>
        {#if teamMembersResult.success}
          <p>Total de membros: {teamMembersResult.count}</p>
          <h5>DEBUG - Membros:</h5>
          <pre>{JSON.stringify(teamMembersResult.data, null, 2)}</pre>

          {#if teamMembersResult.data && (Array.isArray(teamMembersResult.data) ? teamMembersResult.data : teamMembersResult.data.data)}
            <h5>Membros Processados:</h5>
            {#each Array.isArray(teamMembersResult.data) ? teamMembersResult.data : teamMembersResult.data.data || [] as member}
              <div>
                <p>ID: {member.id}</p>
                <p>Email: {member.attributes?.access_email || 'N/A'}</p>
                <p>Status: {member.attributes?.status || 'N/A'}</p>
                <p>Role: {member.attributes?.role || 'N/A'}</p>
                <hr />
              </div>
            {/each}
          {/if}
        {:else if teamMembersResult.error}
          <p>Erro: {teamMembersResult.error}</p>
        {/if}
      </div>
    {/if}
  </div>
</div>
