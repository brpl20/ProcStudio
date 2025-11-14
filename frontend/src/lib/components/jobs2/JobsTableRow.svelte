<script lang="ts">
  import { type Job } from '../../api';
  import { getJobStatusInfo, getJobPriorityInfo, JOBSTATUS, JOBPRIORITY } from '../../constants/formOptions';
  import { truncateDescription } from '../../utils/text';
  import Icon from '../../icons/icons.svelte';
  import AvatarGroup from '../ui/AvatarGroup.svelte';

  interface Props {
    job: Job;
    isEditing?: boolean;
    onEdit?: (job: Job) => void;
    onStartEdit?: () => void;
    onCancelEdit?: () => void;
    onSaveInline?: (updates: Partial<Job>) => void;
  }

  const {
    job,
    isEditing = false,
    onEdit,
    onStartEdit,
    onCancelEdit,
    onSaveInline
  }: Props = $props();

  interface AvatarUser {
    name: string;
    last_name: string;
    avatar?: string;
  }

  const usersAvatar: AvatarUser[] = [
    { name: 'Maria', last_name: 'Silva', avatar: 'https://i.pravatar.cc/150?img=5' },
    { name: 'João', last_name: 'Souza' },
    { name: 'Carlos', last_name: 'Almeida' },
    { name: 'Fernanda', last_name: 'Rocha', avatar: 'https://i.pravatar.cc/150?img=15' },
    { name: 'Leticia', last_name: 'Campos', avatar: 'https://i.pravatar.cc/150?img=6' },
    { name: 'Lucas', last_name: 'Ferreira' },
    { name: 'Marcos', last_name: 'Lopes' }
  ];

  const priorityInfo = $derived(getJobPriorityInfo(job.priority));

  let localEdits = $state({
    description: job.description || '',
    status: job.status,
    priority: job.priority,
    deadline: job.deadline || '',
    work_number: job.work_number || '',
    customer_id: job.customer_id || ''
  });

  $effect(() => {
    localEdits = {
      description: job.description || '',
      status: job.status,
      priority: job.priority,
      deadline: job.deadline || '',
      work_number: job.work_number || '',
      customer_id: job.customer_id || ''
    };
  });

  function handleClick(e: MouseEvent) {
    if (isEditing) return;

    const target = e.target as HTMLElement;
    if (target.tagName === 'INPUT' || target.tagName === 'SELECT' || target.tagName === 'BUTTON') {
      return;
    }

    if (onEdit) {
      onEdit(job);
    }
  }

  function handleDoubleClick(e: MouseEvent) {
    e.stopPropagation();
    if (onStartEdit) {
      onStartEdit();
    }
  }

  function handleSave() {
    if (onSaveInline) {
      onSaveInline({
        description: localEdits.description,
        status: localEdits.status,
        priority: localEdits.priority,
        deadline: localEdits.deadline || undefined,
        work_number: localEdits.work_number || null,
        customer_id: localEdits.customer_id ? Number(localEdits.customer_id) : null
      });
    }
  }

  function handleCancel() {
    localEdits = {
      description: job.description || '',
      status: job.status,
      priority: job.priority,
      deadline: job.deadline || '',
      work_number: job.work_number || '',
      customer_id: job.customer_id || ''
    };
    if (onCancelEdit) {
      onCancelEdit();
    }
  }

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') {
      handleCancel();
    } else if (e.key === 'Enter' && e.ctrlKey) {
      handleSave();
    }
  }
</script>

<tr
  class="hover cursor-pointer transition-all {isEditing
    ? 'bg-primary/10 ring-2 ring-primary shadow-lg'
    : ''}"
  onclick={handleClick}
  ondblclick={handleDoubleClick}
