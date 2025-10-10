<script lang="ts">
  import Checkbox from '../forms_commons/Checkbox.svelte';

  type Props = {
    checked?: boolean;
    id?: string;
    labelText?: string;
    disabled?: boolean;
    onchange?: (checked: boolean) => void;
  };

  let {
    checked = $bindable(false),
    id = 'managing-partner',
    labelText = 'Sócio Administrador',
    disabled = false,
    onchange
  }: Props = $props();
</script>

<Checkbox
  bind:checked
  {id}
  {labelText}
  {disabled}
  {onchange}
/>