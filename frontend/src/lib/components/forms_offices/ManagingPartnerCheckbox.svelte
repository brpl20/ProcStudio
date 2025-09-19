<script lang="ts">
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

  function handleChange(e: Event) {
    const target = e.target as HTMLInputElement;
    checked = target.checked;
    onchange?.(target.checked);
  }
</script>

<div class="form-control">
  <label class="label cursor-pointer justify-start gap-2">
    <input
      {id}
      type="checkbox"
      class="checkbox checkbox-primary"
      bind:checked
      onchange={handleChange}
      {disabled}
    />
    <span class="label-text">{labelText}</span>
  </label>
</div>