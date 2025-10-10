<script lang="ts">
  import Checkbox from '../forms_commons/Checkbox.svelte';

  type Props = {
    checked?: boolean;
    id?: string;
    labelText?: string;
    disabled?: boolean;
  };

  let {
    checked = $bindable(false),
    id = 'partners-pro-labore',
    labelText = 'Sim, os sócios retirarão pro-labore',
    disabled = false
  }: Props = $props();
</script>

<Checkbox
  bind:checked
  {id}
  {labelText}
  {disabled}
  wrapperClass="form-control mb-4"
/>