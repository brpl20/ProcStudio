<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { JOBSTATUS, JOBPRIORITY } from '../../constants/formOptions';
  import Icon from '../../icons/icons.svelte';
  import QuillMentionEditor from '../QuillMetionEditor.svelte';
  import { allUserProfiles } from '../../stores/usersCacheStore';
  import api, { type Draft } from '../../api';

  interface Props {
    isOpen: boolean;
    onClose: () => void;
    onCreate: (jobData: any) => void;
  }

  let { isOpen = $bindable(), onClose, onCreate }: Props = $props();

  let activeTab = $state('atualizacoes');
  let editor: QuillMentionEditor;
  let newJobData = $state({
    title: '',
    status: 'pending',
    priority: 'medium',
    deadline: '',
    work_number: '',
    customer_id: '',
    assignee_ids: [],
    supervisor_ids: [],
    collaborator_ids: []
  });

  let userProfiles = $derived($allUserProfiles);

  // Draft management
  let drafts = $state<Draft[]>([]);
  let loadingDrafts = $state(false);
  let currentDraftId = $state<number | null>(null);
  let sessionId = $state<string | null>(null);
  let autoSaveTimer: number | null = null;
  let hasUnsavedChanges = $state(false);
  let lastSavedAt = $state<Date | null>(null);
  let isSaving = $state(false);
  let showDraftList = $state(false);

  // Generate session ID on mount
  onMount(() => {
    if (!sessionId) {
      sessionId = crypto.randomUUID();
    }
    loadDrafts();
  });

  // Auto-save functionality
  $effect(() => {
    // Track any form field changes
    const _ = [
      newJobData.title,
      newJobData.status,
      newJobData.priority,
      newJobData.deadline,
      newJobData.work_number,
      newJobData.customer_id,
      newJobData.assignee_ids,
      newJobData.supervisor_ids,
      newJobData.collaborator_ids
    ];

    // Only auto-save if form has content and is open
    if (isOpen && (newJobData.title || editor?.getContent())) {
      hasUnsavedChanges = true;

      // Clear existing timer
      if (autoSaveTimer) {
        clearTimeout(autoSaveTimer);
      }

      // Set new auto-save timer (3 seconds debounce)
      autoSaveTimer = setTimeout(() => {
        saveDraft();
      }, 3000);
    }
  });

  // Cleanup on destroy
  onDestroy(() => {
    if (autoSaveTimer) {
      clearTimeout(autoSaveTimer);
    }
  });

  async function loadDrafts() {
    try {
      loadingDrafts = true;
      const response = await api.drafts.getDrafts('job_creation');
      if (response.success && response.data) {
        drafts = response.data;
      }
    } catch (err) {
      console.error('Failed to load drafts:', err);
    } finally {
      loadingDrafts = false;
    }
  }

  function loadDraftData(draft: Draft) {
    const data = draft.data;
    newJobData = {
      title: data.title || '',
      status: data.status || 'pending',
      priority: data.priority || 'medium',
      deadline: data.deadline || '',
      work_number: data.work_number || '',
      customer_id: data.customer_id || '',
      assignee_ids: data.assignee_ids || [],
      supervisor_ids: data.supervisor_ids || [],
      collaborator_ids: data.collaborator_ids || []
    };

    if (data.description && editor) {
      editor.setContent(data.description);
    }

    currentDraftId = draft.id;
    sessionId = draft.session_id || sessionId;
    hasUnsavedChanges = false;
    lastSavedAt = new Date(draft.updated_at);
    showDraftList = false;
  }

  async function saveDraft() {
    if (isSaving) return;

    try {
      isSaving = true;
      const content = editor?.getContent() || '';
      const draftData = {
        form_type: 'job_creation',
        draftable_type: 'Job',
        draftable_id: null,
        data: {
          ...newJobData,
          description: content
        },
        session_id: sessionId || undefined
      };

      let response;
      if (currentDraftId) {
        response = await api.drafts.updateDraft(currentDraftId, { data: draftData.data });
      } else {
        response = await api.drafts.saveDraft(draftData);
      }

      if (response.success && response.data) {
        currentDraftId = response.data.id;
        sessionId = response.data.session_id || sessionId;
        hasUnsavedChanges = false;
        lastSavedAt = new Date();
        await loadDrafts();
      }
    } catch (err) {
      console.error('Failed to save draft:', err);
    } finally {
      isSaving = false;
    }
  }

  async function deleteDraft(draftId: number) {
    if (!confirm('Tem certeza que deseja descartar este rascunho?')) {
      return;
    }

    try {
      await api.drafts.deleteDraft(draftId);
      await loadDrafts();
      if (currentDraftId === draftId) {
        resetForm();
      }
    } catch (err) {
      console.error('Failed to delete draft:', err);
    }
  }

  function formatLastSaved(date: Date | null): string {
    if (!date) return '';

    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const seconds = Math.floor(diff / 1000);

    if (seconds < 10) return 'agora mesmo';
    if (seconds < 60) return `há ${seconds} segundos`;

    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `há ${minutes} minuto${minutes > 1 ? 's' : ''}`;

    const hours = Math.floor(minutes / 60);
    return `há ${hours} hora${hours > 1 ? 's' : ''}`;
  }

  function formatDate(dateString: string): string {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  function handleClose() {
    resetForm();
    onClose();
  }

  function resetForm() {
    newJobData = {
      title: '',
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
    currentDraftId = null;
    sessionId = crypto.randomUUID();
    hasUnsavedChanges = false;
    lastSavedAt = null;
    if (editor) {
      editor.setContent('');
    }
  }

  async function handleSubmit(e: Event) {
    e.preventDefault();

    if (!newJobData.title.trim()) {
      alert('Título da tarefa é obrigatório');
      return;
    }

    const content = editor?.getContent() || '';

    const jobData = {
      ...newJobData,
      description: content
    };

    // Create the job
    onCreate(jobData);

    // Mark draft as fulfilled if there's a current draft
    if (currentDraftId) {
      try {
        // We'll need the job ID from onCreate, but for now let's just delete the draft
        await api.drafts.deleteDraft(currentDraftId);
        await loadDrafts();
      } catch (err) {
        console.error('Failed to fulfill draft:', err);
      }
    }

    handleClose();
  }
</script>

<div class="drawer drawer-end z-50">
  <input
    id="create-job-drawer"
    type="checkbox"
    class="drawer-toggle"
    bind:checked={isOpen}
  />

  <div class="drawer-side">
    <label for="create-job-drawer" aria-label="close sidebar" class="drawer-overlay"></label>

    <div class="menu bg-base-100 text-base-content min-h-full w-96 p-0">
      <div class="flex items-center justify-between p-4 border-b">
        <h3 class="text-lg font-semibold">Criar Nova Tarefa</h3>
        <button class="btn btn-sm btn-ghost btn-circle" onclick={handleClose}>
          <Icon name="x" className="h-5 w-5" />
        </button>
      </div>

      <!-- Draft Selection -->
      <div class="p-4 border-b bg-base-200">
        <button
          class="btn btn-sm btn-outline w-full justify-between"
          onclick={() => (showDraftList = !showDraftList)}
        >
          <span class="flex items-center gap-2">
            <Icon name="file-text" className="h-4 w-4" />
            {#if currentDraftId}
              Rascunho Carregado
            {:else}
              Carregar Rascunho
            {/if}
          </span>
          <Icon
            name="chevron-down"
            className="h-4 w-4 transition-transform {showDraftList ? 'rotate-180' : ''}"
          />
        </button>

        {#if showDraftList}
          <div class="mt-2 max-h-48 overflow-y-auto border rounded-lg bg-base-100">
            {#if loadingDrafts}
              <div class="flex items-center justify-center p-4">
                <span class="loading loading-spinner loading-sm"></span>
              </div>
            {:else if drafts.length === 0}
              <div class="p-4 text-center text-sm text-base-content/60">
                Nenhum rascunho disponível
              </div>
            {:else}
              {#each drafts as draft}
                <div class="flex items-center gap-2 p-2 border-b last:border-b-0 hover:bg-base-200">
                  <button
                    class="flex-1 text-left text-sm"
                    onclick={() => loadDraftData(draft)}
                  >
                    <div class="font-medium truncate">
                      {draft.data.title || 'Sem título'}
                    </div>
                    <div class="text-xs text-base-content/60">
                      {formatDate(draft.updated_at)}
                    </div>
                  </button>
                  <button
                    class="btn btn-xs btn-ghost btn-circle"
                    onclick={() => deleteDraft(draft.id)}
                  >
                    <Icon name="trash" className="h-3 w-3" />
                  </button>
                </div>
              {/each}
            {/if}
          </div>
        {/if}

        <!-- Auto-save indicator -->
        <div class="mt-2 flex items-center gap-2 text-xs">
          {#if isSaving}
            <span class="loading loading-spinner loading-xs"></span>
            <span class="text-base-content/60">Salvando...</span>
          {:else if lastSavedAt}
            <span class="text-success">✓</span>
            <span class="text-base-content/60">Salvo {formatLastSaved(lastSavedAt)}</span>
          {:else if hasUnsavedChanges}
            <span class="text-warning">⚠</span>
            <span class="text-base-content/60">Não salvo</span>
          {/if}
        </div>
      </div>

      <!-- Tabs -->
      <div class="tabs tabs-boxed w-full">
        <button
          class="tab flex-1 {activeTab === 'atualizacoes' ? 'tab-active' : ''}"
          onclick={() => (activeTab = 'atualizacoes')}
        >
          Atualizações
        </button>
        <button
          class="tab flex-1 {activeTab === 'arquivos' ? 'tab-active' : ''}"
          onclick={() => (activeTab = 'arquivos')}
        >
          Arquivos
        </button>
        <button
          class="tab flex-1 {activeTab === 'log' ? 'tab-active' : ''}"
          onclick={() => (activeTab = 'log')}
        >
          Log
        </button>
      </div>

      <div class="flex-1 flex flex-col p-4">
        {#if activeTab === 'atualizacoes'}
          <form class="space-y-4 flex-1" onsubmit={handleSubmit}>
            <div>
              <label class="label">
                <span class="label-text">Título da Tarefa *</span>
              </label>
              <input
                type="text"
                class="input input-bordered w-full"
                bind:value={newJobData.title}
                placeholder="Digite o título..."
                required
                autofocus
              />
            </div>

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

            <div>
              <label class="label">
                <span class="label-text">Instruções da Tarefa</span>
              </label>
              <QuillMentionEditor
                bind:this={editor}
                placeholder="Escreva as instruções..."
                minHeight="200px"
              />
            </div>

            <!-- User Attributions -->
            <div class="space-y-4">
              <h4 class="font-medium">Atribuições</h4>

              <div>
                <label class="label">
                  <span class="label-text">Responsáveis</span>
                </label>
                <select class="select select-bordered w-full" multiple bind:value={newJobData.assignee_ids}>
                  {#each userProfiles as user}
                    <option value={user.id}>
                      {user.attributes?.name} {user.attributes?.last_name}
                    </option>
                  {/each}
                </select>
              </div>

              <div>
                <label class="label">
                  <span class="label-text">Supervisores</span>
                </label>
                <select class="select select-bordered w-full" multiple bind:value={newJobData.supervisor_ids}>
                  {#each userProfiles as user}
                    <option value={user.id}>
                      {user.attributes?.name} {user.attributes?.last_name}
                    </option>
                  {/each}
                </select>
              </div>
            </div>

            <div class="mt-auto pt-4 border-t flex gap-2 justify-end">
              <button type="button" class="btn btn-ghost" onclick={handleClose}>
                Cancelar
              </button>
              <button type="submit" class="btn btn-primary">
                <Icon name="plus" className="h-4 w-4" />
                Criar Tarefa
              </button>
            </div>
          </form>
        {:else if activeTab === 'arquivos'}
          <div class="flex-1 flex items-center justify-center text-center text-base-content/60">
            <div>
              <Icon name="folder" className="h-12 w-12 mx-auto mb-2" />
              <p>Arquivos disponíveis após criação</p>
            </div>
          </div>
        {:else}
          <div class="flex-1 flex items-center justify-center text-center text-base-content/60">
            <div>
              <Icon name="clock" className="h-12 w-12 mx-auto mb-2" />
              <p>Log disponível após criação</p>
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>
