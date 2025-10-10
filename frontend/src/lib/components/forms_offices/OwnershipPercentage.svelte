<script lang="ts">
  import type { NumberFieldProps } from '../../types/form-field-contract';

  interface OwnershipPercentageProps extends NumberFieldProps {
    showRangeSlider?: boolean;
    onchange?: (value: number) => void;
  }

  type Props = OwnershipPercentageProps;

  let {
    value = $bindable(0),
    id = 'partner-percentage',
    labelText = 'Participação (%)',
    showRangeSlider = false,
    disabled = false,
    required = false,
    errors = null,
    hint,
    min = 0,
    max = 100,
    step = 0.01,
    wrapperClass = 'form-control flex flex-col',
    inputClass = 'input input-bordered w-20',
    labelClass = 'label pb-1',
    testId,
    ariaLabel,
    ariaDescribedBy,
    onchange
  }: Props = $props();

  function handleInputChange(e: Event) {
    const target = e.target as HTMLInputElement;
    const newValue = parseFloat(target.value) || 0;
    value = newValue;
    onchange?.(newValue);
  }
</script>

<div class={wrapperClass}>
  <label class={labelClass} for={id}>
    <span class="label-text">
      {labelText}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>
  <div class="flex items-center gap-2">
    <input
      {id}
      type="number"
      class={inputClass}
      class:input-error={errors}
      {min}
      {max}
      {step}
      bind:value
      oninput={handleInputChange}
      {disabled}
      {required}
      data-testid={testId}
      aria-label={ariaLabel || labelText}
      aria-describedby={ariaDescribedBy}
      aria-invalid={!!errors}
    />
    <span>%</span>
  </div>

  {#if showRangeSlider}
    <div class="mt-2">
      <label class="label" for={`${id}-range`}>
        <span class="label-text-alt">Ajuste proporcional</span>
      </label>
      <input
        id={`${id}-range`}
        type="range"
        class="range range-sm"
        {min}
        {max}
        bind:value
        oninput={handleInputChange}
        {disabled}
      />
    </div>
  {/if}
  
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