<!-- /frontend/src/lib/components/forms_commons/Gender.svelte -->
<script lang="ts">
  import type { SelectFieldProps } from '../../types/form-field-contract';

  // Opções de Gênero (regra de negócio aplicada aqui)
  const genderOptions = [
    { value: 'male', label: 'Masculino' },
    { value: 'female', label: 'Feminino' }
  ];

  let {
    value = $bindable(''),
    id = 'gender',
    labelText = 'Gênero',
    required = false,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined
  }: SelectFieldProps = $props();

  function handleBlur() {
    touched = true;
    if (required && !value) {
      errors = 'Este campo é obrigatório.';
    }
  }

  function handleChange() {
    if (touched) {
      handleBlur(); // Re-valida ao mudar a seleção se já foi "tocado"
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
    {#each genderOptions as option}
      <option value={option.value}>{option.label}</option>
    {/each}
  </select>
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>