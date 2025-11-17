<script lang="ts">
  import type { SelectFieldProps } from '../../types/form-field-contract';

  interface CivilStatusProps extends SelectFieldProps {
    gender?: 'male' | 'female' | '';
  }

  let {
    value = $bindable(''),
    gender = '',
    id = 'civil-status',
    labelText = 'Estado Civil',
    required = false,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined
  }: CivilStatusProps = $props();


  const civilStatusOptions = $derived(
    gender === 'female'
      ? [
          { value: 'single', label: 'Solteira' },
          { value: 'married', label: 'Casada' },
          { value: 'divorced', label: 'Divorciada' },
          { value: 'widower', label: 'Viúva' },
          { value: 'union', label: 'União Estável' }
        ]
      : [
          { value: 'single', label: 'Solteiro' },
          { value: 'married', label: 'Casado' },
          { value: 'divorced', label: 'Divorciado' },
          { value: 'widower', label: 'Viúvo' },
          { value: 'union', label: 'União Estável' }
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
    <option disabled value="">Selecione...</option>
    {#each civilStatusOptions as option}
      <option value={option.value}>{option.label}</option>
    {/each}
  </select>
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>