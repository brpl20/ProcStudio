<script lang="ts">
  import { type Job, type JobPriority, type JobStatus } from '../../api';
  import { JOBSTATUS, JOBPRIORITY } from '../../constants/formOptions';
  import { truncateDescription } from '../../utils/text';
  import Icon from '../../icons/icons.svelte';
  import QuillMentionEditor from '../QuillMetionEditor.svelte';
  import { allUserProfiles } from '../../stores/usersCacheStore';

  interface Props {
    isOpen: boolean;
    job: Job | null;
    onClose: () => void;
    onSave?: (updatedJob: Partial<Job>) => void;
  }

  let { isOpen = $bindable(), job, onClose, onSave = () => {} }: Props = $props();

  let activeTab = $state('detalhes');
  let commentText = $state('');
  let editor: QuillMentionEditor;

  // Dados editáveis com tipos corretos
  let editData = $state<{
    description: string;
    status: JobStatus;
    priority: JobPriority;
    deadline: string;
    work_number: string;
    customer_id: string | number;
    assignee_ids: (string | number)[];
    supervisor_ids: (string | number)[];
    collaborator_ids: (string | number)[];
  }>({
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

  let userProfiles = $derived($allUserProfiles);

  // Sincroniza dados quando o job muda
  $effect(() => {
    if (job) {
      editData = {
        description: job.description || '',
        status: (job.status || 'pending') as JobStatus,
        priority: (job.priority || 'medium') as JobPriority,
        deadline: job.deadline || '',
        work_number: job.work_number || '',
        customer_id: job.customer_id || '',
        assignee_ids: job.assignee_ids || [],
        supervisor_ids: job.supervisor_ids || [],
        collaborator_ids: job.collaborator_ids || []
      };
    }
  });

  function handleClose() {
    commentText = '';
    activeTab = 'detalhes';
    onClose();
  }

  function handleSave() {
    if (!job) return;

    const content = editor?.getContent() || editData.description;

    const updatedJob: Partial<Job> = {
      description: content,
      status: editData.status,
      priority: editData.priority,
      deadline: editData.deadline || undefined, // ← Mudei de null para undefined
      work_number: editData.work_number || null,
      // Converte customer_id para number (Job espera number | null)
      customer_id: editData.customer_id ? Number(editData.customer_id) : null, // ← Convertendo para number
      // Converte arrays para number[] (Job espera number[])
      assignee_ids: editData.assignee_ids.map((id) => Number(id)), // ← Convertendo array
      supervisor_ids: editData.supervisor_ids.map((id) => Number(id)), // ← Convertendo array
      collaborator_ids: editData.collaborator_ids.map((id) => Number(id)) // ← Convertendo array
    };

    console.log('Saving job:', job.id, updatedJob);
    onSave(updatedJob);

    alert('Job atualizado com sucesso!');
    handleClose();
  }

  function postComment() {
    if (!commentText.trim() || !job) return;

    console.log('Posting comment to job', job.id, ':', commentText);

    commentText = '';
    alert('Comentário adicionado com sucesso!');
  }

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

  function getJobTitle(job: Job | null): string {
    if (!job) return 'Tarefa';
    if (job.description) return truncateDescription(job.description);
    if (job.work_number) return `Trabalho ${job.work_number}`;
    return `Tarefa #${job.id}`;
  }

  // Helpers para conversão de IDs
  function removeFromArray(arr: (string | number)[], value: string | number): (string | number)[] {
    return arr.filter((id) => String(id) !== String(value));
  }
</script>

<div class="drawer drawer-end z-50">
  <input id="edit-job-drawer" type="checkbox" class="drawer-toggle" bind:checked={isOpen} />

  <div class="drawer-side">
    <label for="edit-job-drawer" aria-label="close sidebar" class="drawer-overlay"></label>

    <div class="menu bg-base-100 text-base-content min-h-full w-full md:w-[600px] p-0">
      <div class="flex items-center justify-between p-4 border-b sticky top-0 bg-base-100 z-10">
        <div class="flex-1 min-w-0 mr-2">
          <h3 class="text-lg font-semibold truncate">
            {getJobTitle(job)}
          </h3>
          <p class="text-sm text-base-content/60">#{job?.id}</p>
        </div>
        <div class="flex gap-2">
          <button class="btn btn-sm btn-primary" onclick={handleSave}>
            <Icon name="check" className="h-4 w-4" />
            Salvar
          </button>
          <button class="btn btn-sm btn-ghost btn-circle" onclick={handleClose}>
            <Icon name="x" className="h-5 w-5" />
          </button>
        </div>
      </div>

      <!-- Tabs -->
      <div class="tabs tabs-boxed w-full sticky top-[73px] bg-base-100 z-10">
        <button
          class="tab flex-1 {activeTab === 'detalhes' ? 'tab-active' : ''}"
          onclick={() => (activeTab = 'detalhes')}
        >
          Detalhes
        </button>
        <button
          class="tab flex-1 {activeTab === 'comentarios' ? 'tab-active' : ''}"
          onclick={() => (activeTab = 'comentarios')}
        >
          Comentários
        </button>
        <button
          class="tab flex-1 {activeTab === 'arquivos' ? 'tab-active' : ''}"
          onclick={() => activeTab === 'arquivos'}
        >
          Arquivos
        </button>
      </div>

      <div class="flex-1 overflow-y-auto p-4">
        {#if activeTab === 'detalhes'}
          <div class="space-y-4">
            <!-- Status e Prioridade -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="label">
                  <span class="label-text">Status</span>
                </label>
                <select class="select select-bordered w-full" bind:value={editData.status}>
                  {#each JOBSTATUS as status}
                    <option value={status.value}>{status.label}</option>
                  {/each}
                </select>
              </div>

              <div>
                <label class="label">
                  <span class="label-text">Prioridade</span>
                </label>
                <select class="select select-bordered w-full" bind:value={editData.priority}>
                  {#each JOBPRIORITY as priority}
                    <option value={priority.value}>{priority.label}</option>
                  {/each}
                </select>
              </div>
            </div>

            <!-- Prazo -->
            <div>
              <label class="label">
                <span class="label-text">Prazo</span>
              </label>
              <input
                type="date"
                class="input input-bordered w-full"
                bind:value={editData.deadline}
              />
              {#if editData.deadline}
                <div class="text-xs mt-1 {getDeadlineStatus(editData.deadline).class}">
                  {new Date(editData.deadline).toLocaleDateString('pt-BR')}
                </div>
              {/if}
            </div>

            <!-- Trabalho -->
            <div>
              <label class="label">
                <span class="label-text">Número do Trabalho</span>
                <span class="label-text-alt text-xs">Temporário até API estar pronta</span>
              </label>
              <input
                type="text"
                class="input input-bordered w-full"
                bind:value={editData.work_number}
                placeholder="Ex: PROC-2024-001"
              />
            </div>

            <!-- Cliente -->
            <div>
              <label class="label">
                <span class="label-text">ID do Cliente</span>
                <span class="label-text-alt text-xs">Temporário até API estar pronta</span>
              </label>
              <input
                type="text"
                class="input input-bordered w-full"
                bind:value={editData.customer_id}
                placeholder="Ex: CLI-001"
              />
            </div>

            <!-- Descrição/Instruções -->
            <div>
              <label class="label">
                <span class="label-text">Descrição da Tarefa</span>
              </label>
              <QuillMentionEditor
                bind:this={editor}
                content={editData.description}
                placeholder="Escreva a descrição da tarefa..."
                minHeight="200px"
              />
            </div>

            <div class="divider">Equipe</div>

            <!-- Responsáveis -->
            <div>
              <label class="label">
                <span class="label-text font-medium">Responsáveis</span>
                <span class="label-text-alt text-xs">Usuários que executarão a tarefa</span>
              </label>
              <select
                class="select select-bordered w-full"
                multiple
                size="4"
                bind:value={editData.assignee_ids}
              >
                {#each userProfiles as user}
                  <option value={user.id}>
                    {user.attributes?.name}
                    {user.attributes?.last_name}
                    {#if user.attributes?.access_email}
                      ({user.attributes.access_email})
                    {/if}
                  </option>
                {/each}
              </select>
              <div class="text-xs text-base-content/60 mt-1">
                Segure Ctrl/Cmd para selecionar múltiplos usuários
              </div>
              {#if editData.assignee_ids.length > 0}
                <div class="flex flex-wrap gap-2 mt-2">
                  {#each editData.assignee_ids as userId}
                    {@const user = userProfiles.find((u) => String(u.id) === String(userId))}
                    {#if user}
                      <div class="badge badge-primary gap-2">
                        {user.attributes?.name}
                        {user.attributes?.last_name}
                        <button
                          class="btn btn-ghost btn-xs btn-circle"
                          onclick={() =>
                            (editData.assignee_ids = removeFromArray(
                              editData.assignee_ids,
                              userId
                            ))}
                        >
                          <Icon name="x" className="h-3 w-3" />
                        </button>
                      </div>
                    {/if}
                  {/each}
                </div>
              {/if}
            </div>

            <!-- Supervisores -->
            <div>
              <label class="label">
                <span class="label-text font-medium">Supervisores</span>
                <span class="label-text-alt text-xs">Usuários que supervisionarão a tarefa</span>
              </label>
              <select
                class="select select-bordered w-full"
                multiple
                size="4"
                bind:value={editData.supervisor_ids}
              >
                {#each userProfiles as user}
                  <option value={user.id}>
                    {user.attributes?.name}
                    {user.attributes?.last_name}
                    {#if user.attributes?.access_email}
                      ({user.attributes.access_email})
                    {/if}
                  </option>
                {/each}
              </select>
              <div class="text-xs text-base-content/60 mt-1">
                Segure Ctrl/Cmd para selecionar múltiplos usuários
              </div>
              {#if editData.supervisor_ids.length > 0}
                <div class="flex flex-wrap gap-2 mt-2">
                  {#each editData.supervisor_ids as userId}
                    {@const user = userProfiles.find((u) => String(u.id) === String(userId))}
                    {#if user}
                      <div class="badge badge-secondary gap-2">
                        {user.attributes?.name}
                        {user.attributes?.last_name}
                        <button
                          class="btn btn-ghost btn-xs btn-circle"
                          onclick={() =>
                            (editData.supervisor_ids = removeFromArray(
                              editData.supervisor_ids,
                              userId
                            ))}
                        >
                          <Icon name="x" className="h-3 w-3" />
                        </button>
                      </div>
                    {/if}
                  {/each}
                </div>
              {/if}
            </div>

            <!-- Colaboradores -->
            <div>
              <label class="label">
                <span class="label-text font-medium">Colaboradores</span>
                <span class="label-text-alt text-xs">Usuários que colaborarão na tarefa</span>
              </label>
              <select
                class="select select-bordered w-full"
                multiple
                size="4"
                bind:value={editData.collaborator_ids}
              >
                {#each userProfiles as user}
                  <option value={user.id}>
                    {user.attributes?.name}
                    {user.attributes?.last_name}
                    {#if user.attributes?.access_email}
                      ({user.attributes.access_email})
                    {/if}
                  </option>
                {/each}
              </select>
              <div class="text-xs text-base-content/60 mt-1">
                Segure Ctrl/Cmd para selecionar múltiplos usuários
              </div>
              {#if editData.collaborator_ids.length > 0}
                <div class="flex flex-wrap gap-2 mt-2">
                  {#each editData.collaborator_ids as userId}
                    {@const user = userProfiles.find((u) => String(u.id) === String(userId))}
                    {#if user}
                      <div class="badge badge-accent gap-2">
                        {user.attributes?.name}
                        {user.attributes?.last_name}
                        <button
                          class="btn btn-ghost btn-xs btn-circle"
                          onclick={() =>
                            (editData.collaborator_ids = removeFromArray(
                              editData.collaborator_ids,
                              userId
                            ))}
                        >
                          <Icon name="x" className="h-3 w-3" />
                        </button>
                      </div>
                    {/if}
                  {/each}
                </div>
              {/if}
            </div>
          </div>
        {:else if activeTab === 'comentarios'}
          <div class="space-y-4">
            <!-- Comentários existentes -->
            <div class="space-y-3 max-h-96 overflow-y-auto">
              {#if job?.latest_comment}
                <div class="bg-base-200 p-3 rounded-lg">
                  <div class="flex items-start gap-3">
                    <div
                      class="w-8 h-8 bg-primary text-primary-content rounded-full flex items-center justify-center text-sm font-semibold flex-shrink-0"
                    >
                      {job.latest_comment.author?.name?.[0]?.toUpperCase() || 'U'}
                    </div>
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2 mb-1">
                        <span class="font-medium text-sm truncate">
                          {job.latest_comment.author?.name || 'Usuário'}
                        </span>
                        <span class="text-xs text-base-content/60">há 2 horas</span>
                      </div>
                      <p class="text-sm break-words">{job.latest_comment.content}</p>
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

            <!-- Adicionar comentário -->
            <div class="border-t pt-4">
              <div class="flex gap-3">
                <div
                  class="w-8 h-8 bg-secondary text-secondary-content rounded-full flex items-center justify-center text-sm font-semibold flex-shrink-0"
                >
                  U
                </div>
                <div class="flex-1 min-w-0">
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
        {:else if activeTab === 'arquivos'}
          <div class="flex items-center justify-center text-center text-base-content/60 py-12">
            <div>
              <Icon name="folder" className="h-16 w-16 mx-auto mb-3 opacity-50" />
              <p class="text-lg font-medium">Arquivos da tarefa #{job?.id}</p>
              <p class="text-sm mt-2">Funcionalidade em desenvolvimento</p>
            </div>
          </div>
        {/if}
      </div>
    </div>
  </div>
</div>
