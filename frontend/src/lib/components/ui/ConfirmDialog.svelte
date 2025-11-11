<!-- components/ui/ConfirmDialog.svelte -->
<script lang="ts">
  let {
    show = $bindable(false),
    title = 'Confirmar',
    message = 'Tem certeza?',
    confirmText = 'Confirmar',
    cancelText = 'Cancelar',
    type = 'warning' as 'warning' | 'danger' | 'info',
    onConfirm = () => {},
    onCancel = () => {}
  }: {
    show?: boolean;
    title?: string;
    message?: string;
    confirmText?: string;
    cancelText?: string;
    type?: 'warning' | 'danger' | 'info';
    onConfirm?: () => void;
    onCancel?: () => void;
  } = $props();

  function confirm(): void {
    onConfirm();
    show = false;
  }

  function cancel(): void {
    onCancel();
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
