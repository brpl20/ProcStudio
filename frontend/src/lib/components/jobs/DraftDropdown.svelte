<script lang="ts">
  import { onMount } from 'svelte';
  import api, { type Draft } from '../../api';

  // Props
  let {
    isOpen = $bindable(false),
    onSelectDraft = (draft: Draft) => {},
    onCreateNew = () => {}
  }: {
    isOpen?: boolean;
    onSelectDraft?: (draft: Draft) => void;
    onCreateNew?: () => void;
  } = $props();

  let drafts = $state<Draft[]>([]);
  let loading = $state(false);
  let error = $state<string | null>(null);

  // Load drafts when dropdown opens
  $effect(() => {
    if (isOpen) {
      loadDrafts();
    }
  });

  async function loadDrafts() {
    try {
      loading = true;
      error = null;

      const response = await api.drafts.getJobCreationDrafts();

      if (response.success) {
        drafts = response.data;
      } else {
        throw new Error(response.message || 'Failed to load drafts');
      }
    } catch (err) {
      error = err instanceof Error ? err.message : 'An error occurred loading drafts';
      drafts = [];
    } finally {
      loading = false;
    }
  }

  function handleSelectDraft(draft: Draft) {
    onSelectDraft(draft);
    isOpen = false;
  }

  function handleCreateNew() {
    onCreateNew();
    isOpen = false;
  }

  function formatDate(dateString: string): string {
    const date = new Date(dateString);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(hours / 24);

    if (hours < 1) {
      const minutes = Math.floor(diff / (1000 * 60));
      return `há ${minutes} minuto${minutes !== 1 ? 's' : ''}`;
    }

    if (hours < 24) {
      return `há ${hours} hora${hours !== 1 ? 's' : ''}`;
    }

    if (days < 7) {
      return `há ${days} dia${days !== 1 ? 's' : ''}`;
    }

    return date.toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  }

  function getDraftPreview(draft: Draft): string {
    const data = draft.data;
    if (data.title) {
      return data.title;
    }
    if (data.description) {
      return data.description.substring(0, 50) + (data.description.length > 50 ? '...' : '');
    }
    return 'Rascunho sem título';
  }

  function getDraftDetails(draft: Draft): string {
    const details: string[] = [];

    if (draft.data.priority) {
      const priorityMap: Record<string, string> = {
        low: 'Prioridade Baixa',
        medium: 'Prioridade Média',
        high: 'Prioridade Alta',
        urgent: 'Urgente'
      };
      details.push(priorityMap[draft.data.priority] || draft.data.priority);
    }

    if (draft.data.deadline) {
      const deadline = new Date(draft.data.deadline);
      details.push(`Prazo: ${deadline.toLocaleDateString('pt-BR')}`);
    }

    return details.join(' • ');
  }

  async function handleDeleteDraft(draft: Draft, event: Event) {
    event.stopPropagation();

    if (!confirm('Tem certeza que deseja excluir este rascunho?')) {
      return;
    }

    try {
      await api.drafts.deleteDraft(draft.id);
      drafts = drafts.filter((d) => d.id !== draft.id);
    } catch (err) {
      error = err instanceof Error ? err.message : 'Falha ao excluir rascunho';
    }
  }
</script>

{#if isOpen}
  <div class="dropdown dropdown-open dropdown-end">
    <div class="dropdown-content z-[1] menu p-2 shadow-lg bg-base-100 rounded-box w-96 max-h-96 overflow-y-auto border border-base-300">
      <div class="px-4 py-3 border-b border-base-300">
        <h3 class="font-semibold text-lg">Criar Nova Tarefa</h3>
        <p class="text-sm text-base-content/60">Selecione um rascunho ou crie uma nova tarefa</p>
      </div>

      <!-- Create New Button -->
      <button
        class="btn btn-primary btn-sm mx-2 my-2"
        onclick={handleCreateNew}
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-5 w-5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 4v16m8-8H4"
          />
        </svg>
        Criar Nova Tarefa
      </button>

      {#if loading}
        <div class="flex justify-center items-center py-8">
          <span class="loading loading-spinner loading-md"></span>
        </div>
      {:else if error}
        <div class="alert alert-error mx-2 my-2">
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
      {:else if drafts.length > 0}
        <div class="divider my-0 px-4 text-xs text-base-content/60">
          Rascunhos Salvos ({drafts.length})
        </div>
        <ul class="space-y-1">
          {#each drafts as draft}
            <li>
              <button
                class="w-full text-left p-3 hover:bg-base-200 rounded-lg transition-colors flex items-start gap-3 relative group"
                onclick={() => handleSelectDraft(draft)}
              >
                <div class="flex-shrink-0 mt-1">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-5 w-5 text-warning"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                    />
                  </svg>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="font-medium text-sm truncate">{getDraftPreview(draft)}</div>
                  {#if getDraftDetails(draft)}
                    <div class="text-xs text-base-content/60 mt-0.5">
                      {getDraftDetails(draft)}
                    </div>
                  {/if}
                  <div class="text-xs text-base-content/50 mt-1">
                    Atualizado {formatDate(draft.updated_at)}
                  </div>
                </div>
                <button
                  class="btn btn-ghost btn-xs btn-circle opacity-0 group-hover:opacity-100 transition-opacity"
                  onclick={(e) => handleDeleteDraft(draft, e)}
                  title="Excluir rascunho"
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M6 18L18 6M6 6l12 12"
                    />
                  </svg>
                </button>
              </button>
            </li>
          {/each}
        </ul>
      {:else}
        <div class="px-4 py-6 text-center text-base-content/60">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-12 w-12 mx-auto mb-2 opacity-50"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
            />
          </svg>
          <p class="text-sm">Nenhum rascunho salvo</p>
        </div>
      {/if}
    </div>
  </div>
{/if}
