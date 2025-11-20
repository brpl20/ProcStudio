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

<div class="space-y-4">
  <div>
    <label class="block text-sm font-semibold text-[#01013D] mb-4">
      Distribuição de Lucros do Escritório
    </label>

    <div class="space-y-3">
      <!-- Proportional Option -->
      <label class="cursor-pointer block">
        <input
          type="radio"
          name="profit-distribution"
          checked={proportional}
          onchange={() => handleChange(true)}
          {disabled}
          class="sr-only peer"
        />
        <div class="p-4 border-2 rounded-xl transition-all duration-200 peer-checked:border-[#0277EE] peer-checked:bg-blue-50 border-gray-200 hover:border-gray-300 peer-disabled:opacity-50 peer-disabled:cursor-not-allowed"
             class:ring-2={proportional}
             class:ring-[#0277EE]={proportional}
             class:ring-offset-2={proportional}>
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0 pt-0.5">
              <div class="flex items-center justify-center h-5 w-5 rounded-full border-2 transition-all"
                   class:border-[#0277EE]={proportional}
                   class:bg-[#0277EE]={proportional}
                   class:border-gray-300={!proportional}>
                {#if proportional}
                  <div class="h-2 w-2 rounded-full bg-white"></div>
                {/if}
              </div>
            </div>
            <div class="flex-1">
              <span class="block text-sm font-semibold text-[#01013D]">
                Distribuição Proporcional
              </span>
              <p class="text-sm text-gray-600 mt-1.5 leading-relaxed">
                Os lucros serão distribuídos proporcionalmente ao número de cotas de cada sócio
              </p>
            </div>
          </div>
        </div>
      </label>

      <!-- Non-proportional Option -->
      <label class="cursor-pointer block">
        <input
          type="radio"
          name="profit-distribution"
          checked={!proportional}
          onchange={() => handleChange(false)}
          {disabled}
          class="sr-only peer"
        />
        <div class="p-4 border-2 rounded-xl transition-all duration-200 peer-checked:border-[#0277EE] peer-checked:bg-blue-50 border-gray-200 hover:border-gray-300 peer-disabled:opacity-50 peer-disabled:cursor-not-allowed"
             class:ring-2={!proportional}
             class:ring-[#0277EE]={!proportional}
             class:ring-offset-2={!proportional}>
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0 pt-0.5">
              <div class="flex items-center justify-center h-5 w-5 rounded-full border-2 transition-all"
                   class:border-[#0277EE]={!proportional}
                   class:bg-[#0277EE]={!proportional}
                   class:border-gray-300={proportional}>
                {#if !proportional}
                  <div class="h-2 w-2 rounded-full bg-white"></div>
                {/if}
              </div>
            </div>
            <div class="flex-1">
              <span class="block text-sm font-semibold text-[#01013D]">
                Distribuição Desproporcional
              </span>
              <p class="text-sm text-gray-600 mt-1.5 leading-relaxed">
                Os lucros serão distribuídos conforme acordado entre os sócios, independente das cotas
              </p>
            </div>
          </div>
        </div>
      </label>
    </div>
  </div>

  <!-- Information Alert -->
  {#if proportional}
    <div class="bg-emerald-50 border-l-4 border-emerald-500 rounded-r-lg p-4 shadow-sm">
      <div class="flex items-start gap-3">
        <div class="flex-shrink-0">
          <svg class="w-5 h-5 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="flex-1">
          <p class="text-sm font-medium text-emerald-800">
            Cada sócio receberá lucros proporcionais às suas cotas na sociedade.
          </p>
        </div>
      </div>
    </div>
  {:else}
    <div class="bg-amber-50 border-l-4 border-amber-500 rounded-r-lg p-4 shadow-sm">
      <div class="flex items-start gap-3">
        <div class="flex-shrink-0">
          <svg class="w-5 h-5 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
        </div>
        <div class="flex-1">
          <p class="text-sm font-medium text-amber-800">
            A distribuição de lucros será definida em acordo específico entre os sócios.
          </p>
        </div>
      </div>
    </div>
  {/if}
</div>
