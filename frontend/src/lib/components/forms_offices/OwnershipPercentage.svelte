<script lang="ts">
  type Props = {
    value?: number;
    id?: string;
    labelText?: string;
    showRangeSlider?: boolean;
    onchange?: (value: number) => void;
    disabled?: boolean;
  };

  let {
    value = $bindable(0),
    id = 'partner-percentage',
    labelText = 'Participação (%)',
    showRangeSlider = false,
    onchange,
    disabled = false
  }: Props = $props();

  function handleInputChange(e: Event) {
    const target = e.target as HTMLInputElement;
    const newValue = parseFloat(target.value) || 0;
    value = newValue;
    onchange?.(newValue);
  }
</script>

<div class="form-control flex flex-col">
  <label class="label pb-1" for={id}>
    <span class="label-text">{labelText}</span>
  </label>
  <div class="flex items-center gap-2">
    <input
      {id}
      type="number"
      class="input input-bordered w-20"
      min="0"
      max="100"
      step="0.01"
      bind:value
      oninput={handleInputChange}
      {disabled}
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
        min="0"
        max="100"
        bind:value
        oninput={handleInputChange}
        {disabled}
      />
    </div>
  {/if}
</div>