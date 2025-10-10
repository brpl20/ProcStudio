<script lang="ts">
  import Checkbox from '../forms_commons/Checkbox.svelte';

  type Props = {
    checked?: boolean;
    id?: string;
    labelText?: string;
    disabled?: boolean;
  };

  let {
    checked = $bindable(false),
    id = 'create-social-contract',
    labelText = 'Sim, desejo criar um contrato social',
    disabled = false
  }: Props = $props();
</script>

<Checkbox bind:checked {id} {labelText} {disabled} />

{#if checked}
  <div class="alert alert-info mt-4">
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
        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
    <span>Esse comando irá gerar um contrato social.</span>
  </div>
{/if}
