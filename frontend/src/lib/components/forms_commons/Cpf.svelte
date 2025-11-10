<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';
  import { validateCPFRequired, formatCPF } from '../../validation/cpf';

  interface CpfProps extends TextFieldProps {
    validateFn?: (value: string) => string | null;
    formatFn?: (value: string) => string;
  }

  let {
    value = $bindable(''),
    id = 'cpf',
    labelText = 'CPF',
    placeholder = '000.000.000-00',
    required = true,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined,
    validateFn = validateCPFRequired,
    formatFn = formatCPF
  }: CpfProps = $props();

  // Handle input with optional formatting
  function handleInput(event: Event) {
    const target = event.target as HTMLInputElement;
    let newValue = target.value;

    // Apply formatting if provided
    if (formatFn) {
      newValue = formatFn(newValue);
    }

    value = newValue;
  }

  // Handle blur with validation
  function handleBlur() {
    touched = true;

    // If validation function provided, validate on blur
    if (validateFn && required) {
      errors = validateFn(value);
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
    type="text"
    class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {inputClass}"
    bind:value
    oninput={handleInput}
    onblur={handleBlur}
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