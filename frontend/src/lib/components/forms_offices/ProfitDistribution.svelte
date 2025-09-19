<script lang="ts">
  type Props = {
    value?: 'proportional' | 'disproportional';
    id?: string;
    labelText?: string;
    disabled?: boolean;
  };

  let {
    value = $bindable('proportional'),
    id = 'profit-distribution',
    labelText = 'Como será a distribuição de lucros?',
    disabled = false
  }: Props = $props();
</script>

<div class="form-control flex flex-col mb-4">
  <fieldset>
    <legend class="label pb-1">
      <span class="label-text">{labelText}</span>
    </legend>

    <div class="flex gap-6">
      <label class="label cursor-pointer">
        <input
          type="radio"
          class="radio radio-primary"
          bind:group={value}
          value="proportional"
          {disabled}
        />
        <span class="label-text ml-2">Proporcional à participação</span>
      </label>

      <label class="label cursor-pointer">
        <input
          type="radio"
          class="radio radio-primary"
          bind:group={value}
          value="disproportional"
          {disabled}
        />
        <span class="label-text ml-2">Desproporcional</span>
      </label>
    </div>
  </fieldset>
</div>