<script lang="ts">
  export let onAddTask: (title: string) => void;
  export let disabled = false;

  let isAdding = false;
  let taskTitle = '';
  let inputElement: HTMLInputElement;

  function startAdding() {
    if (disabled) {
      return;
    }
    isAdding = true;
    setTimeout(() => inputElement?.focus(), 0);
  }

  function cancelAdding() {
    isAdding = false;
    taskTitle = '';
  }

  function handleSubmit() {
    if (taskTitle.trim()) {
      onAddTask(taskTitle.trim());
      taskTitle = '';
      if (!disabled) {
        setTimeout(() => inputElement?.focus(), 0);
      } else {
        isAdding = false;
      }
    }
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      handleSubmit();
    } else if (event.key === 'Escape') {
      cancelAdding();
    }
  }
</script>

{#if isAdding}
  <div class="card card-compact bg-base-100 border border-base-300 shadow-sm">
    <div class="card-body p-3">
      <textarea
        bind:this={inputElement}
        bind:value={taskTitle}
        on:keydown={handleKeydown}
        on:blur={cancelAdding}
        class="textarea textarea-ghost resize-none p-0 text-sm leading-relaxed min-h-16"
        placeholder="Digite o título da tarefa..."
        rows="2"
        maxlength="200"
      ></textarea>

      <div class="flex items-center justify-between gap-2 mt-2">
        <div class="flex items-center gap-2">
          <button
            class="btn btn-primary btn-sm"
            on:click={handleSubmit}
            disabled={!taskTitle.trim()}
          >
            Adicionar
          </button>
          <button class="btn btn-ghost btn-sm" on:click={cancelAdding}> Cancelar </button>
        </div>

        <div class="text-xs text-base-content/50">
          {taskTitle.length}/200
        </div>
      </div>
    </div>
  </div>
{:else}
  <button
    class="btn btn-ghost btn-sm w-full justify-start gap-2 text-base-content/70 hover:text-base-content hover:bg-base-200"
    class:btn-disabled={disabled}
    on:click={startAdding}
    {disabled}
  >
    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M12 6v6m0 0v6m0-6h6m-6 0H6"
      />
    </svg>
    <span>Adicionar tarefa</span>
  </button>
{/if}

<style>
  .textarea-ghost {
    background: transparent;
    border: none;
    resize: none;
  }

  .textarea-ghost:focus {
    outline: none;
    background: transparent;
  }

  .btn-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
</style>
