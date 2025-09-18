<script lang="ts">
  type Props = {
    value?: string;
    id?: string;
    labelText?: string;
    required?: boolean;
    disabled?: boolean;
  };

  let {
    value = $bindable(''),
    id = 'office-foundation',
    labelText = 'Data de Fundação',
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
    type="date"
    class="input input-bordered w-full"
    bind:value
    {required}
    {disabled}
  />
</div>