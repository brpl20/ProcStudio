<script lang="ts">
  import { getCurrentInssConstants } from '../../constants/formOptions';
  import { validateProLaboreAmount } from '../../validation';

  type Props = {
    lawyerName: string;
    value?: number;
    error?: string | null;
    onchange?: (value: number) => void;
    disabled?: boolean;
  };

  let {
    lawyerName,
    value = $bindable(0),
    error = null,
    onchange,
    disabled = false
  }: Props = $props();

  const { minimumWage, inssCeiling } = getCurrentInssConstants();

  function handleInputChange(e: Event) {
    const target = e.target as HTMLInputElement;
    const newValue = parseFloat(target.value) || 0;
    value = newValue;
    error = validateProLaboreAmount(newValue);
    onchange?.(newValue);
  }

  function handleSliderChange(e: Event) {
    const target = e.target as HTMLInputElement;
    const newValue = parseFloat(target.value);
    value = newValue;
    error = validateProLaboreAmount(newValue);
    onchange?.(newValue);
  }
</script>

<div class="space-y-4">
  <div class="alert alert-info">
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
    <div class="text-sm">
      O Sócio único deverá receber um pro-labore ajustado de acordo com o salário mínimo.
      Valor R$ 0,00 significa que o sócio não receberá pro-labore.
    </div>
  </div>

  <div class="border rounded-lg p-4 bg-base-200">
    <div class="flex justify-between items-center mb-4">
      <span class="font-bold">{lawyerName}</span>
      <span class="text-sm text-gray-500">Sócio Único</span>
    </div>

    <div class="space-y-3">
      <div class="flex items-center gap-2">
        <span class="w-20 text-sm">Pro-Labore:</span>
        <span class="text-lg">R$</span>
        <input
          type="number"
          class="input input-bordered input-sm w-40"
          class:input-error={error}
          min="0"
          step="0.01"
          bind:value
          oninput={handleInputChange}
          {disabled}
        />
      </div>

      <div class="space-y-2">
        <label class="text-sm text-gray-600">Ajuste rápido:</label>
        <input
          type="range"
          class="range range-primary"
          min={minimumWage}
          max={inssCeiling}
          step="100"
          bind:value
          oninput={handleSliderChange}
          {disabled}
        />
        <div class="flex justify-between text-xs text-gray-500">
          <span>R$ {minimumWage.toLocaleString('pt-BR')}</span>
          <span>R$ {inssCeiling.toLocaleString('pt-BR')}</span>
        </div>
      </div>

      {#if error}
        <div class="text-error text-sm">⚠️ {error}</div>
      {:else if value === 0}
        <div class="text-success text-sm">✓ Este sócio não receberá pro-labore</div>
      {:else if value >= minimumWage && value <= inssCeiling}
        <div class="text-success text-sm">✓ Valor válido dentro das faixas do INSS</div>
      {:else if value > inssCeiling}
        <div class="text-warning text-sm">⚠️ Valor acima do teto do INSS</div>
      {/if}
    </div>
  </div>
</div>