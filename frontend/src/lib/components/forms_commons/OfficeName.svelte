<script lang="ts">
  type Props = {
    value?: string;
    id?: string;
    labelText?: string;
    placeholder?: string;
    required?: boolean;
    disabled?: boolean;
  };

  let {
    value = $bindable(''),
    id = 'office-name',
    labelText = 'Nome do Escritório',
    placeholder = 'Nome do escritório',
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
  <input
    {id}
    type="text"
    class="input input-bordered w-full"
    bind:value
    {placeholder}
    {required}
    {disabled}
  />
</div>