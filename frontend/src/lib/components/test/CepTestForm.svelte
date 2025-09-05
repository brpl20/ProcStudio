<!-- CEP Test Form -->
<script>
  import { CEPValidator } from '../../validation/cep-validator';
  import { CEPFormatter } from '../../validation/cep-formatter';
  import { cepService } from '../../api-external/services/cep-service';

  let cepValue = '';
  let errors = null;
  let touched = false;
  let isValidating = false;
  let addressInfo = null;
  let testResults = [];

  // Handle input with formatting
  function handleInput(event) {
    let newValue = event.target.value;
    cepValue = CEPFormatter.format(newValue);
    addressInfo = null;
    errors = null;
  }

  // Handle blur with validation
  async function handleBlur() {
    touched = true;

    // Local validation first
    const localError = CEPValidator.validateRequired(cepValue);
    if (localError) {
      errors = localError;
      return;
    }

    // API validation with debouncing
    if (cepValue && cepValue.replace(/[^\d]/g, '').length === 8) {
      isValidating = true;

      cepService.validateWithDebounce(cepValue, (result) => {
        isValidating = false;

        if (!result.isValid) {
          errors = result.message;
          addressInfo = null;
        } else {
          errors = null;
          addressInfo = result.data;

          // Add to test results
          testResults = [
            {
              cep: cepValue,
              timestamp: new Date().toLocaleTimeString(),
              result: result
            },
            ...testResults
          ].slice(0, 5); // Keep last 5 results
        }
      });
    }
  }

  // Clear form
  function clearForm() {
    cepValue = '';
    errors = null;
    touched = false;
    addressInfo = null;
    cepService.clearDebounce();
  }

  // Clear test results
  function clearResults() {
    testResults = [];
    cepService.clearCache();
  }
</script>

<div class="card bg-base-100 shadow-xl max-w-2xl mx-auto">
  <div class="card-body">
    <h2 class="card-title text-primary">🧪 CEP Validator Test</h2>

    <!-- CEP Input Form -->
    <div class="form-control w-full">
      <label for="test-cep" class="label">
        <span class="label-text font-medium">CEP *</span>
      </label>
      <div class="relative">
        <input
          id="test-cep"
          type="text"
          class="input input-bordered w-full {errors && touched ? 'input-error' : ''}"
          bind:value={cepValue}
          on:input={handleInput}
          on:blur={handleBlur}
          placeholder="00000-000"
          maxlength="9"
        />
        {#if isValidating}
          <div class="absolute right-3 top-1/2 transform -translate-y-1/2">
            <span class="loading loading-spinner loading-sm"></span>
          </div>
        {/if}
      </div>

      {#if errors && touched}
        <div class="text-error text-sm mt-1">{errors}</div>
      {/if}
    </div>

    <!-- Address Information -->
    {#if addressInfo && !errors}
      <div class="mt-4 p-4 bg-success/10 border border-success/20 rounded-lg">
        <div class="flex items-center gap-2 mb-3">
          <span class="badge badge-success badge-sm">✓</span>
          <h3 class="font-semibold text-success">CEP Válido</h3>
        </div>

        <div class="space-y-2 text-sm">
          <div class="font-semibold">{addressInfo.street || addressInfo.logradouro}</div>
          {#if addressInfo.complement || addressInfo.complemento}
            <div class="text-base-content/70">
              {addressInfo.complement || addressInfo.complemento}
            </div>
          {/if}
          <div class="text-base-content/70">
            {addressInfo.neighborhood || addressInfo.bairro},
            {addressInfo.city || addressInfo.localidade} -
            {addressInfo.state || addressInfo.uf}
          </div>
          {#if addressInfo.ibge}
            <div class="text-xs text-base-content/50">IBGE: {addressInfo.ibge}</div>
          {/if}
          {#if addressInfo.ddd}
            <div class="text-xs text-base-content/50">DDD: {addressInfo.ddd}</div>
          {/if}
        </div>
      </div>
    {/if}

    <!-- Action Buttons -->
    <div class="card-actions justify-end mt-4">
      <button class="btn btn-ghost btn-sm" on:click={clearForm}> Limpar </button>
      <button class="btn btn-ghost btn-sm" on:click={clearResults}> Limpar Resultados </button>
    </div>

    <!-- Test Results History -->
    {#if testResults.length > 0}
      <div class="divider">Resultados dos Testes</div>

      <div class="space-y-3">
        {#each testResults as test}
          <div class="collapse collapse-arrow bg-base-200">
            <input type="checkbox" />
            <div class="collapse-title text-sm font-medium">
              <div class="flex justify-between items-center">
                <span class="font-mono">{test.cep}</span>
                <div class="flex items-center gap-2">
                  {#if test.result.isValid}
                    <span class="badge badge-success badge-xs">✓</span>
                  {:else}
                    <span class="badge badge-error badge-xs">✗</span>
                  {/if}
                  <span class="text-xs text-base-content/50">{test.timestamp}</span>
                </div>
              </div>
            </div>
            <div class="collapse-content text-xs">
              <pre class="bg-base-300 p-2 rounded text-xs overflow-auto">{JSON.stringify(
                  test.result,
                  null,
                  2
                )}</pre>
            </div>
          </div>
        {/each}
      </div>
    {/if}

    <!-- API Info -->
    <div class="mt-6 p-3 bg-info/10 rounded-lg text-xs text-info-content">
      <div class="font-semibold mb-1">ℹ️ Test Configuration:</div>
      <div>• Debounce: 400ms</div>
      <div>• API Timeout: 3000ms</div>
      <div>• Caching: Enabled for valid results</div>
      <div>• Validation: Local format + API lookup</div>
    </div>
  </div>
</div>
