<!-- components/ui/ConfirmDialog.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let show: boolean = false;
  export let title: string = 'Confirmar';
  export let message: string = 'Tem certeza?';
  export let confirmText: string = 'Confirmar';
  export let cancelText: string = 'Cancelar';
  export let type: 'warning' | 'danger' | 'info' = 'warning';

  const dispatch = createEventDispatcher<{
    confirm: void;
    cancel: void;
  }>();

  function confirm(): void {
    dispatch('confirm');
    show = false;
  }

  function cancel(): void {
    dispatch('cancel');
    show = false;
  }
</script>

{#if show}
  <div class="modal modal-open">
    <div class="modal-box">
      <h3 class="font-bold text-lg">{title}</h3>
      <p class="py-4">{message}</p>
      <div class="modal-action">
        <button class="btn btn-ghost" onclick={cancel}>{cancelText}</button>
        <button
          class="btn {type === 'danger'
            ? 'btn-error'
            : type === 'info'
              ? 'btn-info'
              : 'btn-warning'}"
          onclick={confirm}
        >
          {confirmText}
        </button>
      </div>
    </div>
  </div>
{/if}
