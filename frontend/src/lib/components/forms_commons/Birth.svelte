<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';

  let {
    value = $bindable(''),
    id = 'birth',
    labelText = 'Data de Nascimento',
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

    // 1. Checa se é obrigatório e vazio
    if (required && !value) {
      errors = 'Este campo é obrigatório.';
      return;
    }

    // 2. Validação adicional: data não pode ser no futuro
    if (value) {
      const today = new Date();
      today.setHours(0, 0, 0, 0); // Zera o tempo para comparar apenas a data
      const birthDate = new Date(value);

      if (birthDate > today) {
        errors = 'A data não pode ser no futuro.';
      } else {
        errors = null; // Limpa o erro se a data for válida
      }
    }
  }

  function handleInput() {
    if (touched) {
      handleBlur(); // Re-valida ao mudar a data
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
    id={id}
    type="date"
    class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {inputClass}"
    bind:value
    oninput={handleInput}
    onblur={handleBlur}
    disabled={disabled}
    aria-required={required ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${id}-error` : undefined}
    data-testid={testId || `${id}-input`}
  />
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>