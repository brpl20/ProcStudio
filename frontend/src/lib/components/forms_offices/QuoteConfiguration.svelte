<script lang="ts">
  import type { NumberFieldProps } from '../../types/form-field-contract';

  type Props = {
    quoteValue?: number;
    numberOfQuotes?: number;
    onQuoteValueChange?: (value: number) => void;
    onNumberOfQuotesChange?: (value: number) => void;
    disabled?: boolean;
    errors?: {
      quoteValue?: string | null;
      numberOfQuotes?: string | null;
    };
  };

  let {
    quoteValue = $bindable(0),
    numberOfQuotes = $bindable(0),
    onQuoteValueChange,
    onNumberOfQuotesChange,
    disabled = false,
    errors = {}
  }: Props = $props();

  function handleQuoteValueChange(e: Event) {
    const target = e.target as HTMLInputElement;
    const value = parseFloat(target.value) || 0;
    quoteValue = value;
    onQuoteValueChange?.(value);
  }

  function handleNumberOfQuotesChange(e: Event) {
    const target = e.target as HTMLInputElement;
    const value = parseInt(target.value) || 0;
    numberOfQuotes = value;
    onNumberOfQuotesChange?.(value);
  }

  // Calculate total value
  const totalValue = $derived(quoteValue * numberOfQuotes);

  // Format currency
  function formatCurrency(value: number): string {
    return value.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  }
</script>

<div class="space-y-4">
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
    <!-- Quote Value -->
    <div class="form-control">
      <label class="label" for="quote-value">
        <span class="label-text">Valor da Cota</span>
        <span class="label-text-alt text-error">*</span>
      </label>
      <div class="relative">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">R$</span>
        <input
          id="quote-value"
          type="number"
          class="input input-bordered w-full pl-10"
          class:input-error={errors.quoteValue}
          placeholder="0,00"
          min="0"
          step="0.01"
          bind:value={quoteValue}
          oninput={handleQuoteValueChange}
          {disabled}
        />
      </div>
      {#if errors.quoteValue}
        <label class="label">
          <span class="label-text-alt text-error">{errors.quoteValue}</span>
        </label>
      {:else}
        <label class="label">
          <span class="label-text-alt">Valor individual de cada cota</span>
        </label>
      {/if}
    </div>

    <!-- Number of Quotes -->
    <div class="form-control">
      <label class="label" for="number-of-quotes">
        <span class="label-text">Número de Cotas</span>
        <span class="label-text-alt text-error">*</span>
      </label>
      <input
        id="number-of-quotes"
        type="number"
        class="input input-bordered w-full"
        class:input-error={errors.numberOfQuotes}
        placeholder="0"
        min="1"
        step="1"
        bind:value={numberOfQuotes}
        oninput={handleNumberOfQuotesChange}
        {disabled}
      />
      {#if errors.numberOfQuotes}
        <label class="label">
          <span class="label-text-alt text-error">{errors.numberOfQuotes}</span>
        </label>
      {:else}
        <label class="label">
          <span class="label-text-alt">Total de cotas da sociedade</span>
        </label>
      {/if}
    </div>
  </div>

  <!-- Total Value Display -->
  {#if numberOfQuotes > 0 && quoteValue > 0}
    <div class="alert alert-info">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
      <div>
        <h3 class="font-bold">Capital Social Total</h3>
        <div class="text-xl">{formatCurrency(totalValue)}</div>
        <div class="text-sm mt-1">
          {numberOfQuotes} {numberOfQuotes === 1 ? 'cota' : 'cotas'} de {formatCurrency(quoteValue)} cada
        </div>
      </div>
    </div>
  {/if}
</div>