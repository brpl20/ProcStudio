<script lang="ts">
  import { lawyerStore } from '../../stores/lawyerStore.svelte';
  import type { Lawyer } from '../../api/types/user.lawyer';

  type Props = {
    value?: string;
    availableLawyers?: Lawyer[];
    id?: string;
    labelText?: string;
    required?: boolean;
    disabled?: boolean;
    onchange?: (lawyer: Lawyer | null) => void;
  };

  let {
    value = $bindable(''),
    availableLawyers = [],
    id = 'partner-lawyer',
    labelText = 'Advogado',
    required = false,
    disabled = false,
    onchange
  }: Props = $props();

  function handleChange(e: Event) {
    const target = e.target as HTMLSelectElement;
    const selectedId = target.value;

    if (!selectedId) {
      value = '';
      onchange?.(null);
      return;
    }

    const selectedLawyer = availableLawyers.find((l) => l.id === selectedId);
    if (selectedLawyer) {
      value = selectedId;
      onchange?.(selectedLawyer);
    }
  }

  function getFullName(lawyer: Lawyer) {
    return `${lawyer.attributes.name} ${lawyer.attributes.last_name || ''}`.trim();
  }
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
    onchange={handleChange}
    {disabled}
  >
    <option value="">Selecione o Advogado</option>
    {#each availableLawyers as lawyer}
      <option value={lawyer.id}>
        {getFullName(lawyer)}
      </option>
    {/each}
  </select>
</div>