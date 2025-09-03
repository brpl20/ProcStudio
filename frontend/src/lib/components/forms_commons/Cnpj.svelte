<!-- CNPJ.svelte -->
<script>
  import { createEventDispatcher } from 'svelte';
  import { validateCNPJRequired, formatCNPJ } from '../../validation/cnpj';

  // Props with defaults
  export let value = '';
  export let errors = null;
  export let touched = false;
  export let disabled = false;
  export let validateFn = validateCNPJRequired; // Default to built-in validation
  export let formatFn = formatCNPJ; // Default to built-in formatting
  export let id = 'cnpj'; // Allow customizing the ID
  export let required = true;
  export let labelText = 'CNPJ';
  export let placeholder = '00.000.000/0000-00';
  export let testId = undefined; // Can be overridden, otherwise uses id
  export let inputClass = ''; // Additional classes for the input
  export let wrapperClass = ''; // Additional classes for the wrapper

  // Set up event dispatcher
  const dispatch = createEventDispatcher();

  // Handle input with optional formatting
  function handleInput(event) {
    let newValue = event.target.value;

    // Apply formatting if provided
    if (formatFn) {
      newValue = formatFn(newValue);
    }

    value = newValue; // Update the bound value
    dispatch('input', { value: newValue, id });
  }

  // Handle blur with validation
  function handleBlur() {
    touched = true; // Mark as touched on blur
    dispatch('blur', { id, value });

    // If validation function provided, validate on blur
    if (validateFn && required) {
      const error = validateFn(value);
      errors = error; // Erros back and forth
      dispatch('validate', { id, value, error });
    }
  }
</script>

<div class="form-control w-full {wrapperClass}">
  <label for={id} class="label justify-start">
    <span class="label-text font-medium">{labelText} {required ? '*' : ''}</span>
  </label>
  <input
    {id}
    type="text"
    class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {inputClass}"
    bind:value
    on:input={handleInput}
    on:blur={handleBlur}
    {disabled}
    {placeholder}
    maxlength="18"
    aria-required={required ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${id}-error` : undefined}
    data-testid={testId || `${id}-input`}
  />
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>
