<script lang="ts">
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

<div class="form-control mb-4">
  <label class="label cursor-pointer justify-start gap-2">
    <input
      {id}
      type="checkbox"
      class="checkbox checkbox-primary"
      bind:checked
      {disabled}
    />
    <span class="label-text">{labelText}</span>
  </label>
</div>