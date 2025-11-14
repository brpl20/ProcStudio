<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import api, { type Draft } from '../../api';
  import type { JobStatus, JobPriority } from '../../api/types/job.types';

  // Props
  let {
    isOpen = $bindable(false),
    onSuccess = () => {},
    selectedDraft = $bindable<Draft | null>(null)
  }: {
    isOpen?: boolean;
    onSuccess?: (job: any) => void;
    selectedDraft?: Draft | null;
  } = $props();

  // Form state
  let formData = $state({
    title: '',
    description: '',
    status: 'pending' as JobStatus,
    priority: 'medium' as JobPriority,
    deadline: '',
    assigned_to: undefined as number | undefined
  });

  let loading = $state(false);
  let error = $state<string | null>(null);
  let currentDraftId = $state<number | null>(null);
  let sessionId = $state<string | null>(null);
  let autoSaveTimer: number | null = null;
  let hasUnsavedChanges = $state(false);
  let lastSavedAt = $state<Date | null>(null);
  let isSaving = $state(false);

  // Status options
  const statusOptions: { value: JobStatus; label: string }[] = [
    { value: 'pending', label: 'Pendente' },
    { value: 'in_progress', label: 'Em Andamento' },
    { value: 'completed', label: 'Concluído' },
    { value: 'cancelled', label: 'Cancelado' }
  ];

  // Priority options
  const priorityOptions: { value: JobPriority; label: string }[] = [
    { value: 'low', label: 'Baixa' },
    { value: 'medium', label: 'Média' },
    { value: 'high', label: 'Alta' },
    { value: 'urgent', label: 'Urgente' }
  ];

  // Generate session ID on mount
  onMount(() => {
    if (!sessionId) {
      sessionId = crypto.randomUUID();
    }

    // Load selected draft if provided
    if (selectedDraft) {
      loadDraft(selectedDraft);
    }
  });

  // Watch for changes in selectedDraft
  $effect(() => {
    if (selectedDraft && isOpen) {
      loadDraft(selectedDraft);
    }
  });

  // Auto-save functionality
  $effect(() => {
    // Track any form field changes
    const _ = [
      formData.title,
      formData.description,
      formData.status,
      formData.priority,
      formData.deadline,
      formData.assigned_to
    ];

    // Only auto-save if form has content and is open
    if (isOpen && (formData.title || formData.description)) {
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

  function loadDraft(draft: Draft) {
    const data = draft.data;
    formData = {
      title: data.title || '',
      description: data.description || '',
      status: (data.status as JobStatus) || 'pending',
      priority: (data.priority as JobPriority) || 'medium',
      deadline: data.deadline || '',
      assigned_to: data.assigned_to
    };

    currentDraftId = draft.id;
    sessionId = draft.session_id || sessionId;
    hasUnsavedChanges = false;
    lastSavedAt = new Date(draft.updated_at);
  }

  async function saveDraft() {
    if (isSaving) return;

    try {
      isSaving = true;
      const draftData = {
        form_type: 'job_creation',
        draftable_type: 'Job',
        draftable_id: null,
        data: {
          title: formData.title,
          description: formData.description,
          status: formData.status,
          priority: formData.priority,
          deadline: formData.deadline,
          assigned_to: formData.assigned_to
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
      }
    } catch (err) {
      console.error('Failed to save draft:', err);
    } finally {
      isSaving = false;
    }
  }

  async function handleSubmit() {
    try {
      loading = true;
      error = null;

      // Validate required fields
      if (!formData.title?.trim()) {
        error = 'O título é obrigatório';
        return;
      }

      if (!formData.deadline) {
        error = 'A data limite é obrigatória';
        return;
      }

      // Create the job
      const response = await api.jobs.createJob({
        title: formData.title,
        description: formData.description,
        status: formData.status,
        priority: formData.priority,
        deadline: formData.deadline,
        assigned_to: formData.assigned_to
      });

      if (response.success && response.data) {
        // Mark draft as fulfilled
        if (currentDraftId) {
          await api.drafts.fulfillDraft(currentDraftId, {
            record_type: 'Job',
            record_id: response.data.id
          });
        }

        // Reset form and close modal
        resetForm();
        isOpen = false;
        onSuccess(response.data);
      } else {
        throw new Error(response.message || 'Falha ao criar tarefa');
      }
    } catch (err) {
      error = err instanceof Error ? err.message : 'Ocorreu um erro ao criar a tarefa';
    } finally {
      loading = false;
    }
  }

  async function handleDiscard() {
    if (!currentDraftId) {
      resetForm();
      isOpen = false;
      return;
    }

    if (!confirm('Tem certeza que deseja descartar este rascunho?')) {
      return;
    }

    try {
      await api.drafts.deleteDraft(currentDraftId);
      resetForm();
      isOpen = false;
    } catch (err) {
      error = err instanceof Error ? err.message : 'Falha ao descartar rascunho';
    }
  }

  function resetForm() {
    formData = {
      title: '',
      description: '',
      status: 'pending',
      priority: 'medium',
      deadline: '',
      assigned_to: undefined
    };
    currentDraftId = null;
    sessionId = crypto.randomUUID();
    hasUnsavedChanges = false;
    lastSavedAt = null;
    error = null;
    selectedDraft = null;
  }

  function handleClose() {
    if (hasUnsavedChanges && (formData.title || formData.description)) {
      if (confirm('Você tem alterações não salvas. Deseja salvá-las antes de fechar?')) {
        saveDraft();
      }
    }
    isOpen = false;
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
</script>

{#if isOpen}
  <div class="modal modal-open">
    <div class="modal-box max-w-2xl">
      <div class="flex justify-between items-center mb-4">
        <h3 class="font-bold text-lg">
          {currentDraftId ? 'Continuar Tarefa' : 'Nova Tarefa'}
        </h3>
        <button class="btn btn-sm btn-circle btn-ghost" onclick={handleClose}>✕</button>
      </div>

      <!-- Auto-save indicator -->
      <div class="mb-4 flex items-center gap-2 text-sm">
        {#if isSaving}
          <span class="loading loading-spinner loading-xs"></span>
          <span class="text-base-content/60">Salvando rascunho...</span>
        {:else if lastSavedAt}
          <span class="text-success">✓</span>
          <span class="text-base-content/60">Rascunho salvo {formatLastSaved(lastSavedAt)}</span>
        {:else if hasUnsavedChanges}
          <span class="text-warning">⚠</span>
          <span class="text-base-content/60">Alterações não salvas</span>
        {/if}
      </div>

      {#if error}
        <div class="alert alert-error mb-4">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="stroke-current shrink-0 h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>{error}</span>
        </div>
      {/if}

      <form onsubmit|preventDefault={handleSubmit} class="space-y-4">
        <!-- Title -->
        <div class="form-control">
          <label for="title" class="label">
            <span class="label-text">Título <span class="text-error">*</span></span>
          </label>
          <input
            id="title"
            type="text"
            bind:value={formData.title}
            class="input input-bordered w-full"
            placeholder="Digite o título da tarefa"
            required
            disabled={loading}
          />
        </div>

        <!-- Description -->
        <div class="form-control">
          <label for="description" class="label">
            <span class="label-text">Descrição</span>
          </label>
          <textarea
            id="description"
            bind:value={formData.description}
            class="textarea textarea-bordered h-24"
            placeholder="Digite a descrição da tarefa"
            disabled={loading}
          ></textarea>
        </div>

        <!-- Status and Priority -->
        <div class="grid grid-cols-2 gap-4">
          <div class="form-control">
            <label for="status" class="label">
              <span class="label-text">Status</span>
            </label>
            <select
              id="status"
              bind:value={formData.status}
              class="select select-bordered w-full"
              disabled={loading}
            >
              {#each statusOptions as option}
                <option value={option.value}>{option.label}</option>
              {/each}
            </select>
          </div>

          <div class="form-control">
            <label for="priority" class="label">
              <span class="label-text">Prioridade</span>
            </label>
            <select
              id="priority"
              bind:value={formData.priority}
              class="select select-bordered w-full"
              disabled={loading}
            >
              {#each priorityOptions as option}
                <option value={option.value}>{option.label}</option>
              {/each}
            </select>
          </div>
        </div>

        <!-- Deadline -->
        <div class="form-control">
          <label for="deadline" class="label">
            <span class="label-text">Data Limite <span class="text-error">*</span></span>
          </label>
          <input
            id="deadline"
            type="date"
            bind:value={formData.deadline}
            class="input input-bordered w-full"
            required
            disabled={loading}
          />
        </div>

        <!-- Actions -->
        <div class="modal-action">
          {#if currentDraftId}
            <button
              type="button"
              class="btn btn-error btn-outline"
              onclick={handleDiscard}
              disabled={loading}
            >
              Descartar Rascunho
            </button>
          {/if}
          <button type="button" class="btn" onclick={handleClose} disabled={loading}>
            Cancelar
          </button>
          <button type="submit" class="btn btn-primary" disabled={loading}>
            {#if loading}
              <span class="loading loading-spinner"></span>
              Criando...
            {:else}
              Criar Tarefa
            {/if}
          </button>
        </div>
      </form>
    </div>
    <label class="modal-backdrop" onclick={handleClose}></label>
  </div>
{/if}
