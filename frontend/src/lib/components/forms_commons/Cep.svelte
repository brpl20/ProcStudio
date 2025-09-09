<!-- CEP.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { CEPFormatter } from '../../validation/cep-formatter';
  import { CEPValidator } from '../../validation/cep-validator';
  import { cepService } from '../../api-external/services/cep-service';

  interface AddressInfo {
    logradouro: string;
    complemento?: string;
    bairro: string;
    localidade: string;
    uf: string;
    estado: string;
    cep?: string;
    ibge?: string;
    gia?: string;
    ddd?: string;
    siafi?: string;
  }

  // Props with defaults
  export let value = '';
  export let errors: string | null = null;
  export let touched = false;
  export let disabled = false;
  export let validateFn = CEPValidator.validateRequired; // Default to built-in validation
  export let formatFn = CEPFormatter.format; // Default to built-in formatting
  export let id = 'cep'; // Allow customizing the ID
  export let required = true;
  export let labelText = 'CEP';
  export let placeholder = '00000-000';
  export let testId: string | undefined = undefined; // Can be overridden, otherwise uses id
  export let inputClass = ''; // Additional classes for the input
  export let wrapperClass = ''; // Additional classes for the wrapper
  export let useAPIValidation = false; // Enable API validation
  export let showAddressInfo = false; // Show address information when valid

  // Set up event dispatcher
  const dispatch = createEventDispatcher();

  // Address information from API
  let addressInfo: AddressInfo | null = null;
  let isValidating = false;

  // Handle input with optional formatting
  function handleInput(event: Event) {
    const target = event.target as HTMLInputElement;
    let newValue = target.value;

    // Apply formatting if provided
    if (formatFn) {
      newValue = formatFn(newValue);
    }

    value = newValue; // Update the bound value
    addressInfo = null; // Clear previous address info
    dispatch('input', { value: newValue, id });
  }

  // Handle blur with validation
  async function handleBlur() {
    touched = true; // Mark as touched on blur
    dispatch('blur', { id, value });

    // If validation function provided, validate on blur
    if (validateFn && required) {
      const error = validateFn(value);
      errors = error;

      // If local validation passes and API validation is enabled
      if (!error && useAPIValidation && value) {
        isValidating = true;
        try {
          const apiResult = await cepService.validate(value);

          if (!apiResult.isValid) {
            errors = apiResult.message || 'Erro na validação do CEP';
          } else if (apiResult.data) {
            if (showAddressInfo) {
              addressInfo = apiResult.data as AddressInfo;
            }
            dispatch('address-found', {
              id,
              value,
              address: apiResult.data as AddressInfo
            });
          }
        } catch (error) {
          errors = 'Erro ao validar CEP';
        } finally {
          isValidating = false;
        }
      }

      dispatch('validate', { id, value, error: errors, addressInfo });
    }
  }
</script>

<div class="form-control w-full {wrapperClass}">
  <label for={id} class="label justify-start">
    <span class="label-text font-medium">{labelText} {required ? '*' : ''}</span>
  </label>
  <div class="relative">
    <input
      {id}
      type="text"
      class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {inputClass}"
      bind:value
      on:input={handleInput}
      on:blur={handleBlur}
      {disabled}
      {placeholder}
      maxlength="9"
      aria-required={required ? 'true' : 'false'}
      aria-invalid={errors && touched ? 'true' : 'false'}
      aria-describedby={errors && touched ? `${id}-error` : undefined}
      data-testid={testId || `${id}-input`}
    />
    {#if isValidating}
      <div class="absolute right-3 top-1/2 transform -translate-y-1/2">
        <span class="loading loading-spinner loading-sm"></span>
      </div>
    {/if}
  </div>

  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}

  {#if showAddressInfo && addressInfo && !errors}
    <div class="mt-2 p-3 bg-base-200 rounded-lg text-sm">
      <div class="font-semibold text-base-content">{addressInfo.logradouro}</div>
      {#if addressInfo.complemento}
        <div class="text-base-content/70">{addressInfo.complemento}</div>
      {/if}
      <div class="text-base-content/70">
        {addressInfo.bairro}, {addressInfo.localidade} - {addressInfo.uf}
      </div>
      {#if addressInfo.estado !== addressInfo.uf}
        <div class="text-base-content/50">{addressInfo.estado}</div>
      {/if}
    </div>
  {/if}
</div>
