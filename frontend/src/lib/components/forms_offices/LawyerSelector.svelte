<script lang="ts">
  import { lawyerStore } from '../../stores/lawyerStore.svelte';
  import type { Lawyer } from '../../api/types/user.lawyer';
  import { onMount } from 'svelte';

  type Props = {
    selectedLawyer?: Lawyer | null;
    onSelect?: (lawyer: Lawyer | null) => void;
    placeholder?: string;
    disabled?: boolean;
  };

  let {
    selectedLawyer = $bindable(null),
    onSelect,
    placeholder = 'Selecione um advogado',
    disabled = false
  }: Props = $props();

  onMount(() => {
    lawyerStore.init();
  });

  function handleSelectChange(event: Event) {
    const select = event.target as HTMLSelectElement;
    const selectedId = select.value;

    if (!selectedId) {
      selectedLawyer = null;
      onSelect?.(null);
      return;
    }

    const lawyer = lawyerStore.availableLawyers.find((l) => l.id === selectedId);
    if (lawyer) {
      lawyerStore.selectLawyer(lawyer);
      selectedLawyer = lawyer;
      onSelect?.(lawyer);

      // Reset selector to placeholder
      select.value = '';
    }
  }

  function handleRemoveLawyer(lawyerId: string) {
    lawyerStore.unselectLawyer(lawyerId);
    if (selectedLawyer?.id === lawyerId) {
      selectedLawyer = null;
      onSelect?.(null);
    }
  }
</script>

<div class="form-control w-full">
  <label class="label" for="lawyer-select">
    <span class="label-text">Advogado</span>
  </label>

  <select
    id="lawyer-select"
    class="select select-bordered w-full"
    class:loading={lawyerStore.loading}
    disabled={disabled || lawyerStore.loading}
    value=""
    onchange={handleSelectChange}
  >
    <option value="">{placeholder}</option>
    {#each lawyerStore.availableLawyers as lawyer (lawyer.id)}
      <option value={lawyer.id}>
        {lawyer.attributes.name} {lawyer.attributes.last_name || ''}
        {#if lawyer.attributes.oab}
          - OAB: {lawyer.attributes.oab}
        {/if}
      </option>
    {/each}
  </select>

  {#if lawyerStore.error}
    <div class="mt-1">
      <span class="text-sm text-error">{lawyerStore.error}</span>
    </div>
  {/if}

  {#if lawyerStore.loading}
    <div class="mt-1">
      <span class="text-sm text-gray-500">Carregando advogados...</span>
    </div>
  {/if}

  {#if lawyerStore.selectedLawyers.length > 0}
    <div class="mt-2 space-y-2">
      <span class="text-sm font-medium">Advogados selecionados:</span>
      {#each lawyerStore.selectedLawyers as selectedLawyer (selectedLawyer.id)}
        <div class="p-2 bg-base-200 rounded flex justify-between items-center">
          <div>
            <span class="text-sm">{selectedLawyer.attributes.name} {selectedLawyer.attributes.last_name || ''}</span>
            {#if selectedLawyer.attributes.oab}
              <span class="text-xs text-gray-500"> - OAB: {selectedLawyer.attributes.oab}</span>
            {/if}
          </div>
          <button
            class="btn btn-sm btn-error btn-outline"
            onclick={() => handleRemoveLawyer(selectedLawyer.id)}
            type="button"
          >
            Remover
          </button>
        </div>
      {/each}
    </div>
  {/if}
</div>