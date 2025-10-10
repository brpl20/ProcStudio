<script lang="ts">
  import { PARTNERSHIP_TYPES } from '../../constants/formOptions';
  import type { SelectFieldProps } from '../../types/form-field-contract';

  interface PartnershipTypeProps extends Omit<SelectFieldProps<string>, 'options'> {
    onchange?: (value: string) => void;
  }

  type Props = PartnershipTypeProps;

  let {
    value = $bindable(''),
    id = 'partner-type',
    labelText = 'Função',
    placeholder = 'Selecione a Função',
    required = false,
    disabled = false,
    errors = null,
    hint,
    wrapperClass = 'form-control flex flex-col',
    inputClass = 'select select-bordered w-full',
    labelClass = 'label pb-1',
    testId,
    ariaLabel,
    ariaDescribedBy,
    onchange
  }: Props = $props();

  function handleChange(e: Event) {
    const target = e.target as HTMLSelectElement;
    value = target.value;
    onchange?.(target.value);
  }
</script>

<div class={wrapperClass}>
  <label class={labelClass} for={id}>
    <span class="label-text">
      {labelText}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>
  <select
    {id}
    class={inputClass}
    class:select-error={errors}
    bind:value
    {disabled}
    {required}
    onchange={handleChange}
    data-testid={testId}
    aria-label={ariaLabel || labelText}
    aria-describedby={ariaDescribedBy}
    aria-invalid={!!errors}
  >
    <option value="">{placeholder}</option>
    {#each PARTNERSHIP_TYPES as type}
      <option value={type.value}>{type.label}</option>
    {/each}
  </select>
  
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