>
  <td class="py-4 text-sm text-base-content/60 font-medium border-r border-base-200">
    {job.id}
  </td>

  <!-- Descrição -->
  <td class="py-4 min-w-[180px] border-r border-base-200">
    {#if isEditing}
      <input
        type="text"
        class="input input-xs input-bordered input-primary w-full"
        bind:value={localEdits.description}
        onkeydown={handleKeydown}
        placeholder="Descrição da tarefa..."
        autofocus
      />
    {:else if job.description}
      <div class="font-medium tooltip" data-tip="{job.description} (Duplo clique para editar)">
        {truncateDescription(job.description)}
      </div>
    {:else}
      <div class="font-medium text-base-content/60 italic">Duplo clique para adicionar</div>
    {/if}
  </td>

  <!-- Comentários -->
  <td class="py-4 text-center w-12 border-r border-base-200">
    {#if job.latest_comment}
      <div class="tooltip tooltip-left" data-tip={job.latest_comment.content}>
        <div class="flex items-center gap-1 justify-center">
          <Icon name="comment" className="h-4 w-4 sm:h-5 sm:w-5 text-primary" />
          {#if job.comments_count && job.comments_count > 1}
            <span class="badge badge-xs badge-primary">{job.comments_count}</span>
          {/if}
        </div>
      </div>
    {:else}
      <Icon name="comment" className="h-4 w-4 sm:h-5 sm:w-5 text-primary opacity-30" />
    {/if}
  </td>

  <!-- Status -->
  <td class="py-4 min-w-[130px] border-r border-base-200">
    {#if isEditing}
      <select
        class="select select-xs select-bordered select-primary w-full"
        bind:value={localEdits.status}
        onclick={(e) => e.stopPropagation()}
      >
        {#each JOBSTATUS as status}
          <option value={status.value}>{status.label}</option>
        {/each}
      </select>
    {:else}
      <div class="flex flex-col gap-1">
        <div>
          <span class="{getJobStatusInfo(job.status).badgeClass} badge-xs">
            {getJobStatusInfo(job.status).label}
          </span>
        </div>
        <div class="text-[9px] sm:text-xs text-base-content/60 whitespace-nowrap">
          {#if job.deadline}
            {new Date(job.deadline).toLocaleDateString('pt-BR', {
              day: '2-digit',
              month: '2-digit'
            })}
          {:else}
            Sem prazo
          {/if}
        </div>
      </div>
    {/if}
  </td>

  <!-- Prioridade -->
  <td class="py-4 text-center min-w-[100px] border-r border-base-200">
    {#if isEditing}
      <select
        class="select select-xs select-bordered select-primary w-full"
        bind:value={localEdits.priority}
        onclick={(e) => e.stopPropagation()}
      >
        {#each JOBPRIORITY as priority}
          <option value={priority.value}>{priority.label}</option>
        {/each}
      </select>
    {:else}
      <span class="{priorityInfo.badgeClass} badge-xs whitespace-nowrap">
        {priorityInfo.label}
      </span>
    {/if}
  </td>

  <!-- Equipe -->
  <td class="py-4 min-w-[140px] border-r border-base-200">
    <AvatarGroup users={usersAvatar} size="responsive" />
  </td>

  <!-- Trabalho -->
  <td class="py-4 text-sm min-w-[120px] border-r border-base-200">
    {#if isEditing}
      <input
        type="text"
        class="input input-xs input-bordered input-primary w-full"
        bind:value={localEdits.work_number}
        onkeydown={handleKeydown}
        onclick={(e) => e.stopPropagation()}
        placeholder="PROC-001"
      />
    {:else if job.work_number}
      <div class="font-medium truncate max-w-[100px]">{job.work_number}</div>
    {:else}
      <div class="font-medium text-base-content/60">—</div>
    {/if}
  </td>

  <!-- Cliente -->
  <td class="py-4 text-sm min-w-[120px]">
    {#if isEditing}
      <input
        type="text"
        class="input input-xs input-bordered input-primary w-full"
        bind:value={localEdits.customer_id}
        onkeydown={handleKeydown}
        onclick={(e) => e.stopPropagation()}
        placeholder="CLI-001"
      />
    {:else if job.customer_id}
      <div class="font-medium truncate max-w-[100px]">ID: {job.customer_id}</div>
    {:else}
      <div class="font-medium text-base-content/60">—</div>
    {/if}
  </td>

  <!-- Ações (só aparece quando está editando) -->
  {#if isEditing}
    <td class="min-w-[100px]">
      <div class="flex gap-1 justify-center">
        <button class="btn btn-success btn-xs" onclick={handleSave} title="Salvar (Ctrl+Enter)">
          <Icon name="check" className="h-3 w-3" />
        </button>
        <button class="btn btn-error btn-xs" onclick={handleCancel} title="Cancelar (Esc)">
          <Icon name="x" className="h-3 w-3" />
        </button>
      </div>
    </td>
  {/if}
</tr>
