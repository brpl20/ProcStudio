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

  const finalId = id;
  const finalLabelText = labelText;
  const finalPlaceholder = placeholder;
  const finalRequired = required;
  const finalDisabled = disabled;
  const finalWrapperClass = wrapperClass;
  const finalInputClass = inputClass;
  const finalTestId = testId;
  const finalValidateFn = validateFn;
  const finalFormatFn = formatFn;

  // Handle input with optional formatting
  function handleInput(event: Event) {
    const target = event.target as HTMLInputElement;
    let newValue = target.value;

    // Apply formatting if provided
    if (finalFormatFn) {
      newValue = finalFormatFn(newValue);
    }

    value = newValue;
  }

  // Handle blur with validation
  function handleBlur() {
    touched = true;

    // If validation function provided, validate on blur
    if (finalValidateFn && finalRequired) {
      // CORREÇÃO: Atribui diretamente o resultado da validação.
      // Se for válido, 'errors' receberá null e limpará a mensagem.
      // Se for inválido, receberá a string de erro.
      errors = finalValidateFn(value);
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
    maxlength="14"
    aria-required={finalRequired ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${finalId}-error` : undefined}
    data-testid={finalTestId || `${finalId}-input`}
  />
  {#if errors && touched}
    <div id="{finalId}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>