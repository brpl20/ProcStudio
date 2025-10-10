<script lang="ts">
  import { formatCurrency } from '../../utils/lawyer.utils';

  type Props = {
    totalMonthly: number;
  };

  let { totalMonthly }: Props = $props();

  const totalAnnual = $derived(totalMonthly * 13.33);
</script>

{#if totalMonthly > 0}
  <div class="mt-4 p-4 bg-base-200 rounded-lg">
    <div class="flex justify-between items-center">
      <span class="font-semibold">Total Pro-Labore Mensal:</span>
      <span class="text-lg font-bold text-primary">
        R$ {formatCurrency(totalMonthly)}
      </span>
    </div>
    <div class="text-sm text-gray-600 mt-2">
      Custo anual estimado: R$ {formatCurrency(totalAnnual)}
      <span class="text-xs">(incluindo 13º e férias)</span>
    </div>
  </div>
{/if}
