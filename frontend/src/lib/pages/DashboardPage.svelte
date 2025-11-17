<script>
  import AuthSidebar from '../components/AuthSidebar.svelte';
  import UserProfile from '../UserProfile.svelte';
  import { authStore } from '../stores/authStore';

  let { user } = $derived($authStore);

  const stats = {
    clientesAtivos: 124,
    trabalhosEmAndamento: 32,
    documentosPendentes: 15,
    jobsConcluidosMes: 58
  };

  const trabalhosPorMes = {
    labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
    data: [45, 52, 68, 72, 65, 80]
  };

  const trabalhosRecentes = [
    { id: 'JOB-0532', cliente: 'Tech Solutions Inc.', status: 'Em Andamento', time: 'Equipe Alpha' },
    { id: 'JOB-0531', cliente: 'Marketing Criativo', status: 'Concluído', time: 'Equipe Beta' },
    { id: 'JOB-0530', cliente: 'Inovações Globais', status: 'Aguardando Aprovação', time: 'Equipe Alpha' },
    { id: 'JOB-0529', cliente: 'Data Analytics Co.', status: 'Concluído', time: 'Equipe Gamma' }
  ];

  function getStatusColor(status) {
    const map = {
      'Concluído': 'bg-green-100 text-green-900',
      'Em Andamento': 'bg-blue-100 text-blue-900',
      'Aguardando Aprovação': 'bg-amber-100 text-amber-900'
    };
    return map[status] || 'bg-gray-100 text-gray-900';
  }

  function getStatIcon(type) {
    const icons = {
      clients: 'M12 4.354a4 4 0 110 8.048M7 14H5a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2h-2m-1-7a4 4 0 11-8 0 4 4 0 018 0z',
      work: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01',
      docs: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
      completed: 'M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z'
    };
    return icons[type];
  }
</script>

