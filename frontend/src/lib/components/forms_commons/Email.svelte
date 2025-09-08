<script>
  import { createEventDispatcher } from 'svelte';
  import { validateEmail, validateEmailRequired } from '../../validation';

  export let value = '';
  export let placeholder = 'email@exemplo.com';
  export let id = 'email';
  export let labelText = 'Email';
  export let required = false;
  export let disabled = false;
  export let errors = '';
  export let touched = false;
  export let testId = 'email-input';

  const dispatch = createEventDispatcher();

  let error = '';

  // Reactive validation
  $: {
    if (touched && value !== undefined) {
      if (required) {
        error = validateEmailRequired(value);
      } else {
        error = validateEmail(value);
      }
    }
  }

  // Use external error if provided, otherwise use internal validation
  $: displayError = errors || error;
  $: hasError = touched && displayError;

  function handleInput(event) {
    value = event.target.value;
    dispatch('input', { value, target: event.target });
  }

  function handleBlur(event) {
    touched = true;
    dispatch('blur', { value, target: event.target });
  }
</script>

<div class="form-control w-full">
  <label for={id} class="label justify-start">
    <span class="label-text font-medium">
      {labelText}
      {required ? '*' : ''}
    </span>
  </label>

  <input
    {id}
    type="email"
    class="input input-bordered w-full {hasError ? 'input-error' : ''}"
    {value}
    on:input={handleInput}
    on:blur={handleBlur}
    {disabled}
    {placeholder}
    aria-required={required ? 'true' : 'false'}
    aria-invalid={hasError ? 'true' : 'false'}
    aria-describedby={hasError ? `${id}-error` : undefined}
    data-testid={testId}
  />

  {#if hasError}
    <div id="{id}-error" class="text-error text-sm mt-1">
      {displayError}
    </div>
  {/if}
</div>
