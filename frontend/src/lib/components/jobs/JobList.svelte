<!-- components/jobs/JobList.svelte -->
<script lang="ts">
  import { type Job } from '../../api';
  import { getJobStatusInfo, getJobPriorityInfo } from '../../constants/formOptions';
  import { truncateDescription } from '../../utils/text';
  import Icon from '../../icons/icons.svelte';
  import SearchInput from '../ui/SearchInput.svelte';
  import FilterButton, { type FilterOption } from '../ui/FilterButton.svelte';
  import AvatarGroup from '../ui/AvatarGroup.svelte';
  import { JOBPRIORITY } from '../../constants/formOptions';

  interface Props {
    jobs?: Job[];
    loading?: boolean;
    error?: string | null;
    onRetry?: () => void;
  }

  const usersAvatar = [
    { name: 'Maria', last_name: 'Silva', avatar: 'https://i.pravatar.cc/150?img=5' },
    { name: 'João', last_name: 'Souza', avatar: null },
    { name: 'Carlos', last_name: 'Almeida', avatar: null },
    { name: 'Fernanda', last_name: 'Rocha', avatar: 'https://i.pravatar.cc/150?img=15' },
    { name: 'Leticia', last_name: 'Campos', avatar: 'https://i.pravatar.cc/150?img=6' },
    { name: 'Lucas', last_name: 'Ferreira', avatar: null },
    { name: 'Marcos', last_name: 'Lopes', avatar: null }
  ];

  const { jobs = [], loading = false, error = null, onRetry = () => {} }: Props = $props();

  let searchTerm = $state('');
  let priorityFilter = $state<string>('all');

  let filteredJobs = $state([]);

  const priorityOptions: FilterOption<string>[] = JOBPRIORITY.map((item) => ({
    value: item.value,
    label: item.label,
    badgeClass: item.badgeClass
  }));

  $effect(() => {
    let result = [...jobs];

    if (priorityFilter !== 'all') {
      result = result.filter((job) => job.priority === priorityFilter);
    }

    if (searchTerm && searchTerm.trim()) {
      const term = searchTerm.toLowerCase();
      result = result.filter((job) => {
        return (
          job.title?.toLowerCase().includes(term) ||
          job.description?.toLowerCase().includes(term) ||
          job.latest_comment?.author?.name?.toLowerCase().includes(term) ||
          job.work_number?.toLowerCase().includes(term) ||
          job.status?.toLowerCase().includes(term) ||
          job.priority?.toLowerCase().includes(term) ||
          job.id?.toString().includes(term) ||
          job.assignees_summary?.some(
            (u) => u.name?.toLowerCase().includes(term) || u.last_name?.toLowerCase().includes(term)
          )
        );
      });
    }

    filteredJobs = result;
  });

  function getStatusIcon(status: string): string {
    const icons: Record<string, string> = {
      'pending': 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z',
      'in_progress': 'M13 10V3L4 14h7v7l9-11h-7z',
      'completed': 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
      'cancelled': 'M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2M9 12a9 9 0 11-18 0 9 9 0 0118 0z'
    };
    return icons[status] || icons['pending'];
  }
</script>

