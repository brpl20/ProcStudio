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
    tip?: string;
  };

  let {
    partnerName,
    partnershipType,
    value = $bindable(0),
    error = null,
    id = 'pro-labore',
    onchange,
    disabled = false,
    tip = undefined
  }: Props = $props();

  function handleInputChange(e: Event) {
    const target = e.target as HTMLInputElement;
    const newValue = parseFloat(target.value) || 0;
    value = newValue;
    onchange?.(newValue);
  }

  function formatCurrency(val: number): string {
    return val.toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
  }

  const partnershipLabel = PARTNERSHIP_TYPES.find((t) => t.value === partnershipType)?.label || partnershipType;
</script>

<div class="border rounded p-4">
  <div class="flex justify-between items-center mb-2">
    <span class="font-bold">{partnerName}</span>
    <span class="text-sm text-gray-500">{partnershipLabel}</span>
  </div>

  <div class="space-y-2">
    <div class="flex items-center gap-2">
      <span class="w-24 text-sm font-medium">Pro-Labore:</span>
      <div class="flex items-center gap-2">
        <span class="text-lg">R$</span>
        <input
          {id}
          type="number"
          class="input input-bordered input-sm w-40"
          class:input-error={error}
          min="0"
          step="0.01"
          value={value || 0}
          oninput={handleInputChange}
          {disabled}
        />
        {#if value > 0}
          <span class="text-sm font-semibold text-primary">
            = R$ {formatCurrency(value)}
          </span>
        {/if}
      </div>
    </div>
  </div>

  {#if tip}
    <div class="alert alert-info mt-2">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="stroke-current shrink-0 h-4 w-4"
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
      <span class="text-sm">{tip}</span>
    </div>
  {/if}

  <div class="mt-2">
    {#if error}
      <div class="text-error text-sm">⚠️ {error}</div>
    {:else if value === 0 || !value}
      <div class="text-info text-sm">ℹ️ Este sócio não receberá pro-labore</div>
    {:else if value > 0}
      <div class="text-success text-sm">
        ✓ Pro-labore mensal: R$ {formatCurrency(value)}
      </div>
    {/if}
  </div>
</div>