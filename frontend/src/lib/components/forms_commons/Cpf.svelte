<!-- CPF.svelte -->
<script>
  import { createEventDispatcher } from 'svelte';
  import { validateCPFRequired, formatCPF } from '../../validation/cpf';

  // Props with defaults
  export let value = '';
  export let errors = null;
  export let touched = false;
  export let disabled = false;
  export let validateFn = validateCPFRequired; // Default to built-in validation
  export let formatFn = formatCPF; // Default to built-in formatting
  export let id = 'cpf'; // Allow customizing the ID
  export let required = true;
  export let labelText = 'CPF';
  export let placeholder = '000.000.000-00';
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
      if (error) {
        errors = error;
      }
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
    maxlength="14"
    aria-required={required ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${id}-error` : undefined}
    data-testid={testId || `${id}-input`}
  />
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>
