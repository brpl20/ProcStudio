<script lang="ts">
  import type { Lawyer } from '../../api/types/user.lawyer';
  import { getLawyerDisplayName } from '../../utils/lawyer.utils';

  type Props = {
    selectedLawyers?: Lawyer[];
    availableLawyers?: Lawyer[];
    onSelect?: (lawyer: Lawyer | null) => void;
    onRemove?: (lawyerId: string) => void;
    placeholder?: string;
    disabled?: boolean;
    loading?: boolean;
    error?: string | null;
  };

  let {
    selectedLawyers = $bindable([]),
    availableLawyers = [],
    onSelect,
    onRemove,
    placeholder = 'Selecione um advogado',
    disabled = false,
    loading = false,
    error = null
  }: Props = $props();

  function handleSelectChange(event: Event) {
    const select = event.target as HTMLSelectElement;
    const selectedId = select.value;

    if (!selectedId) {
      onSelect?.(null);
      return;
    }

    const lawyer = availableLawyers.find((l) => l.id === selectedId);
    if (lawyer) {
      onSelect?.(lawyer);
      // Reset selector to placeholder
      select.value = '';
    }
  }

  function handleRemoveLawyer(lawyerId: string) {
    onRemove?.(lawyerId);
  }
</script>

<div class="form-control w-full">
  <label class="label" for="lawyer-select">
    <span class="label-text">Advogado</span>
  </label>

  <select
    id="lawyer-select"
    class="select select-bordered w-full"
    class:loading={loading}
    disabled={disabled || loading}
    value=""
    onchange={handleSelectChange}
  >
    <option value="">{placeholder}</option>
    {#each availableLawyers as lawyer (lawyer.id)}
      <option value={lawyer.id}>
        {getLawyerDisplayName(lawyer, true)}
      </option>
    {/each}
  </select>

  {#if error}
    <div class="mt-1">
      <span class="text-sm text-error">{error}</span>
    </div>
  {/if}

  {#if loading}
    <div class="mt-1">
      <span class="text-sm text-gray-500">Carregando advogados...</span>
    </div>
  {/if}

  {#if selectedLawyers.length > 0}
    <div class="mt-2 space-y-2">
      <span class="text-sm font-medium">Advogados selecionados:</span>
      {#each selectedLawyers as selectedLawyer (selectedLawyer.id)}
        <div class="p-2 bg-base-200 rounded flex justify-between items-center">
          <div>
            <span class="text-sm">{getLawyerDisplayName(selectedLawyer, true)}</span>
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