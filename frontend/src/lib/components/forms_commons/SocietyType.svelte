<script lang="ts">
  import { SOCIETY_OPTIONS } from '../../constants/formOptions';

  type Props = {
    value?: string;
    id?: string;
    labelText?: string;
    required?: boolean;
    disabled?: boolean;
  };

  let {
    value = $bindable(''),
    id = 'office-society',
    labelText = 'Tipo de Sociedade',
    required = false,
    disabled = false
  }: Props = $props();
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
  >
    <option value="">Selecione...</option>
    {#each SOCIETY_OPTIONS as option}
      <option value={option.value}>{option.label}</option>
    {/each}
  </select>
</div>