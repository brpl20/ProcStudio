<!-- components/jobs/JobList.svelte -->
<script lang="ts">
  import { type Job } from '../../api';
  import { getJobStatusInfo, getJobPriorityInfo, JOBSTATUS, JOBPRIORITY } from '../../constants/formOptions';
  import { truncateDescription } from '../../utils/text';
  import Icon from '../../icons/icons.svelte';
  import SearchInput from '../ui/SearchInput.svelte';
  import FilterButton, { type FilterOption } from '../ui/FilterButton.svelte';
  import AvatarGroup from '../ui/AvatarGroup.svelte';
  import { onMount, onDestroy } from 'svelte';
  import Quill from 'quill';
  import 'quill/dist/quill.snow.css';
  import { usersCacheStore, allUserProfiles } from '../../stores/usersCacheStore';
  import type { UserProfileData } from '../../api/types/user.types';

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
  let editingTask = $state<string | null>(null);
  let editingValue = $state('');
  let showDatePicker = $state<string | null>(null);
  let showCreateDrawer = $state(false);
  let showEditDrawer = $state(false);
  let selectedJob = $state<Job | null>(null);
  let activeTab = $state('atualizacoes');
  let commentText = $state('');
  let newJobData = $state({
    title: '',
    description: '',
    status: 'pending',
    priority: 'medium',
    deadline: '',
    work_number: '',
    customer_id: '',
    assignee_ids: [],
    supervisor_ids: [],
    collaborator_ids: []
  });

  // Quill and mentions variables
  let editor: HTMLDivElement;
  let quill: Quill | null = null;
  let showAutocomplete = $state(false);
  let autocompletePosition = $state({ x: 0, y: 0 });
  let mentionSearchTerm = $state('');
  let selectedUser: UserProfileData | null = null;
  let currentMentionRange: any = null;
  let selectedIndex = $state(0);
  let debounceTimer: number | null = null;

  // Create filter options from JOBPRIORITY
  const priorityOptions: FilterOption<string>[] = JOBPRIORITY.map((item) => ({
    value: item.value,
    label: item.label,
    badgeClass: item.badgeClass
  }));

  // Role translations
  const roleTranslations: Record<string, string> = {
    lawyer: 'Advogado',
    secretary: 'Secretário',
    admin: 'Administrador'
  };

  let userProfiles = $derived($allUserProfiles);
  let filteredUsers = $derived(searchUsers(mentionSearchTerm));
  
  $effect(() => {
    if (showAutocomplete && filteredUsers.length > 0) {
      selectedIndex = 0; // Pre-select first user when list updates
    }
  });

  // Deadline checker function
  function getDeadlineStatus(deadline: string | null) {
    if (!deadline) return { status: 'none', class: 'text-base-content/60' };
    
    const deadlineDate = new Date(deadline);
    const today = new Date();
    const timeDiff = deadlineDate.getTime() - today.getTime();
    const daysDiff = Math.ceil(timeDiff / (1000 * 3600 * 24));
    
    if (daysDiff < 0) {
      return { status: 'overdue', class: 'text-error font-medium' };
    } else if (daysDiff <= 7) {
      return { status: 'warning', class: 'text-warning font-medium' };
    } else {
      return { status: 'normal', class: 'text-base-content/60' };
    }
  }

  // Handler functions for inline editing
  function handleStatusChange(jobId: string, newStatus: string) {
    console.log(`Changing job ${jobId} status to ${newStatus}`);
    // In a real app, this would call an API
  }

  function handlePriorityChange(jobId: string, newPriority: string) {
    console.log(`Changing job ${jobId} priority to ${newPriority}`);
    // In a real app, this would call an API
  }

  function startEditingTask(jobId: string, currentDescription: string) {
    editingTask = jobId;
    editingValue = currentDescription || '';
  }

  function saveTaskEdit(jobId: string) {
    console.log(`Saving job ${jobId} description: ${editingValue}`);
    // In a real app, this would call an API
    editingTask = null;
    editingValue = '';
  }

  function cancelTaskEdit() {
    editingTask = null;
    editingValue = '';
  }

  function handleDateChange(jobId: string, event: any) {
    const selectedDate = event.detail.date;
    console.log(`Changing job ${jobId} deadline to ${selectedDate}`);
    // In a real app, this would call an API
    showDatePicker = null;
  }

  function closeDatePicker(event: MouseEvent) {
    if (showDatePicker && !(event.target as Element).closest('.date-picker-container')) {
      showDatePicker = null;
    }
  }

  function openCreateDrawer() {
    newJobData = {
      title: '',
      description: '',
      status: 'pending',
      priority: 'medium',
      deadline: '',
      work_number: '',
      customer_id: '',
      assignee_ids: [],
      supervisor_ids: [],
      collaborator_ids: []
    };
    activeTab = 'atualizacoes';
    showCreateDrawer = true;
  }

  function closeCreateDrawer() {
    showCreateDrawer = false;
    showAutocomplete = false;
  }

  function openEditDrawer(job: Job) {
    selectedJob = job;
    activeTab = 'atualizacoes';
    showEditDrawer = true;
    commentText = '';
  }

  function closeEditDrawer() {
    showEditDrawer = false;
    selectedJob = null;
    showAutocomplete = false;
    commentText = '';
  }

  function postComment() {
    if (!commentText.trim() || !selectedJob) return;
    
    const comment = {
      id: `comment-${Date.now()}`,
      content: commentText,
      author: {
        name: 'Usuário Atual', // In real app, this would come from auth
        avatar: null
      },
      created_at: new Date().toISOString()
    };
    
    console.log('Posting comment to job', selectedJob.id, ':', comment);
    // In a real app, this would call an API to post the comment
    
    commentText = '';
    alert('Comentário adicionado com sucesso!');
  }

  function createNewJob() {
    if (!newJobData.title.trim()) {
      alert('Título da tarefa é obrigatório');
      return;
    }

    const content = quill ? quill.root.innerHTML : newJobData.description;

    const newJob = {
      id: `new-${Date.now()}`,
      title: newJobData.title,
      description: content,
      status: newJobData.status,
      priority: newJobData.priority,
      deadline: newJobData.deadline || null,
      work_number: newJobData.work_number || null,
      customer_id: newJobData.customer_id || null,
      assignee_ids: newJobData.assignee_ids,
      supervisor_ids: newJobData.supervisor_ids,
      collaborator_ids: newJobData.collaborator_ids,
      latest_comment: null,
      comments_count: 0,
      assignees_summary: []
    };
    
    console.log('Creating new job:', newJob);
    // In a real app, this would call an API to create the job
    
    // Add to filteredJobs for immediate display (mock behavior)
    filteredJobs = [newJob, ...filteredJobs];
    
    closeCreateDrawer();
  }

  // Update filteredJobs whenever jobs, searchTerm, or priorityFilter changes
  $effect(() => {
    let result = [...jobs];

    // Apply priority filter
    if (priorityFilter !== 'all') {
      result = result.filter((job) => job.priority === priorityFilter);
    }

    // Apply search filter
    if (searchTerm && searchTerm.trim()) {
      const term = searchTerm.toLowerCase();
      result = result.filter((job) => {
        return (
          job.description?.toLowerCase().includes(term) ||
          // job.latest_comment?.content?.toLowerCase().includes(term) ||
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

  onMount(async () => {
    // Initialize users cache
    await usersCacheStore.initialize();
  });

  onDestroy(() => {
    if (quill) {
      quill.root.removeEventListener('keydown', handleKeydown);
      quill = null;
    }
    if (debounceTimer) {
      clearTimeout(debounceTimer);
    }
  });

  // Initialize Quill when drawer opens
  $effect(() => {
    if (showCreateDrawer && editor && !quill) {
      quill = new Quill(editor, {
        theme: 'snow',
        placeholder: 'Escreva as instruções da tarefa aqui...',
        modules: {
          toolbar: [
            [{ header: [1, 2, 3, false] }],
            ['bold', 'italic', 'underline', 'strike'],
            ['blockquote', 'code-block'],
            [{ list: 'ordered' }, { list: 'bullet' }],
            [{ indent: '-1' }, { indent: '+1' }],
            [{ color: [] }, { background: [] }],
            [{ align: [] }],
            ['link', 'image'],
            ['clean']
          ]
        }
      });

      // Listen for text changes to detect @ mentions
      quill.on('text-change', (delta, oldDelta, source) => {
        if (source === 'user') {
          handleTextChange();
        }
      });

      // Listen for selection changes
      quill.on('selection-change', (range, oldRange, source) => {
        if (!range) {
          showAutocomplete = false;
        }
      });

      // Add keyboard event listener to the editor
      quill.root.addEventListener('keydown', handleKeydown);
    }
  });

  function handleKeydown(event: KeyboardEvent) {
    if (!showAutocomplete) {
      return;
    }

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        selectedIndex = Math.min(selectedIndex + 1, filteredUsers.length - 1);
        break;
      case 'ArrowUp':
        event.preventDefault();
        selectedIndex = Math.max(selectedIndex - 1, 0);
        break;
      case 'Enter':
        event.preventDefault();
        if (filteredUsers[selectedIndex]) {
          handleUserSelect(filteredUsers[selectedIndex]);
        }
        break;
      case 'Escape':
        event.preventDefault();
        showAutocomplete = false;
        currentMentionRange = null;
        break;
    }
  }

  function handleTextChange() {
    if (!quill) {
      return;
    }

    // Clear existing debounce timer
    if (debounceTimer) {
      clearTimeout(debounceTimer);
    }

    // Set new debounce timer
    debounceTimer = setTimeout(() => {
      processTextChange();
    }, 100);
  }

  function processTextChange() {
    if (!quill) {
      return;
    }

    const range = quill.getSelection();
    if (!range) {
      return;
    }

    const text = quill.getText();
    const cursorPos = range.index;

    // Look for @ symbol before cursor
    let atSignPos = -1;
    for (let i = cursorPos - 1; i >= 0; i--) {
      if (text[i] === '@') {
        atSignPos = i;
        break;
      }
      // Stop if we hit a space or newline
      if (text[i] === ' ' || text[i] === '\n') {
        break;
      }
    }

    if (atSignPos !== -1) {
      // Extract the search term after @ (can be empty to show all users)
      mentionSearchTerm = text.substring(atSignPos + 1, cursorPos);

      // Get the position of the @ symbol in the editor
      const bounds = quill.getBounds(atSignPos);

      // Store the range for replacement
      currentMentionRange = {
        index: atSignPos,
        length: cursorPos - atSignPos
      };

      // Show autocomplete immediately when @ is typed
      showAutocomplete = true;
      selectedIndex = 0; // Reset selection to first item

      // Position the autocomplete below the cursor
      autocompletePosition = {
        x: bounds.left,
        y: bounds.bottom + 5
      };
    } else {
      showAutocomplete = false;
      currentMentionRange = null;
    }
  }

  function handleUserSelect(user: UserProfileData) {
    if (!quill || !currentMentionRange) {
      return;
    }

    // Delete the @ and partial name
    quill.deleteText(currentMentionRange.index, currentMentionRange.length);

    // Insert the user mention with formatting
    const userName = `${user.attributes?.name || ''} ${user.attributes?.last_name || ''}`.trim();

    // Insert formatted mention
    quill.insertText(currentMentionRange.index, `@${userName}`, {
      bold: true,
      color: '#0066cc'
    });

    // Insert a space after the mention
    quill.insertText(currentMentionRange.index + userName.length + 1, ' ');

    // Move cursor after the space
    quill.setSelection(currentMentionRange.index + userName.length + 2);

    // Hide autocomplete
    showAutocomplete = false;
    currentMentionRange = null;
    selectedUser = null;
    selectedIndex = 0;
  }

  function searchUsers(term: string) {
    // Show all users when no search term (when @ is just typed)
    if (!term || term.trim() === '') {
      return userProfiles;
    }

    const lowerTerm = term.toLowerCase();
    return userProfiles.filter((profile) => {
      const fullName =
        `${profile.attributes?.name || ''} ${profile.attributes?.last_name || ''}`.toLowerCase();
      const email = profile.attributes?.access_email?.toLowerCase() || '';

      return fullName.includes(lowerTerm) || email.includes(lowerTerm);
    });
  }

  function getUserLabel(user: UserProfileData) {
    if (!user) {
      return '';
    }
    const name = `${user.attributes?.name || ''} ${user.attributes?.last_name || ''}`.trim();
    const email = user.attributes?.access_email || '';
    return name ? `${name} (${email})` : email;
  }
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div onclick={closeDatePicker}>

{#if loading}
  <div class="text-center py-8">
    <div class="loading loading-spinner loading-md text-primary"></div>
    <p class="text-base-content/70 mt-4">Carregando jobs...</p>
  </div>
{:else if error}
  <div class="alert alert-error">
    <Icon name="error" className="h-6 w-6" />
    <div>
      <h3 class="font-bold">Erro ao carregar jobs</h3>
      <div class="text-xs">{error}</div>
    </div>
    <button onclick={onRetry} class="btn btn-sm">Tentar novamente</button>
  </div>
{:else if jobs.length === 0}
  <div class="hero bg-base-200 rounded-lg py-8">
    <div class="hero-content text-center">
      <div class="max-w-md">
        <p class="py-6 text-lg">Nenhum job encontrado</p>
        <p class="text-base-content/60">Os jobs aparecerão aqui quando forem criados.</p>
      </div>
    </div>
  </div>
{:else}
  <div class="mb-4 flex gap-2 items-center">
    <button class="btn btn-primary" onclick={openCreateDrawer}>
      <Icon name="plus" className="h-4 w-4" />
      Nova Tarefa
    </button>
    <SearchInput bind:value={searchTerm} placeholder="Insira palavras chaves..." />
    <FilterButton
      bind:value={priorityFilter}
      options={priorityOptions}
      placeholder="Filtros"
      allOptionLabel="Todas"
      onFilterChange={(value) => priorityFilter = value}
    />
  </div>

  {#if filteredJobs.length === 0}
    <div class="alert alert-info">
      <Icon name="info" className="h-6 w-6" />
      <span>Nenhum job encontrado para "{searchTerm}"</span>
    </div>
  {:else}
    <div class="text-sm text-base-content/60 mb-2">
      Mostrando {filteredJobs.length} de {jobs.length} jobs
    </div>
  {/if}

  <div class="overflow-x-auto">
    <table class="table table-zebra table-xs text-center">
      <thead>
        <tr>
          <th>#</th>
          <th>Tarefas</th>
          <th></th>
          <th>Status</th>
          <th>Prioridade</th>
          <th>Equipe</th>
          <th>Trabalho</th>
          <th>Cliente</th>
        </tr>
      </thead>
      <tbody>
        {#each filteredJobs as job}
          <tr class="hover cursor-pointer" onclick={() => openEditDrawer(job)}>
            <td class="font-mono text-sm">
              {job.id}
            </td>
            <td>
              {#if editingTask === job.id}
                <div class="flex gap-1">
                  <input 
                    type="text" 
                    class="input input-xs flex-1" 
                    bind:value={editingValue}
                    onkeydown={(e) => {
                      if (e.key === 'Enter') saveTaskEdit(job.id);
                      if (e.key === 'Escape') cancelTaskEdit();
                    }}
                    autofocus
                  />
                  <button class="btn btn-xs btn-success" onclick={() => saveTaskEdit(job.id)}>
                    <Icon name="check" className="h-3 w-3" />
                  </button>
                  <button class="btn btn-xs btn-ghost" onclick={cancelTaskEdit}>
                    <Icon name="x" className="h-3 w-3" />
                  </button>
                </div>
              {:else}
                {#if job.description}
                  <div 
                    class="font-medium tooltip cursor-pointer hover:bg-base-200 p-1 rounded" 
                    data-tip="Clique para editar"
                    onclick={() => startEditingTask(job.id, job.description)}
                  >
                    {truncateDescription(job.description)}
                  </div>
                {:else}
                  <div 
                    class="font-medium text-base-content/60 cursor-pointer hover:bg-base-200 p-1 rounded" 
                    onclick={() => startEditingTask(job.id, '')}
                  >
                    Sem descrição
                  </div>
                {/if}
              {/if}
            </td>
            <td class="w-12 text-center">
              {#if job.latest_comment}
                <div class="tooltip tooltip-left" data-tip={job.latest_comment.content}>
                  <div class="flex items-center gap-1">
                    <Icon
                      name="comment"
                      className="h-6 w-6 text-primary hover:text-primary-focus cursor-help"
                    />
                    {#if job.comments_count && job.comments_count > 1}
                      <span class="badge badge-xs badge-primary">{job.comments_count}</span>
                    {/if}
                  </div>
                </div>
              {:else}
                <Icon
                  name="comment"
                  className="h-6 w-6 text-primary hover:text-primary-focus cursor-help"
                />
              {/if}
            </td>
            <td>
              <div class="flex flex-col gap-1">
                <div>
                  <select 
                    class="select select-xs max-w-xs {getJobStatusInfo(job.status).badgeClass.replace('badge', 'select')}"
                    value={job.status}
                    onchange={(e) => handleStatusChange(job.id, e.target.value)}
                  >
                    {#each JOBSTATUS as status}
                      <option value={status.value}>{status.label}</option>
                    {/each}
                  </select>
                </div>
                <div class="relative">
                  <div 
                    class="text-xs {getDeadlineStatus(job.deadline).class} cursor-pointer hover:bg-base-200 p-1 rounded" 
                    onclick={() => showDatePicker = showDatePicker === job.id ? null : job.id}
                    data-tip="Clique para alterar prazo"
                  >
                    {#if job.deadline}
                      {new Date(job.deadline).toLocaleDateString('pt-BR')}
                    {:else}
                      Sem prazo
                    {/if}
                  </div>
                  {#if showDatePicker === job.id}
                    <div class="absolute z-50 mt-2 date-picker-container">
                      <calendar-date 
                        class="cally bg-base-100 border border-base-300 shadow-lg rounded-box"
                        ondatechange={(e) => handleDateChange(job.id, e)}
                      >
                        <svg aria-label="Previous" class="fill-current size-4" slot="previous" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M15.75 19.5 8.25 12l7.5-7.5"></path></svg>
                        <svg aria-label="Next" class="fill-current size-4" slot="next" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="m8.25 4.5 7.5 7.5-7.5 7.5"></path></svg>
                        <calendar-month></calendar-month>
                      </calendar-date>
                    </div>
                  {/if}
                </div>
              </div>
            </td>
            <td>
              <div class="tooltip md:hidden" data-tip={getJobPriorityInfo(job.priority).label}>
                <select 
                  class="select select-xs w-8 h-8 p-0 min-h-0"
                  value={job.priority}
                  onchange={(e) => handlePriorityChange(job.id, e.target.value)}
                >
                  {#each JOBPRIORITY as priority}
                    <option value={priority.value}>{priority.label.charAt(0)}</option>
                  {/each}
                </select>
              </div>
              <div class="hidden md:inline-block">
                <select 
                  class="select select-xs max-w-xs {getJobPriorityInfo(job.priority).badgeClass.replace('badge', 'select')}"
                  value={job.priority}
                  onchange={(e) => handlePriorityChange(job.id, e.target.value)}
                >
                  {#each JOBPRIORITY as priority}
                    <option value={priority.value}>{priority.label}</option>
                  {/each}
                </select>
              </div>
            </td>
            <td>
              <AvatarGroup users={usersAvatar} size="sm" />
            </td>
            <td>
              {#if job.work_number}
                <div class="font-medium">{job.work_number}</div>
              {:else}
                <div class="font-medium text-base-content/60">Sem trabalho</div>
              {/if}
            </td>
            <td>
              {#if job.customer_id}
                <div class="font-medium">ID: {job.customer_id}</div>
              {:else}
                <div class="font-medium text-base-content/60">Sem cliente</div>
              {/if}
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
{/if}

<!-- Create Job Drawer -->
<div class="drawer drawer-end z-50">
  <input id="create-job-drawer" type="checkbox" class="drawer-toggle" bind:checked={showCreateDrawer} />

  <div class="drawer-side">
    <label for="create-job-drawer" aria-label="close sidebar" class="drawer-overlay"></label>

    <div class="menu bg-base-100 text-base-content min-h-full w-96 p-0">
      <div class="flex items-center justify-between p-4 border-b">
        <h3 class="text-lg font-semibold">Criar Nova Tarefa</h3>
        <button class="btn btn-sm btn-ghost btn-circle" aria-label="Fechar" onclick={closeCreateDrawer}>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Tabs -->
      <div class="tabs tabs-box w-full">
        <button 
          class="tab flex-1 {activeTab === 'atualizacoes' ? 'tab-active' : ''}" 
          onclick={() => activeTab = 'atualizacoes'}
        >
          Atualizações
        </button>
        <button 
          class="tab flex-1 {activeTab === 'arquivos' ? 'tab-active' : ''}" 
          onclick={() => activeTab = 'arquivos'}
        >
          Arquivos
        </button>
        <button 
          class="tab flex-1 {activeTab === 'log' ? 'tab-active' : ''}" 
          onclick={() => activeTab = 'log'}
        >
          Log
        </button>
      </div>

      <div class="flex-1 flex flex-col p-4 relative">
        {#if activeTab === 'atualizacoes'}
          <form class="space-y-4 flex-1" onsubmit={(e) => { e.preventDefault(); createNewJob(); }}>
            <!-- Job Title -->
            <div>
              <label class="label">
                <span class="label-text">Título da Tarefa *</span>
              </label>
              <input 
                type="text" 
                class="input input-bordered w-full" 
                bind:value={newJobData.title}
                placeholder="Digite o título da tarefa..."
                required
                autofocus
              />
            </div>

            <!-- Status -->
            <div>
              <label class="label">
                <span class="label-text">Status</span>
              </label>
              <select class="select select-bordered w-full" bind:value={newJobData.status}>
                {#each JOBSTATUS as status}
                  <option value={status.value}>{status.label}</option>
                {/each}
              </select>
            </div>

            <!-- Priority -->
            <div>
              <label class="label">
                <span class="label-text">Prioridade</span>
              </label>
              <select class="select select-bordered w-full" bind:value={newJobData.priority}>
                {#each JOBPRIORITY as priority}
                  <option value={priority.value}>{priority.label}</option>
                {/each}
              </select>
            </div>

            <!-- Deadline -->
            <div>
              <label class="label">
                <span class="label-text">Prazo</span>
              </label>
              <input 
                type="date" 
                class="input input-bordered w-full" 
                bind:value={newJobData.deadline}
              />
            </div>

            <!-- Work Number -->
            <div>
              <label class="label">
                <span class="label-text">Número do Trabalho</span>
              </label>
              <input 
                type="text" 
                class="input input-bordered w-full" 
                bind:value={newJobData.work_number}
                placeholder="Ex: PROC-2024-001"
              />
            </div>

            <!-- Customer ID -->
            <div>
              <label class="label">
                <span class="label-text">ID do Cliente</span>
              </label>
              <input 
                type="text" 
                class="input input-bordered w-full" 
                bind:value={newJobData.customer_id}
                placeholder="Ex: CLI-001"
              />
            </div>

            <!-- Task Instructions with Quill Editor -->
            <div class="mb-4">
              <label class="label">
                <span class="label-text">Instruções da Tarefa</span>
              </label>
              <div class="border rounded-lg bg-base-100 relative">
                <div bind:this={editor} class="min-h-[200px]"></div>

                {#if showAutocomplete}
                  <div
                    class="absolute bg-base-100 border-2 rounded-lg shadow-2xl max-h-96 overflow-y-auto z-50"
                    style="left: {autocompletePosition.x}px; top: {autocompletePosition.y}px; min-width: 320px;"
                  >
                    <!-- Users Header -->
                    <div class="sticky top-0 bg-base-200 px-4 py-2 border-b">
                      <h4 class="font-semibold text-sm flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" />
                        </svg>
                        Usuários
                      </h4>
                    </div>

                    <div class="p-2">
                      {#if filteredUsers.length === 0}
                        <div class="text-sm text-base-content/60 p-4 text-center">
                          Nenhum usuário encontrado
                        </div>
                      {:else}
                        <div class="text-xs text-base-content/60 mb-2 px-2">
                          {filteredUsers.length} usuário{filteredUsers.length !== 1 ? 's' : ''} encontrado{filteredUsers.length !== 1 ? 's' : ''}
                        </div>
                        {#each filteredUsers.slice(0, 8) as user, index}
                          <button
                            class="w-full text-left p-3 rounded-lg flex items-center gap-3 transition-colors {index === selectedIndex ? 'bg-primary/10 ring-2 ring-primary' : 'hover:bg-base-200'}"
                            onclick={() => handleUserSelect(user)}
                            onmouseenter={() => (selectedIndex = index)}
                          >
                            {#if user.attributes?.avatar_url}
                              <img
                                src={user.attributes.avatar_url}
                                alt={user.attributes?.name || ''}
                                class="w-10 h-10 rounded-full object-cover"
                              />
                            {:else}
                              <div class="w-10 h-10 rounded-full bg-primary text-primary-content flex items-center justify-center text-sm font-semibold">
                                {(user.attributes?.name || '?')[0].toUpperCase()}
                              </div>
                            {/if}
                            <div class="flex-1 min-w-0">
                              <div class="font-medium truncate">
                                {user.attributes?.name || ''} {user.attributes?.last_name || ''}
                              </div>
                              <div class="text-xs text-base-content/60 truncate">
                                {user.attributes?.access_email || ''}
                              </div>
                              {#if user.attributes?.oab}
                                <div class="text-xs text-base-content/50 mt-0.5">
                                  OAB: {user.attributes.oab}
                                </div>
                              {/if}
                            </div>
                            {#if index === selectedIndex}
                              <div class="text-xs text-primary">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                              </div>
                            {/if}
                          </button>
                        {/each}
                      {/if}
                    </div>

                    <!-- Keyboard shortcuts hint -->
                    <div class="sticky bottom-0 bg-base-200 px-4 py-2 border-t text-xs text-base-content/60">
                      <div class="flex gap-4">
                        <span>↑↓ Navegar</span>
                        <span>Enter Selecionar</span>
                        <span>Esc Fechar</span>
                      </div>
                    </div>
                  </div>
                {/if}
              </div>
              <div class="text-xs text-base-content/60 mt-1">Digite @ para mencionar um usuário</div>
            </div>

            <!-- User Attributions Section -->
            <div class="space-y-4">
              <h4 class="font-medium text-base">Atribuições de Usuários</h4>
              
              <!-- Assignees -->
              <div>
                <label class="label">
                  <span class="label-text">Responsáveis</span>
                  <span class="label-text-alt text-xs">Usuários que executarão a tarefa</span>
                </label>
                <select 
                  class="select select-bordered w-full" 
                  multiple
                  bind:value={newJobData.assignee_ids}
                >
                  {#each userProfiles as user}
                    <option value={user.id}>
                      {user.attributes?.name || ''} {user.attributes?.last_name || ''} ({user.attributes?.access_email || ''})
                    </option>
                  {/each}
                </select>
                <div class="text-xs text-base-content/60 mt-1">
                  Segure Ctrl/Cmd para selecionar múltiplos usuários
                </div>
              </div>

              <!-- Supervisors -->
              <div>
                <label class="label">
                  <span class="label-text">Supervisores</span>
                  <span class="label-text-alt text-xs">Usuários que supervisionarão a tarefa</span>
                </label>
                <select 
                  class="select select-bordered w-full" 
                  multiple
                  bind:value={newJobData.supervisor_ids}
                >
                  {#each userProfiles as user}
                    <option value={user.id}>
                      {user.attributes?.name || ''} {user.attributes?.last_name || ''} ({user.attributes?.access_email || ''})
                    </option>
                  {/each}
                </select>
                <div class="text-xs text-base-content/60 mt-1">
                  Segure Ctrl/Cmd para selecionar múltiplos usuários
                </div>
              </div>

              <!-- Collaborators -->
              <div>
                <label class="label">
                  <span class="label-text">Colaboradores</span>
                  <span class="label-text-alt text-xs">Usuários que colaborarão na tarefa</span>
                </label>
                <select 
                  class="select select-bordered w-full" 
                  multiple
                  bind:value={newJobData.collaborator_ids}
                >
                  {#each userProfiles as user}
                    <option value={user.id}>
                      {user.attributes?.name || ''} {user.attributes?.last_name || ''} ({user.attributes?.access_email || ''})
                    </option>
                  {/each}
                </select>
                <div class="text-xs text-base-content/60 mt-1">
                  Segure Ctrl/Cmd para selecionar múltiplos usuários
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div class="mt-auto pt-4 border-t">
              <div class="flex gap-2 justify-end">
                <button type="button" class="btn btn-ghost" onclick={closeCreateDrawer}>
                  Cancelar
                </button>
                <button type="submit" class="btn btn-primary">
                  <Icon name="plus" className="h-4 w-4" />
                  Criar Tarefa
                </button>
              </div>
            </div>
          </form>
        {:else if activeTab === 'arquivos'}
          <div class="flex-1 flex items-center justify-center">
            <div class="text-center text-base-content/60">
              <Icon name="folder" className="h-12 w-12 mx-auto mb-2" />
              <p>Arquivos serão disponibilizados após a criação da tarefa</p>
            </div>
          </div>
        {:else if activeTab === 'log'}
          <div class="flex-1 flex items-center justify-center">
            <div class="text-center text-base-content/60">
              <Icon name="clock" className="h-12 w-12 mx-auto mb-2" />
              <p>Histórico será disponibilizado após a criação da tarefa</p>
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>

<!-- Edit Job Drawer -->
<div class="drawer drawer-end z-50">
  <input id="edit-job-drawer" type="checkbox" class="drawer-toggle" bind:checked={showEditDrawer} />

  <div class="drawer-side">
    <label for="edit-job-drawer" aria-label="close sidebar" class="drawer-overlay"></label>

    <div class="menu bg-base-100 text-base-content min-h-full w-96 p-0">
      <div class="flex items-center justify-between p-4 border-b">
        <div>
          <h3 class="text-lg font-semibold">
            {selectedJob?.title || selectedJob?.description || 'Tarefa'}
          </h3>
          <p class="text-sm text-base-content/60">#{selectedJob?.id}</p>
        </div>
        <button class="btn btn-sm btn-ghost btn-circle" aria-label="Fechar" onclick={closeEditDrawer}>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Tabs -->
      <div class="tabs tabs-box w-full">
        <button 
          class="tab flex-1 {activeTab === 'atualizacoes' ? 'tab-active' : ''}" 
          onclick={() => activeTab = 'atualizacoes'}
        >
          Atualizações
        </button>
        <button 
          class="tab flex-1 {activeTab === 'arquivos' ? 'tab-active' : ''}" 
          onclick={() => activeTab = 'arquivos'}
        >
          Arquivos
        </button>
        <button 
          class="tab flex-1 {activeTab === 'log' ? 'tab-active' : ''}" 
          onclick={() => activeTab = 'log'}
        >
          Log
        </button>
      </div>

      <div class="flex-1 flex flex-col p-4 relative">
        {#if activeTab === 'atualizacoes'}
          <div class="space-y-4 flex-1">
            <!-- Job Information Display -->
            <div class="bg-base-200 p-4 rounded-lg space-y-3">
              <div class="grid grid-cols-2 gap-3 text-sm">
                <div>
                  <span class="text-base-content/60">Status:</span>
                  <div class="mt-1">
                    <span class="{getJobStatusInfo(selectedJob?.status || '').badgeClass} badge-xs">
                      {getJobStatusInfo(selectedJob?.status || '').label}
                    </span>
                  </div>
                </div>
                <div>
                  <span class="text-base-content/60">Prioridade:</span>
                  <div class="mt-1">
                    <span class="{getJobPriorityInfo(selectedJob?.priority || '').badgeClass} badge-xs">
                      {getJobPriorityInfo(selectedJob?.priority || '').label}
                    </span>
                  </div>
                </div>
                <div>
                  <span class="text-base-content/60">Prazo:</span>
                  <div class="mt-1 text-xs {getDeadlineStatus(selectedJob?.deadline || null).class}">
                    {selectedJob?.deadline ? new Date(selectedJob.deadline).toLocaleDateString('pt-BR') : 'Sem prazo'}
                  </div>
                </div>
                <div>
                  <span class="text-base-content/60">Trabalho:</span>
                  <div class="mt-1 text-xs">
                    {selectedJob?.work_number || 'Não informado'}
                  </div>
                </div>
              </div>
              {#if selectedJob?.description}
                <div>
                  <span class="text-base-content/60 text-sm">Descrição:</span>
                  <div class="mt-1 text-sm bg-base-100 p-2 rounded border">
                    {@html selectedJob.description}
                  </div>
                </div>
              {/if}
            </div>

            <!-- Comments Section -->
            <div class="flex-1 flex flex-col">
              <h4 class="font-medium mb-3">Comentários</h4>
              
              <!-- Existing Comments (Mock) -->
              <div class="flex-1 space-y-3 mb-4 max-h-64 overflow-y-auto">
                {#if selectedJob?.latest_comment}
                  <div class="bg-base-200 p-3 rounded-lg">
                    <div class="flex items-start gap-3">
                      <div class="w-8 h-8 bg-primary text-primary-content rounded-full flex items-center justify-center text-sm font-semibold">
                        {selectedJob.latest_comment.author?.name?.[0]?.toUpperCase() || 'U'}
                      </div>
                      <div class="flex-1">
                        <div class="flex items-center gap-2 mb-1">
                          <span class="font-medium text-sm">{selectedJob.latest_comment.author?.name || 'Usuário'}</span>
                          <span class="text-xs text-base-content/60">há 2 horas</span>
                        </div>
                        <p class="text-sm">{selectedJob.latest_comment.content}</p>
                      </div>
                    </div>
                  </div>
                {:else}
                  <div class="text-center text-base-content/60 py-8">
                    <Icon name="message-circle" className="h-12 w-12 mx-auto mb-2 opacity-50" />
                    <p>Nenhum comentário ainda</p>
                    <p class="text-xs">Seja o primeiro a comentar!</p>
                  </div>
                {/if}
              </div>

              <!-- Add Comment Form -->
              <div class="border-t pt-4">
                <div class="flex gap-3">
                  <div class="w-8 h-8 bg-secondary text-secondary-content rounded-full flex items-center justify-center text-sm font-semibold">
                    U
                  </div>
                  <div class="flex-1">
                    <textarea 
                      class="textarea textarea-bordered w-full resize-none" 
                      rows="3"
                      placeholder="Adicione um comentário..."
                      bind:value={commentText}
                    ></textarea>
                    <div class="flex justify-end mt-2">
                      <button 
                        class="btn btn-primary btn-sm"
                        onclick={postComment}
                        disabled={!commentText.trim()}
                      >
                        <Icon name="send" className="h-4 w-4" />
                        Comentar
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        {:else if activeTab === 'arquivos'}
          <div class="flex-1 flex items-center justify-center">
            <div class="text-center text-base-content/60">
              <Icon name="folder" className="h-12 w-12 mx-auto mb-2" />
              <p>Arquivos da tarefa #{selectedJob?.id}</p>
              <p class="text-xs mt-1">Funcionalidade em desenvolvimento</p>
            </div>
          </div>
        {:else if activeTab === 'log'}
          <div class="flex-1 flex items-center justify-center">
            <div class="text-center text-base-content/60">
              <Icon name="clock" className="h-12 w-12 mx-auto mb-2" />
              <p>Histórico da tarefa #{selectedJob?.id}</p>
              <p class="text-xs mt-1">Funcionalidade em desenvolvimento</p>
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>

</div>

<style>
  :global(.ql-toolbar) {
    border-top-left-radius: 0.5rem;
    border-top-right-radius: 0.5rem;
    border-color: oklch(var(--bc) / 0.2);
  }

  :global(.ql-container) {
    border-bottom-left-radius: 0.5rem;
    border-bottom-right-radius: 0.5rem;
    border-color: oklch(var(--bc) / 0.2);
    font-size: 1rem;
  }

  :global(.ql-editor) {
    min-height: 250px;
  }

  :global(.ql-editor.ql-blank::before) {
    color: oklch(var(--bc) / 0.5);
    font-style: normal;
  }
</style>
