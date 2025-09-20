<script lang="ts">
  import { SOCIETY_OPTIONS } from '../../constants/formOptions';
  import { lawyerStore } from '../../stores/lawyerStore.svelte';

  type Props = {
    value?: string;
    id?: string;
    labelText?: string;
    required?: boolean;
    disabled?: boolean;
  };

  let {
    value = $bindable(''),
    id = 'office-society',
    labelText = 'Tipo de Sociedade',
    required = false,
    disabled = false
  }: Props = $props();

  // Initialize store
  $effect(() => {
    lawyerStore.init();
  });

  // Check if single lawyer
  const isSingleLawyer = $derived(lawyerStore.availableLawyers.length === 1);

  // Auto-set to individual if single lawyer
  $effect(() => {
    if (isSingleLawyer && !value) {
      value = 'individual';
    }
  });
</script>

<div class="form-control flex flex-col">
  <label class="label pb-1" for={id}>
    <span class="label-text">
      {labelText}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>
  <select
    {id}
    class="select select-bordered w-full"
    bind:value
    disabled={disabled || isSingleLawyer}
  >
    <option value="">Selecione...</option>
    {#each SOCIETY_OPTIONS as option}
      <option value={option.value}>{option.label}</option>
    {/each}
  </select>
  
  {#if isSingleLawyer}
    <div class="alert alert-info mt-2">
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
      <span class="text-sm">
        Cadastre mais advogados para liberar os outros tipos societários
      </span>
    </div>
  {/if}
</div>