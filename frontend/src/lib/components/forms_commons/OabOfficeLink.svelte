<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';

  type Props = TextFieldProps & {
    inputType?: 'url';
  };

  let {
    value = $bindable(''),
    id = 'oab-office-link',
    labelText = 'Link OAB',
    placeholder = 'Link do perfil na OAB',
    required = false,
    disabled = false,
    errors = null,
    touched = false,
    wrapperClass = '',
    inputClass = '',
    inputType = 'url',
    testId = undefined
  }: Props = $props();
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
    type={inputType}
    class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {inputClass}"
    bind:value
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
}</div>