<AuthSidebar activeSection="dashboard">
  <div class="w-full px-4 sm:px-6 lg:px-8 py-8 space-y-8">
    <div>
      <h1 class="text-3xl sm:text-4xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent mb-2">
        Dashboard Principal
      </h1>
      <p class="text-gray-600 text-sm sm:text-base">
        Bem-vindo de volta, <span class="font-semibold text-[#01013D]">{user?.name || 'Usuário'}</span>! Aqui está um resumo da sua atividade.
      </p>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
      <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] p-6 sm:p-8 hover:shadow-xl transition-shadow duration-300">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 rounded-full bg-gradient-to-br from-[#0277EE]/20 to-[#0277EE]/5 flex items-center justify-center">
            <svg class="w-6 h-6 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getStatIcon('clients')} />
            </svg>
          </div>
          <span class="text-xs font-bold text-green-600 bg-green-100 px-2.5 py-1 rounded-full">+5%</span>
        </div>
        <p class="text-gray-600 text-sm font-medium mb-1">Clientes Ativos</p>
        <h3 class="text-4xl font-bold text-[#01013D] mb-2">{stats.clientesAtivos}</h3>
        <p class="text-xs text-gray-500">vs. mês passado</p>
      </div>

      <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] p-6 sm:p-8 hover:shadow-xl transition-shadow duration-300">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 rounded-full bg-gradient-to-br from-[#0277EE]/20 to-[#0277EE]/5 flex items-center justify-center">
            <svg class="w-6 h-6 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getStatIcon('work')} />
            </svg>
          </div>
          <span class="text-xs font-bold text-amber-600 bg-amber-100 px-2.5 py-1 rounded-full">3 urgentes</span>
        </div>
        <p class="text-gray-600 text-sm font-medium mb-1">Trabalhos em Andamento</p>
        <h3 class="text-4xl font-bold text-[#01013D] mb-2">{stats.trabalhosEmAndamento}</h3>
        <p class="text-xs text-gray-500">com prazo próximo</p>
      </div>

      <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] p-6 sm:p-8 hover:shadow-xl transition-shadow duration-300">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 rounded-full bg-gradient-to-br from-[#0277EE]/20 to-[#0277EE]/5 flex items-center justify-center">
            <svg class="w-6 h-6 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getStatIcon('docs')} />
            </svg>
          </div>
          <span class="text-xs font-bold text-red-600 bg-red-100 px-2.5 py-1 rounded-full">2 atrasados</span>
        </div>
        <p class="text-gray-600 text-sm font-medium mb-1">Documentos Pendentes</p>
        <h3 class="text-4xl font-bold text-[#01013D] mb-2">{stats.documentosPendentes}</h3>
        <p class="text-xs text-gray-500">aguardando ação</p>
      </div>

      <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] p-6 sm:p-8 hover:shadow-xl transition-shadow duration-300">
        <div class="flex items-center justify-between mb-4">
          <div class="w-12 h-12 rounded-full bg-gradient-to-br from-green-500/20 to-green-500/5 flex items-center justify-center">
            <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={getStatIcon('completed')} />
            </svg>
          </div>
          <span class="text-xs font-bold text-blue-600 bg-blue-100 px-2.5 py-1 rounded-full">83%</span>
        </div>
        <p class="text-gray-600 text-sm font-medium mb-1">Jobs Concluídos (Mês)</p>
        <h3 class="text-4xl font-bold text-[#01013D] mb-2">{stats.jobsConcluidosMes}</h3>
        <p class="text-xs text-gray-500">meta: 70</p>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] overflow-hidden">
          <div class="p-6 sm:p-8">
            <h3 class="text-xl sm:text-2xl font-bold text-[#01013D] mb-2">Relatório de Jobs por Mês</h3>
            <p class="text-gray-600 text-sm mb-6">
              Visualização mensal de jobs concluídos. Você pode integrar bibliotecas como 
              <a href="https://apexcharts.com/" target="_blank" class="text-[#0277EE] hover:underline font-semibold">ApexCharts</a> 
              ou 
              <a href="https://www.chartjs.org/" target="_blank" class="text-[#0277EE] hover:underline font-semibold">Chart.js</a> 
              para renderizar os dados.
            </p>
            <div class="bg-gradient-to-br from-[#eef0ef]/30 to-[#0277EE]/5 h-72 rounded-xl flex items-center justify-center border border-[#eef0ef]">
              <div class="text-center">
                <svg class="w-12 h-12 text-[#0277EE]/30 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
                <p class="text-gray-400 font-medium">Área do Gráfico</p>
                <p class="text-gray-300 text-sm mt-1">Integre seu gráfico aqui</p>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] overflow-hidden">
          <div class="p-6 sm:p-8">
            <h3 class="text-xl sm:text-2xl font-bold text-[#01013D] mb-6">Trabalhos Recentes</h3>
            <div class="overflow-x-auto">
              <table class="w-full">
                <thead class="bg-gradient-to-r from-[#01013D]/5 to-[#0277EE]/5 border-b border-[#eef0ef]">
                  <tr>
                    <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">ID do Job</th>
                    <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">Cliente</th>
                    <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">Status</th>
                    <th class="px-6 py-4 text-left text-sm font-bold text-[#01013D]">Time</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-[#eef0ef]">
                  {#each trabalhosRecentes as job}
                    <tr class="hover:bg-gradient-to-r hover:from-[#eef0ef]/30 hover:to-[#0277EE]/5 transition-colors duration-200">
                      <td class="px-6 py-4">
                        <p class="font-mono font-bold text-[#0277EE]">{job.id}</p>
                      </td>
                      <td class="px-6 py-4">
                        <p class="text-gray-900 font-medium">{job.cliente}</p>
                      </td>
                      <td class="px-6 py-4">
                        <span class="px-3 py-1 rounded-full text-xs font-semibold {getStatusColor(job.status)}">
                          {job.status}
                        </span>
                      </td>
                      <td class="px-6 py-4">
                        <p class="text-gray-600 text-sm">{job.time}</p>
                      </td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <div class="space-y-6">
        <UserProfile {user} />

        <div class="bg-white rounded-2xl shadow-lg border border-[#eef0ef] overflow-hidden">
          <div class="p-6 sm:p-8">
            <h3 class="text-lg sm:text-xl font-bold text-[#01013D] mb-6">Filtros</h3>

            <div class="space-y-5">
              <div>
                <label class="block text-sm font-semibold text-[#01013D] mb-2" for="filtro-time">
                  Time que Pertence
                </label>
                <select 
                  id="filtro-time" 
                  class="w-full px-4 py-2.5 rounded-xl border border-[#eef0ef] bg-white text-[#01013D] font-medium focus:border-[#0277EE] focus:ring-2 focus:ring-[#0277EE]/20 focus:outline-none transition-all duration-300"
                >
                  <option selected>Todos os times</option>
                  <option>Equipe Alpha</option>
                  <option>Equipe Beta</option>
                  <option>Equipe Gamma</option>
                </select>
              </div>

              <div>
                <label class="block text-sm font-semibold text-[#01013D] mb-2" for="filtro-office">
                  Escritório
                </label>
                <select 
                  id="filtro-office" 
                  class="w-full px-4 py-2.5 rounded-xl border border-[#eef0ef] bg-white text-[#01013D] font-medium focus:border-[#0277EE] focus:ring-2 focus:ring-[#0277EE]/20 focus:outline-none transition-all duration-300"
                >
                  <option selected>Todos os escritórios</option>
                  <option>São Paulo</option>
                  <option>Rio de Janeiro</option>
                </select>
              </div>

              <button class="w-full px-4 py-2.5 rounded-xl font-semibold bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white hover:shadow-lg hover:shadow-[#0277EE]/30 transition-all duration-300 mt-6">
                Aplicar Filtros
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</AuthSidebar>
