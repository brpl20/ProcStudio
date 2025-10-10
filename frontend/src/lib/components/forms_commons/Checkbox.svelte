<script lang="ts">
  import type { FormFieldProps } from '../../types/form-field-contract';

  interface CheckboxProps extends Omit<FormFieldProps<boolean>, 'value'> {
    checked?: boolean;
    onchange?: (checked: boolean) => void;
  }

  type Props = CheckboxProps;

  let {
    checked = $bindable(false),
    id = 'checkbox',
    labelText = '',
    disabled = false,
    required = false,
    errors = null,
    hint,
    wrapperClass = 'form-control',
    inputClass = 'checkbox checkbox-primary',
    labelClass = 'label cursor-pointer justify-start gap-2',
    testId,
    ariaLabel,
    ariaDescribedBy,
    onchange
  }: Props = $props();

  function handleChange(e: Event) {
    const target = e.target as HTMLInputElement;
    checked = target.checked;
    onchange?.(target.checked);
  }
</script>

<div class={wrapperClass}>
  <label class={labelClass}>
    <input
      {id}
      type="checkbox"
      class={inputClass}
      class:checkbox-error={errors}
      bind:checked
      onchange={handleChange}
      {disabled}
      {required}
      data-testid={testId}
      aria-label={ariaLabel || labelText}
      aria-describedby={ariaDescribedBy}
      aria-invalid={!!errors}
    />
    {#if labelText}
      <span class="label-text">
        {labelText}
        {#if required}<span class="text-error">*</span>{/if}
      </span>
    {/if}
  </label>
  
  {#if hint && !errors}
    <div class="label">
      <span class="label-text-alt">{hint}</span>
    </div>
  {/if}
  
  {#if errors}
    <div class="label">
      <span class="label-text-alt text-error">{errors}</span>
    </div>
  {/if}
</div>