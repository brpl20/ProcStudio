<script lang="ts">
  import type { ProfitDistributionType } from '../../constants/formOptions';

  type Partner = {
    lawyer_name?: string;
    ownership_percentage: number;
  };

  type Props = {
    distributionType: ProfitDistributionType;
    partners?: Partner[];
  };

  const {
    distributionType = 'proportional',
    partners = []
  }: Props = $props();
</script>

{#if distributionType === 'proportional'}
  <div class="alert alert-info">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="stroke-current shrink-0 h-6 w-6"
      fill="none"
      viewBox="0 0 24 24"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
    <div>
      <div class="font-bold">
        Os lucros serão distribuídos proporcionalmente à participação de cada sócio.
      </div>
      <div class="text-sm mt-2">
        <strong>Distribuição atual:</strong>
        {#each partners as partner}
          {#if partner.lawyer_name}
            <div class="flex justify-between">
              <span>{partner.lawyer_name}:</span>
              <span class="font-bold">{partner.ownership_percentage}%</span>
            </div>
          {/if}
        {/each}
      </div>
    </div>
  </div>
{:else}
  <div class="alert alert-warning">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="stroke-current shrink-0 h-6 w-6"
      fill="none"
      viewBox="0 0 24 24"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"
      />
    </svg>
    <span>
      Distribuição desproporcional será definida de acordo com cada trabalho/processo.
    </span>
  </div>
{/if}