<script lang="ts">
  type Props = {
    proportional?: boolean;
    onProportionalChange?: (value: boolean) => void;
    disabled?: boolean;
  };

  let {
    proportional = $bindable(true),
    onProportionalChange,
    disabled = false
  }: Props = $props();

  function handleChange(value: boolean) {
    proportional = value;
    onProportionalChange?.(value);
  }
</script>

<div class="form-control">
  <label class="label">
    <span class="label-text font-semibold">Distribuição de Lucros do Escritório</span>
  </label>

  <div class="space-y-3">
    <!-- Proportional Option -->
    <label class="label cursor-pointer justify-start gap-3 p-4 border rounded-lg hover:bg-base-100"
           class:border-primary={proportional}
           class:bg-primary-50={proportional}>
      <input
        type="radio"
        name="profit-distribution"
        class="radio radio-primary"
        checked={proportional}
        onchange={() => handleChange(true)}
        {disabled}
      />
      <div class="flex-1">
        <span class="label-text font-medium">Distribuição Proporcional</span>
        <p class="text-sm text-gray-600 mt-1">
          Os lucros serão distribuídos proporcionalmente ao número de cotas de cada sócio
        </p>
      </div>
    </label>

    <!-- Non-proportional Option -->
    <label class="label cursor-pointer justify-start gap-3 p-4 border rounded-lg hover:bg-base-100"
           class:border-primary={!proportional}
           class:bg-primary-50={!proportional}>
      <input
        type="radio"
        name="profit-distribution"
        class="radio radio-primary"
        checked={!proportional}
        onchange={() => handleChange(false)}
        {disabled}
      />
      <div class="flex-1">
        <span class="label-text font-medium">Distribuição Desproporcional</span>
        <p class="text-sm text-gray-600 mt-1">
          Os lucros serão distribuídos conforme acordado entre os sócios, independente das cotas
        </p>
      </div>
    </label>
  </div>

  <!-- Information Alert -->
  {#if proportional}
    <div class="alert alert-success mt-4">
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>Cada sócio receberá lucros proporcionais às suas cotas na sociedade.</span>
    </div>
  {:else}
    <div class="alert alert-warning mt-4">
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z" />
      </svg>
      <span>A distribuição de lucros será definida em acordo específico entre os sócios.</span>
    </div>
  {/if}
</div>