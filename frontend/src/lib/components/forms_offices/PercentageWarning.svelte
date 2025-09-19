<script lang="ts">
  type Props = {
    totalPercentage: number;
    showWarning: boolean;
  };

  let {
    totalPercentage = $bindable(0),
    showWarning = $bindable(false)
  }: Props = $props();
</script>

{#if showWarning}
  <div class="alert alert-warning">
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
        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"
      />
    </svg>
    <span>
      O total de participação ({totalPercentage}%) excede 100%. Ajuste as
      porcentagens para que somem no máximo 100%.
    </span>
  </div>
{/if}