<div class="w-full px-4 sm:px-6 lg:px-8 py-8 space-y-6">
  {#if loading}
    <div class="text-center py-16">
      <div class="inline-flex items-center justify-center">
        <div class="relative w-16 h-16">
          <div class="absolute inset-0 rounded-full bg-gradient-to-r from-[#0277EE] to-[#01013D] opacity-10 animate-pulse"></div>
          <div class="absolute inset-2 rounded-full border-4 border-transparent border-t-[#0277EE] border-r-[#0277EE] animate-spin"></div>
        </div>
      </div>
      <p class="mt-6 text-gray-600 font-semibold text-lg">Carregando suas tarefas</p>
      <p class="text-gray-500 text-sm mt-1">Aguarde enquanto processamos os dados...</p>
    </div>
  {:else if error}
    <div class="bg-gradient-to-r from-red-50 to-red-50/50 border border-red-200 rounded-2xl p-6 flex items-start gap-4 animate-in fade-in slide-in-from-top-2 duration-300">
      <div class="flex-shrink-0">
        <div class="flex items-center justify-center h-12 w-12 rounded-xl bg-red-100">
          <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4v2m0 0v2m0-6v-2m0 0V7a2 2 0 012-2h.5a2 2 0 012 2v12a2 2 0 01-2 2h-.5a2 2 0 01-2-2v-2zm0 0V5a2 2 0 012-2h.5a2 2 0 012 2v2m0 0V7"/>
          </svg>
        </div>
      </div>
      <div class="flex-1">
        <h3 class="text-red-900 font-bold text-base mb-1">Erro ao carregar jobs</h3>
        <p class="text-red-800 text-sm mb-4">{error}</p>
        <button 
          on:click={onRetry}
          class="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700 transition-all duration-200 font-semibold text-sm hover:shadow-lg hover:shadow-red-600/30"
        >
          Tentar novamente
        </button>
      </div>
    </div>
  {:else if jobs.length === 0}
    <div class="relative">
      <div class="absolute inset-0 bg-gradient-to-r from-[#0277EE]/5 to-[#01013D]/5 rounded-3xl blur-2xl"></div>
      <div class="relative text-center py-20 px-6">
        <div class="inline-flex items-center justify-center w-20 h-20 rounded-2xl bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 mb-6">
          <svg class="w-10 h-10 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/>
          </svg>
        </div>
        <p class="text-[#01013D] font-bold text-2xl mb-2">Nenhuma tarefa por aqui</p>
        <p class="text-gray-600 text-base max-w-md mx-auto">Suas tarefas aparecerão aqui assim que forem criadas. Comece a organizar seu trabalho agora!</p>
      </div>
    </div>
  {:else}
    <!-- Header com Filtros -->
    <div class="space-y-4">
      <div class="flex flex-col sm:flex-row gap-3">
        <div class="flex-1">
          <SearchInput bind:value={searchTerm} placeholder="Buscar por título, descrição ou responsável..." />
        </div>
        <div class="flex-shrink-0">
          <FilterButton
            bind:value={priorityFilter}
            options={priorityOptions}
            placeholder="Filtros"
            allOptionLabel="Todas"
            onFilterChange={(value) => priorityFilter = value}
          />
        </div>
      </div>

      {#if filteredJobs.length > 0}
        <div class="flex items-center justify-between px-1">
          <p class="text-sm font-semibold text-gray-600">
            <span class="text-[#0277EE] font-bold text-base">{filteredJobs.length}</span>
            <span class="text-gray-500"> tarefa{filteredJobs.length !== 1 ? 's' : ''} encontrada{filteredJobs.length !== 1 ? 's' : ''}</span>
          </p>
        </div>
      {/if}
    </div>

    <!-- Results -->
    {#if filteredJobs.length === 0}
      <div class="bg-gradient-to-r from-blue-50 to-blue-50/50 border border-blue-200 rounded-2xl p-8 text-center">
        <svg class="w-12 h-12 text-[#0277EE] mx-auto mb-4 opacity-60" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
        <p class="text-[#01013D] font-semibold text-lg">Nenhuma tarefa encontrada</p>
        <p class="text-gray-600 text-sm mt-2">Tente ajustar seus filtros ou termos de busca</p>
      </div>
    {:else}
      <!-- Jobs Timeline View -->
      <div class="space-y-3">
        {#each filteredJobs as job, index}
          <div class="group relative">
            <!-- Connection Line -->
            {#if index < filteredJobs.length - 1}
              <div class="absolute left-8 top-16 w-0.5 h-12 bg-gradient-to-b from-[#0277EE]/30 to-transparent"></div>
            {/if}

            <div class="relative flex gap-6">
              <!-- Timeline Dot -->
              <div class="flex-shrink-0 flex flex-col items-center">
                <div class="relative flex items-center justify-center">
                  <div class="absolute inset-0 rounded-full bg-[#0277EE]/10 group-hover:scale-150 transition-transform duration-300"></div>
                  <div class="relative w-8 h-8 rounded-full bg-gradient-to-br from-[#0277EE] to-[#01013D] flex items-center justify-center shadow-lg">
                    <svg class="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                    </svg>
                  </div>
                </div>
              </div>

              <!-- Card Content -->
              <div class="flex-1 min-w-0">
                <div class="bg-white rounded-2xl border border-[#eef0ef] hover:border-[#0277EE] hover:shadow-lg hover:shadow-[#0277EE]/10 transition-all duration-300 overflow-hidden">
                  <!-- Card Header -->
                  <div class="bg-gradient-to-r from-[#eef0ef]/50 to-transparent px-6 py-4 border-b border-[#eef0ef]">
                    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-3">
                      <div class="flex items-center gap-3 flex-wrap">
                        <span class="inline-flex items-center justify-center px-3 py-1 rounded-full bg-gradient-to-r from-[#01013D] to-[#0277EE] text-white text-xs font-bold shadow-md">
                          #{job.id}
                        </span>
                        <span class="{getJobStatusInfo(job.status).badgeClass} text-xs font-semibold px-3 py-1 rounded-full">
                          {getJobStatusInfo(job.status).label}
                        </span>
                        <span class="{getJobPriorityInfo(job.priority).badgeClass} text-xs font-semibold px-3 py-1 rounded-full">
                          {getJobPriorityInfo(job.priority).label}
                        </span>
                      </div>
                      {#if job.deadline}
                        <div class="flex items-center gap-2 text-sm font-semibold text-gray-600 bg-white px-3 py-1 rounded-lg border border-[#eef0ef]">
                          <svg class="w-4 h-4 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                          </svg>
                          {new Date(job.deadline).toLocaleDateString('pt-BR')}
                        </div>
                      {/if}
                    </div>
                    {#if job.title}
                      <h3 class="font-bold text-lg text-[#01013D] line-clamp-2">
                        {job.title}
                      </h3>
                    {/if}
                  </div>

                  <!-- Card Body -->
                  <div class="px-6 py-4 space-y-4">
                    {#if job.description}
                      <p class="text-sm text-gray-700 line-clamp-2 leading-relaxed">
                        {truncateDescription(job.description)}
                      </p>
                    {/if}

                    <!-- Main Info Grid -->
                    <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
                      {#if job.work_number}
                        <div class="bg-[#eef0ef]/50 rounded-lg p-3">
                          <p class="text-xs font-semibold text-gray-500 uppercase mb-1 tracking-wide">Trabalho</p>
                          <p class="text-sm font-bold text-[#0277EE]">{job.work_number}</p>
                        </div>
                      {/if}
                      
                      {#if job.customer_id}
                        <div class="bg-[#eef0ef]/50 rounded-lg p-3">
                          <p class="text-xs font-semibold text-gray-500 uppercase mb-1 tracking-wide">Cliente</p>
                          <p class="text-sm font-bold text-[#01013D]">ID: {job.customer_id}</p>
                        </div>
                      {/if}

                      {#if job.comments_count}
                        <div class="bg-blue-50 rounded-lg p-3">
                          <p class="text-xs font-semibold text-gray-500 uppercase mb-1 tracking-wide">Comentários</p>
                          <p class="text-sm font-bold text-[#0277EE]">{job.comments_count}</p>
                        </div>
                      {/if}
                    </div>

                    <!-- Comments Preview -->
                    {#if job.latest_comment}
                      <div class="bg-gradient-to-r from-[#0277EE]/5 to-transparent border-l-4 border-[#0277EE] rounded-lg p-3">
                        <p class="text-xs font-semibold text-gray-600 mb-1 flex items-center gap-1">
                          <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M2 5a2 2 0 012-2h12a2 2 0 012 2v10a2 2 0 01-2 2H4a2 2 0 01-2-2V5z"/>
                          </svg>
                          Último comentário de {job.latest_comment.author?.name}
                        </p>
                        <p class="text-sm text-[#01013D] line-clamp-2">{job.latest_comment.content}</p>
                      </div>
                    {/if}
                  </div>

                  <!-- Footer with Team -->
                  <div class="bg-gradient-to-r from-[#eef0ef]/30 to-transparent px-6 py-4 border-t border-[#eef0ef] flex items-center justify-between">
                    <div>
                      <p class="text-xs font-semibold text-gray-500 uppercase mb-2 tracking-wide">Equipe</p>
                      <AvatarGroup users={usersAvatar} size="responsive" />
                    </div>
                    <button class="p-2 rounded-lg text-gray-400 hover:text-[#0277EE] hover:bg-[#eef0ef] transition-all duration-200">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  {/if}
</div>
