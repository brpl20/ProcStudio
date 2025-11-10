<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';

  let {
    value = $bindable(''),
    id = 'password',
    labelText = 'Senha',
    placeholder = 'Digite a senha',
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
    if (required && !value) {
      errors = 'Este campo é obrigatório.';
    } else if (value && value.length < 6) {
      errors = 'A senha deve ter pelo menos 6 caracteres.';
    } else {
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
    type="password"
    class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {inputClass}"
    bind:value
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