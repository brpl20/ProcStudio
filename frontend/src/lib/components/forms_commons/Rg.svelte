<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';

  interface RgProps extends TextFieldProps {
    formatFn?: (value: string) => string;
  }

  let {
    value = $bindable(''),
    id = 'rg',
    labelText = 'RG',
    placeholder = '00.000.000-0',
    required = false,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined,
    formatFn = undefined 
  }: RgProps = $props();

  function handleInput(event: Event) {
    const target = event.target as HTMLInputElement;
    let newValue = target.value;

    if (formatFn) {
      newValue = formatFn(newValue);
    }
    value = newValue;

    if (touched && errors) {
      errors = null;
    }
  }

  function handleBlur() {
    touched = true;
    if (required && !value) {
      errors = 'Este campo é obrigatório.';
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
    type="text"
    class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {inputClass}"
    bind:value
    oninput={handleInput}
    onblur={handleBlur}
    disabled={disabled}
    placeholder={placeholder}
    aria-required={required ? 'true' : 'false'}
    aria-invalid={errors && touched ? 'true' : 'false'}
    aria-describedby={errors && touched ? `${id}-error` : undefined}
    data-testid={testId || `${id}-input`}
  />
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>