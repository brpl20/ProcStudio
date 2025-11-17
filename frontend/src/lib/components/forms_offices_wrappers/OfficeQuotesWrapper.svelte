<script lang="ts">
  import OfficeProportionality from '../forms_offices/OfficeProportionality.svelte';
  import QuoteConfiguration from '../forms_offices/QuoteConfiguration.svelte';

  type Props = {
    proportional?: boolean;
    quoteValue?: number;
    numberOfQuotes?: number;
    onProportionalChange?: (value: boolean) => void;
    onQuoteValueChange?: (value: number) => void;
    onNumberOfQuotesChange?: (value: number) => void;
    disabled?: boolean;
    errors?: {
      quoteValue?: string | null;
      numberOfQuotes?: string | null;
    };
  };

  let {
    proportional = $bindable(true),
    quoteValue = $bindable(0),
    numberOfQuotes = $bindable(0),
    onProportionalChange,
    onQuoteValueChange,
    onNumberOfQuotesChange,
    disabled = false,
    errors = {}
  }: Props = $props();

  // Validation states
  const isQuoteConfigValid = $derived(quoteValue > 0 && numberOfQuotes > 0);
</script>

<div class="space-y-6">
  <!-- Capital Social Section -->
  <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
    <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
          </svg>
        </div>
        <h3 class="text-lg font-semibold text-white">Capital Social e Cotas</h3>
      </div>
    </div>
    <div class="p-6">
      <QuoteConfiguration
        bind:quoteValue
        bind:numberOfQuotes
        {onQuoteValueChange}
        {onNumberOfQuotesChange}
        {disabled}
        {errors}
      />
    </div>
  </div>

  <!-- Profit Distribution Section -->
  <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
    <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2"/>
          </svg>
        </div>
        <h3 class="text-lg font-semibold text-white">Política de Distribuição de Lucros</h3>
      </div>
    </div>
    <div class="p-6">
      <OfficeProportionality
        bind:proportional
        {onProportionalChange}
        disabled={disabled || !isQuoteConfigValid}
      />

      {#if !isQuoteConfigValid}
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 flex items-start gap-3 mt-4">
          <svg class="w-5 h-5 text-blue-500 flex-shrink-0 mt-0.5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <div>
            <h4 class="font-semibold text-blue-900">Ação Necessária</h4>
            <p class="text-sm text-blue-700">Configure o capital social e as cotas antes de definir a política de distribuição.</p>
          </div>
        </div>
      {/if}
    </div>
  </div>
</div>

<style>
  :global(.bg-primary-50) {
    background-color: rgb(239 246 255);
  }
</style>