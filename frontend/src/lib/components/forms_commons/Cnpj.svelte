<!-- CNPJ.svelte -->
<script>
  import { createEventDispatcher } from 'svelte';
  import { validateCNPJ, formatCNPJ } from '../../validation/cnpj';

  // Props with defaults
  export let value = '';
  export let errors = null;
  export let touched = false;
  export let disabled = false;

  // Master switch: allow parent to disable validation entirely
  export let validate = true;

  // Validation/formatting functions (kept internal by default)
  export let validateFn = validateCNPJ; // non-required validator by default
  export let formatFn = formatCNPJ; // Default to built-in formatting

  export let id = 'cnpj';
  export let required = true;
  export let labelText = 'CNPJ';
  export let placeholder = '00.000.000/0000-00';
  export let testId = undefined; // Can be overridden, otherwise uses id
  export let inputClass = ''; // Additional classes for the input
  export let wrapperClass = ''; // Additional classes for the wrapper

  // Set up event dispatcher
  const dispatch = createEventDispatcher();

  // Handle input with optional formatting (no live validation)
  function handleInput(event) {
    let newValue = event.target.value;

    if (formatFn) {
      newValue = formatFn(newValue);
    }

    value = newValue;
    dispatch('input', { value: newValue, id });
  }

  // Handle blur with validation based on required and presence of value
  function handleBlur() {
    touched = true;
    dispatch('blur', { id, value });

    if (!validate) {
      errors = null;
      dispatch('validate', { id, value, error: null });
      return;
    }

    const hasValue = String(value ?? '').trim().length > 0;

    if (required && !hasValue) {
      errors = 'CNPJ é obrigatório';
    } else if (hasValue && validateFn) {
      errors = validateFn(value);
    } else {
      // optional and blank => no error
      errors = null;
    }

    dispatch('validate', { id, value, error: errors });
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
