<script lang="ts">
  import { PARTNERSHIP_TYPES } from '../../constants/formOptions';

  type Props = {
    partnerName: string;
    partnershipType: string;
    value?: number;
    error?: string | null;
    id?: string;
    onchange?: (value: number) => void;
    disabled?: boolean;
  };

  let {
    partnerName,
    partnershipType,
    value = $bindable(0),
    error = null,
    id = 'pro-labore',
    onchange,
    disabled = false
  }: Props = $props();

  function handleInputChange(e: Event) {
    const target = e.target as HTMLInputElement;
    const newValue = parseFloat(target.value) || 0;
    value = newValue;
    onchange?.(newValue);
  }

  const partnershipLabel = PARTNERSHIP_TYPES.find((t) => t.value === partnershipType)?.label || partnershipType;
</script>

<div class="border rounded p-4">
  <div class="flex justify-between items-center mb-2">
    <span class="font-bold">{partnerName}</span>
    <span class="text-sm text-gray-500">{partnershipLabel}</span>
  </div>

  <div class="flex items-center gap-2">
    <span class="w-20">Pro-Labore:</span>
    <span class="text-lg">R$</span>
    <input
      {id}
      type="number"
      class="input input-bordered input-sm w-32"
      class:input-error={error}
      min="0"
      step="0.01"
      bind:value
      oninput={handleInputChange}
      {disabled}
    />
  </div>

  {#if error}
    <div class="text-error text-sm mt-1">⚠️ {error}</div>
  {:else if value === 0}
    <div class="text-success text-sm mt-1">✓ Este sócio não receberá pro-labore</div>
  {:else if value > 0}
    <div class="text-success text-sm mt-1">✓ Valor válido</div>
  {/if}
</div>