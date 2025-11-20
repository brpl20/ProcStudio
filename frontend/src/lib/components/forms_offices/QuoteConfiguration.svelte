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

  const totalValue = $derived(quoteValue * numberOfQuotes);

  function formatCurrency(value: number): string {
    return value.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    });
  }
</script>

<div class="space-y-6">
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
    <div>
      <label class="block text-sm font-semibold mb-2" for="quote-value">
        Valor da Cota
        <span class="text-red-500">*</span>
      </label>
      <div class="relative">
        <span class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500 font-medium">R$</span>
        <input
          id="quote-value"
          type="number"
          class="w-full pl-12 pr-4 py-2.5 border-2 rounded-lg font-medium transition-all duration-200 focus:outline-none placeholder-gray-400"
          class:border-red-300={errors.quoteValue}
          class:bg-red-50={errors.quoteValue}
          class:border-gray-300={!errors.quoteValue}
          class:focus:border-[#0277EE]={!errors.quoteValue}
          class:focus:ring-2={!errors.quoteValue}
          class:focus:ring-[#0277EE]={!errors.quoteValue}
          class:focus:ring-opacity-10={!errors.quoteValue}
          class:focus:border-red-500={errors.quoteValue}
          placeholder="0,00"
          min="0"
          step="0.01"
          bind:value={quoteValue}
          oninput={handleQuoteValueChange}
          {disabled}
        />
      </div>
      <div class="mt-2 text-xs">
        {#if errors.quoteValue}
          <p class="text-red-600 font-medium flex items-center gap-1">
            <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18.101 12.93a1 1 0 00-1.01-1.986c-.563.097-1.141.179-1.728.254 1.118-1.595 1.948-3.529 1.948-5.68 0-5.207-4.411-9.426-9.85-9.426S-.948 1.274-.948 6.481c0 2.151.83 4.085 1.948 5.68-.587-.075-1.165-.157-1.728-.254a1 1 0 11.202-1.982c.564.097 1.135.178 1.707.251 1.9 1.612 4.472 2.583 7.323 2.583s5.424-.97 7.323-2.583c.572-.073 1.143-.154 1.707-.251a1 1 0 01.99 1.836l-.672.11c-.248 2.157-1.681 4.066-3.705 5.267.237.196.454.41.65.644 2.212-1.419 3.842-3.645 4.28-6.233z" clip-rule="evenodd"/>
            </svg>
            {errors.quoteValue}
          </p>
        {:else}
          <p class="text-gray-600">Valor individual de cada cota</p>
        {/if}
      </div>
    </div>

    <!-- Number of Quotes -->
    <div>
      <label class="block text-sm font-semibold text-[#01013D] mb-2" for="number-of-quotes">
        Número de Cotas
        <span class="text-red-500">*</span>
      </label>
      <input
        id="number-of-quotes"
        type="number"
        class="w-full px-4 py-2.5 border-2 rounded-lg font-medium transition-all duration-200 focus:outline-none placeholder-gray-400"
        class:border-red-300={errors.numberOfQuotes}
        class:bg-red-50={errors.numberOfQuotes}
        class:border-gray-300={!errors.numberOfQuotes}
        class:focus:border-[#0277EE]={!errors.numberOfQuotes}
        class:focus:ring-2={!errors.numberOfQuotes}
        class:focus:ring-[#0277EE]={!errors.numberOfQuotes}
        class:focus:ring-opacity-10={!errors.numberOfQuotes}
        class:focus:border-red-500={errors.numberOfQuotes}
        placeholder="0"
        min="1"
        step="1"
        bind:value={numberOfQuotes}
        oninput={handleNumberOfQuotesChange}
        {disabled}
      />
      <div class="mt-2 text-xs">
        {#if errors.numberOfQuotes}
          <p class="text-red-600 font-medium flex items-center gap-1">
            <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18.101 12.93a1 1 0 00-1.01-1.986c-.563.097-1.141.179-1.728.254 1.118-1.595 1.948-3.529 1.948-5.68 0-5.207-4.411-9.426-9.85-9.426S-.948 1.274-.948 6.481c0 2.151.83 4.085 1.948 5.68-.587-.075-1.165-.157-1.728-.254a1 1 0 11.202-1.982c.564.097 1.135.178 1.707.251 1.9 1.612 4.472 2.583 7.323 2.583s5.424-.97 7.323-2.583c.572-.073 1.143-.154 1.707-.251a1 1 0 01.99 1.836l-.672.11c-.248 2.157-1.681 4.066-3.705 5.267.237.196.454.41.65.644 2.212-1.419 3.842-3.645 4.28-6.233z" clip-rule="evenodd"/>
            </svg>
            {errors.numberOfQuotes}
          </p>
        {:else}
          <p class="text-gray-600">Total de cotas da sociedade</p>
        {/if}
      </div>
    </div>
  </div>

  <!-- Total Value Display -->
  {#if numberOfQuotes > 0 && quoteValue > 0}
    <div class="bg-blue-50 border-l-4 border-[#0277EE] rounded-r-lg p-5 shadow-sm">
      <div class="flex items-start gap-4">
        <div class="flex-shrink-0 pt-0.5">
          <svg class="w-6 h-6 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
        </div>
        <div class="flex-1 min-w-0">
          <h3 class="text-sm font-semibold text-[#01013D] mb-2">Capital Social Total</h3>
          <div class="text-2xl font-bold text-[#0277EE]">{formatCurrency(totalValue)}</div>
          <p class="text-sm text-gray-600 mt-2">
            {numberOfQuotes} {numberOfQuotes === 1 ? 'cota' : 'cotas'} de <span class="font-medium text-gray-700">{formatCurrency(quoteValue)}</span> cada
          </p>
        </div>
      </div>
    </div>
  {/if}
</div>
