<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';
  import { validateCNPJOptional, formatCNPJ } from '../../validation/cnpj';

  interface CnpjProps extends TextFieldProps {
    validate?: boolean;
    validateFn?: (value: string) => string | null;
    formatFn?: (value: string) => string;
  }

  let {
    value = $bindable(''),
    id = 'cnpj',
    labelText = 'CNPJ',
    placeholder = '00.000.000/0000-00',
    required = true,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined,
    validate = true,
    validateFn = validateCNPJOptional,
    formatFn = formatCNPJ
  }: CnpjProps = $props();

  const finalId = id;
  const finalLabelText = labelText;
  const finalPlaceholder = placeholder;
  const finalRequired = required;
  const finalDisabled = disabled;
  const finalWrapperClass = wrapperClass;
  const finalInputClass = inputClass;
  const finalTestId = testId;
  const finalValidate = validate;
  const finalValidateFn = validateFn;
  const finalFormatFn = formatFn;

  // Handle input with optional formatting (no live validation)
  function handleInput(event: Event) {
    const target = event.target as HTMLInputElement;
    let newValue = target.value;

    if (finalFormatFn) {
      newValue = finalFormatFn(newValue);
    }

    value = newValue;
  }

  // Handle blur with validation based on required and presence of value
  function handleBlur() {
    touched = true;

    if (!finalValidate) {
      errors = null;
      return;
    }

    const hasValue = String(value ?? '').trim().length > 0;

    if (finalRequired && !hasValue) {
      errors = 'CNPJ é obrigatório';
    } else if (hasValue && finalValidateFn) {
      errors = finalValidateFn(value);
    } else {
      // optional and blank => no error
      errors = null;
    }
  }
</script>

<div class="form-control w-full {finalWrapperClass}">
  <label for={finalId} class="label justify-start pb-1">
    <span class="label-text font-medium">
      {finalLabelText}
      {#if finalRequired}<span class="text-error">*</span>{/if}
    </span>
  </label>
  <input
    id={finalId}
    type="text"
    class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {finalInputClass}"
    bind:value
    oninput={handleInput}
    onblur={handleBlur}
    disabled={finalDisabled}
    placeholder={finalPlaceholder}
    maxlength="18"
    aria-required={finalRequired ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${finalId}-error` : undefined}
    data-testid={finalTestId || `${finalId}-input`}
  />
  {#if errors && touched}
    <div id="{finalId}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>
