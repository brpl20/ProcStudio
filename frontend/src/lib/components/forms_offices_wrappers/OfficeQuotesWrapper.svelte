<script lang="ts">
  import FormSection from '../ui/FormSection.svelte';
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
  const showPartnerConfiguration = $derived(isQuoteConfigValid);
</script>

<!-- Capital Social Section -->
<FormSection title="Capital Social e Cotas">
  {#snippet children()}
    <QuoteConfiguration
      bind:quoteValue
      bind:numberOfQuotes
      onQuoteValueChange={onQuoteValueChange}
      onNumberOfQuotesChange={onNumberOfQuotesChange}
      {disabled}
      {errors}
    />
  {/snippet}
</FormSection>

<!-- Profit Distribution Section -->
<FormSection title="Política de Distribuição de Lucros">
  {#snippet children()}
    <OfficeProportionality
      bind:proportional
      onProportionalChange={onProportionalChange}
      disabled={disabled || !isQuoteConfigValid}
    />

    {#if !isQuoteConfigValid}
      <div class="alert alert-info mt-4">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-current shrink-0 w-6 h-6">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span>Configure o capital social e as cotas antes de definir a política de distribuição.</span>
      </div>
    {/if}
  {/snippet}
</FormSection>

<style>
  :global(.bg-primary-50) {
    background-color: rgb(239 246 255);
  }
</style>