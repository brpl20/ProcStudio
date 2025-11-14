<script lang="ts">
  import { JOBSTATUS, JOBPRIORITY } from '../../constants/formOptions';
  import Icon from '../../icons/icons.svelte';
  import QuillMentionEditor from '../QuillMetionEditor.svelte';
  import { allUserProfiles } from '../../stores/usersCacheStore';

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
  }

  function handleSubmit(e: Event) {
    e.preventDefault();

    if (!newJobData.title.trim()) {
      alert('Título da tarefa é obrigatório');
      return;
    }

    const content = editor?.getContent() || '';

    onCreate({
      ...newJobData,
      description: content
    });

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
