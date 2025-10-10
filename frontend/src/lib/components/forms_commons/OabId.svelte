<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';
  import { validateAndNormalizeOab } from '../../validation/oabValidator';

  interface OabIdProps extends TextFieldProps {
    type?: 'lawyer' | 'office';
    onValidation?: (isValid: boolean, normalizedValue?: string) => void;
  }

  type Props = OabIdProps;

  let {
    value = $bindable(''),
    id = 'oab-id',
    labelText = 'Identificação OAB',
    placeholder = 'Número OAB',
    required = false,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined,
    type = 'lawyer',
    onValidation = undefined
  }: Props = $props();

  let internalErrors: string | null = null;

  $effect(() => {
    // Only validate for lawyer type
    if (type === 'lawyer' && value && touched) {
      const validationResult = validateAndNormalizeOab(value);
      
      if (!validationResult.isValid) {
        internalErrors = validationResult.error || 'OAB inválida';
        errors = internalErrors;
        onValidation?.(false);
      } else {
        internalErrors = null;
        errors = null;
        // For lawyers, update value with normalized format
        if (validationResult.normalizedOab && value !== validationResult.normalizedOab) {
          value = validationResult.normalizedOab;
        }
        onValidation?.(true, validationResult.normalizedOab);
      }
    } else if (type === 'office') {
      // For office type, no validation - just clear errors
      internalErrors = null;
      if (touched && !value && required) {
        errors = 'Campo obrigatório';
      } else {
        errors = null;
      }
      onValidation?.(true, value);
    }
  });

  // Update placeholder and label based on type
  $effect(() => {
    if (!placeholder || placeholder === 'Número OAB' || placeholder === 'ID do escritório na OAB') {
      placeholder = type === 'lawyer' ? 'Ex: PR_54159' : 'ID do escritório na OAB';
    }
    if (!labelText || labelText === 'Identificação OAB') {
      labelText = type === 'lawyer' ? 'OAB do Advogado' : 'Identificação OAB do Escritório';
    }
  });

  function handleBlur() {
    touched = true;
  }

  // For office type, allow special characters
  function handleInput(e: Event) {
    const target = e.target as HTMLInputElement;
    
    if (type === 'lawyer') {
      // For lawyer, restrict to alphanumeric and common separators
      target.value = target.value.replace(/[^A-Za-z0-9\s_/]/g, '');
    }
    // For office, allow all characters including - and /
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
    {disabled}
    {placeholder}
    aria-required={required ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${id}-error` : undefined}
    data-testid={testId || `${id}-input`}
    onblur={handleBlur}
    oninput={handleInput}
  />
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
  {#if type === 'lawyer' && !errors && !touched}
    <div class="text-xs text-base-content/60 mt-1">
      Formatos aceitos: PR_54159, PR 54159, 54159/PR
    </div>
  {/if}
</div>