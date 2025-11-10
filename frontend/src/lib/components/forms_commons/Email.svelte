<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';
  import { validateEmail, validateEmailRequired } from '../../validation';

  let {
    value = $bindable(''),
    id = 'email',
    labelText = 'Email',
    placeholder = 'email@exemplo.com',
    required = false,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined
  }: TextFieldProps = $props();

  function handleBlur() {
    touched = true;

    // Validate email format
    if (required) {
      const validationError = validateEmailRequired(value);
      errors = validationError || null;
    } else if (value) {
      const validationError = validateEmail(value);
      errors = validationError || null;
    } else {
      errors = null;
    }
  }

  function handleInput() {
    // Clear errors on input if already touched
    if (touched && errors) {
      errors = null;
    }
  }
</script>

<div class="form-control w-full {wrapperClass}">
  <label for={id} class="label justify-start pb-1">
    <span class="label-text font-medium">
      {labelText}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>
  <input
    {id}
    type="email"
    class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {inputClass}"
    bind:value
    oninput={handleInput}
    onblur={handleBlur}
    {disabled}
    {placeholder}
    aria-required={required ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${id}-error` : undefined}
    data-testid={testId || `${id}-input`}
  />
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>
