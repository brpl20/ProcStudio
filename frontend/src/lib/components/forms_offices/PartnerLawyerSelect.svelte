<script lang="ts">
  import type { Lawyer } from '../../api/types/user.lawyer';
  import { getFullName } from '../../utils/lawyer.utils';

  type Props = {
    value?: string;
    allLawyers?: Lawyer[];
    selectedByOthers?: string[]; // IDs already selected by other partners
    id?: string;
    labelText?: string;
    required?: boolean;
    disabled?: boolean;
    onchange?: (lawyer: Lawyer | null) => void;
  };

  let {
    value = $bindable(''),
    allLawyers = [],
    selectedByOthers = [],
    id = 'partner-lawyer',
    labelText = 'Advogado',
    required = false,
    disabled = false,
    onchange
  }: Props = $props();

  const isSelected = $derived(!!value);
  // Find lawyer by UserProfile ID (backward compatibility)
  const selectedLawyer = $derived(allLawyers.find((l) => l.id === value));

  // Show ALL lawyers in dropdown, but mark which ones are selected by others
  // Don't filter out the current selection
  const dropdownLawyers = $derived(allLawyers);

  // Debug
  $effect(() => {
    console.log(`🟣 [PartnerLawyerSelect ${id}] value:`, value);
    console.log(`🟣 [PartnerLawyerSelect ${id}] selectedLawyer:`, selectedLawyer?.attributes.name || 'none');
    console.log(`🟣 [PartnerLawyerSelect ${id}] selectedByOthers:`, selectedByOthers);
    console.log(`🟣 [PartnerLawyerSelect ${id}] allLawyers.length:`, allLawyers.length);
  });

  function handleChange(e: Event) {
    const target = e.target as HTMLSelectElement;
    const selectedId = target.value;
    console.log(`🟣 [PartnerLawyerSelect ${id}] handleChange - selectedId:`, selectedId);

    if (!selectedId) {
      value = '';
      onchange?.(null);
      return;
    }

    const lawyer = allLawyers.find((l) => l.id === selectedId);
    if (lawyer) {
      value = selectedId;
      onchange?.(lawyer);
    }
  }
</script>

<div class="form-control flex flex-col">
  <label class="label pb-1" for={id}>
    <span class="label-text">
      {labelText}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>

  <!-- Debug info -->
  <div class="text-xs bg-purple-100 p-1 rounded mb-1">
    Value: {value || 'empty'} | Selected: {selectedLawyer?.attributes.name || 'none'} | All: {allLawyers.length} | Blocked: [{selectedByOthers.join(', ')}]
  </div>

  <select
    {id}
    class="select select-bordered w-full"
    value={value || ''}
    onchange={handleChange}
    {disabled}
  >
    <option value="">Selecione o Advogado</option>
    {#each dropdownLawyers as lawyer}
      {@const isCurrentSelection = lawyer.id === value}
      {@const isSelectedByOther = selectedByOthers.includes(lawyer.id)}
      <option
        value={lawyer.id}
        selected={isCurrentSelection}
        disabled={isSelectedByOther && !isCurrentSelection}
      >
        {getFullName(lawyer)}{isCurrentSelection ? ' ✓' : ''}{isSelectedByOther && !isCurrentSelection ? ' (já selecionado)' : ''}
      </option>
    {/each}
  </select>

  {#if value && selectedByOthers.includes(value)}
    <div class="text-warning text-sm mt-1">
      ⚠️ Este advogado já foi selecionado em outro campo
    </div>
  {/if}
</div>