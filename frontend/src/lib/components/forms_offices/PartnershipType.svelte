<script lang="ts">
  import { PARTNERSHIP_TYPES } from '../../constants/formOptions';

  type Props = {
    value?: string;
    id?: string;
    labelText?: string;
    required?: boolean;
    disabled?: boolean;
    onchange?: (value: string) => void;
  };

  let {
    value = $bindable(''),
    id = 'partner-type',
    labelText = 'Função',
    required = false,
    disabled = false,
    onchange
  }: Props = $props();

  function handleChange(e: Event) {
    const target = e.target as HTMLSelectElement;
    value = target.value;
    onchange?.(target.value);
  }
</script>

<div class="form-control flex flex-col">
  <label class="label pb-1" for={id}>
    <span class="label-text">
      {labelText}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>
  <select
    {id}
    class="select select-bordered w-full"
    bind:value
    {disabled}
    onchange={handleChange}
  >
    <option value="">Selecione a Função</option>
    {#each PARTNERSHIP_TYPES as type}
      <option value={type.value}>{type.label}</option>
    {/each}
  </select>
</div>