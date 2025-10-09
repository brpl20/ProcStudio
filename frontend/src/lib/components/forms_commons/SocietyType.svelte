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

  // Check if single lawyer - based on total active lawyers in system, not available for selection
  const isSingleLawyer = $derived(lawyerStore.activeLawyers.length === 1);

  // Auto-set to individual if single lawyer
  $effect(() => {
    if (isSingleLawyer && !value) {
      value = 'individual';
    }
  });

  // Filter society options based on lawyer count
  const availableOptions = $derived(
    isSingleLawyer 
      ? SOCIETY_OPTIONS.filter(option => option.value === 'individual')
      : SOCIETY_OPTIONS
  );
</script>

<div class="form-control flex flex-col">
  <label class="label pb-1" for={id}>
    <span class="label-text">
      {labelText}
      {#if isSingleLawyer}
        <div class="tooltip tooltip-info tooltip-right ml-1" data-tip="Cadastre mais advogados para liberar os outros tipos societários">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="inline w-4 h-4 text-info cursor-help"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
        </div>
      {/if}
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
    {#each availableOptions as option}
      <option value={option.value}>{option.label}</option>
    {/each}
  </select>
</div>