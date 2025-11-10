<!-- /frontend/src/lib/components/forms_commons/Nationality.svelte -->
<script lang="ts">
  import type { SelectFieldProps } from '../../types/form-field-contract';

  interface NationalityProps extends SelectFieldProps {
    gender?: 'male' | 'female' | '';
  }

  let {
    value = $bindable('brazilian'), // Default para 'brazilian'
    gender = '',
    id = 'nationality',
    labelText = 'Nacionalidade',
    required = false,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined
  }: NationalityProps = $props();

  // Dynamically generate options based on gender
  const nationalityOptions = $derived(
    gender === 'female'
      ? [
          { value: 'brazilian', label: 'Brasileira' },
          { value: 'foreigner', label: 'Estrangeira' }
        ]
      : [
          { value: 'brazilian', label: 'Brasileiro' },
          { value: 'foreigner', label: 'Estrangeiro' }
        ]
  );

  function handleBlur() {
    touched = true;
    if (required && !value) {
      errors = 'Este campo é obrigatório.';
    }
  }

  function handleChange() {
    if (touched) {
      handleBlur();
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
  <select
    id={id}
    class="select select-bordered w-full {errors && touched ? 'select-error' : ''} {inputClass}"
    bind:value
    onblur={handleBlur}
    onchange={handleChange}
    disabled={disabled}
    aria-required={required ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${id}-error` : undefined}
    data-testid={testId || `${id}-select`}
  >
    <!-- Não há necessidade de "Selecione..." se há um padrão -->
    {#each nationalityOptions as option}
      <option value={option.value}>{option.label}</option>
    {/each}
  </select>
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>