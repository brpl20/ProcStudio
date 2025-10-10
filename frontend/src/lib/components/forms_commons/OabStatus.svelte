<script lang="ts">
  import type { TextFieldProps } from '../../types/form-field-contract';

  interface OabStatusProps extends TextFieldProps {
    type?: 'lawyer' | 'office';
  }

  type Props = OabStatusProps;

  let {
    value = $bindable(''),
    id = 'oab-status',
    labelText = 'Status na OAB',
    placeholder = 'Status na OAB',
    required = false,
    disabled = false,
    errors = null,
    touched = false,
    wrapperClass = '',
    inputClass = '',
    testId = undefined,
    type = 'office'
  }: Props = $props();

  // Office status options
  const officeStatusOptions = [
    { value: '', label: 'Selecione o status' },
    { value: 'active', label: 'Ativo' },
    { value: 'inactive', label: 'Inativo' }
  ];

  // TODO: Implement lawyer status options when requirements are defined
  // For now, lawyer status will use a text input field
  const lawyerStatusOptions: { value: string; label: string }[] = [];
</script>

<div class="form-control w-full {wrapperClass}">
  <label for={id} class="label justify-start pb-1">
    <span class="label-text font-medium">
      {labelText}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>
  
  {#if type === 'office'}
    <!-- Office status: use select dropdown -->
    <select
      {id}
      class="select select-bordered w-full {errors && touched ? 'select-error' : ''} {inputClass}"
      bind:value
      {disabled}
      aria-required={required ? 'true' : 'false'}
      aria-invalid={errors && touched ? 'true' : 'false'}
      aria-describedby={errors && touched ? `${id}-error` : undefined}
      data-testid={testId || `${id}-select`}
    >
      {#each officeStatusOptions as option}
        <option value={option.value}>{option.label}</option>
      {/each}
    </select>
  {:else}
    <!-- Lawyer status: use text input for now -->
    <!-- TODO: Replace with select dropdown when lawyer status options are defined -->
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
    />
    {#if !errors && !touched}
      <div class="text-xs text-base-content/60 mt-1">
        Status do advogado (implementação futura)
      </div>
    {/if}
  {/if}
  
  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>