<script lang="ts">
  import { PROFIT_DISTRIBUTION_TYPES, type ProfitDistributionType } from '../../constants/formOptions';

  type Props = {
    value?: ProfitDistributionType;
    id?: string;
    labelText?: string;
    disabled?: boolean;
  };

  let {
    value = $bindable<ProfitDistributionType>('proportional'),
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
      {#each PROFIT_DISTRIBUTION_TYPES as type}
        <label class="label cursor-pointer">
          <input
            type="radio"
            class="radio radio-primary"
            bind:group={value}
            value={type.value}
            {disabled}
          />
          <span class="label-text ml-2">{type.label}</span>
        </label>
      {/each}
    </div>
  </fieldset>
</div>