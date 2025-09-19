<script lang="ts">
  import FormSection from '../ui/FormSection.svelte';
  import PartnerLawyerSelect from '../forms_offices/PartnerLawyerSelect.svelte';
  import PartnershipType from '../forms_offices/PartnershipType.svelte';
  import OwnershipPercentage from '../forms_offices/OwnershipPercentage.svelte';
  import ManagingPartnerCheckbox from '../forms_offices/ManagingPartnerCheckbox.svelte';
  import PercentageWarning from '../forms_offices/PercentageWarning.svelte';
  import ProfitDistribution from '../forms_offices/ProfitDistribution.svelte';
  import ProfitDistributionInfo from '../forms_offices/ProfitDistributionInfo.svelte';
  import ProLaboreCheckbox from '../forms_offices/ProLaboreCheckbox.svelte';
  import ProLaboreInfo from '../forms_offices/ProLaboreInfo.svelte';
  import ProLaboreInput from '../forms_offices/ProLaboreInput.svelte';
  import { lawyerStore } from '../../stores/lawyerStore.svelte';
  import type { Lawyer } from '../../api/types/user.lawyer';
  import { validateProLaboreAmount } from '../../validation';

  interface Partner {
    lawyer_id: string;
    lawyer_name?: string;
    partnership_type: string;
    ownership_percentage: number;
    is_managing_partner: boolean;
    pro_labore_amount?: number;
  }

  type Props = {
    partners: Partner[];
    profitDistribution: 'proportional' | 'disproportional';
    partnersWithProLabore: boolean;
    proLaboreErrors?: { [key: number]: string | null };
    onPartnerChange?: (index: number, field: string, value: any) => void;
    onAddPartner?: () => void;
    onRemovePartner?: (index: number) => void;
  };

  let {
    partners = $bindable([]),
    profitDistribution = $bindable('proportional'),
    partnersWithProLabore = $bindable(false),
    proLaboreErrors = $bindable({}),
    onPartnerChange,
    onAddPartner,
    onRemovePartner
  }: Props = $props();

  // Store initialization
  $effect(() => {
    lawyerStore.init();
  });

  // Calculate total percentage
  function getTotalPercentage(): number {
    return partners.reduce((sum, p) => sum + (p.ownership_percentage || 0), 0);
  }

  // Check if percentage is over 100
  function checkIsOverPercentage(): boolean {
    return getTotalPercentage() > 100;
  }

  // Get available lawyers for each partner position
  function getAvailableLawyersForPartner(index: number): Lawyer[] {
    const selectedIds = partners
      .filter((_, i) => i !== index)
      .map((p) => p.lawyer_id)
      .filter(Boolean);

    return lawyerStore.availableLawyers.filter(
      (lawyer) => !selectedIds.includes(lawyer.id)
    );
  }

  // Handle partner field changes
  function handlePartnerFieldChange(index: number, field: string, value: any) {
    if (field === 'lawyer_id' && value) {
      const lawyer = value as Lawyer;
      partners[index] = {
        ...partners[index],
        lawyer_id: lawyer.id,
        lawyer_name: `${lawyer.attributes.name} ${lawyer.attributes.last_name || ''}`.trim()
      };
    } else if (field === 'ownership_percentage' && partners.length === 2) {
      // For 2 partners, automatically adjust the other's percentage
      const newValue = parseFloat(value) || 0;
      partners[index] = { ...partners[index], ownership_percentage: newValue };
      partners[1 - index] = {
        ...partners[1 - index],
        ownership_percentage: Math.max(0, 100 - newValue)
      };
    } else {
      partners[index] = { ...partners[index], [field]: value };
    }

    onPartnerChange?.(index, field, value);
  }

  // Validate pro-labore amounts
  function validateProLabore(index: number, value: number) {
    const error = validateProLaboreAmount(value);
    proLaboreErrors[index] = error;
  }

  // Remove partner
  function removePartner(index: number) {
    partners = partners.filter((_, i) => i !== index);
    onRemovePartner?.(index);
  }

  // Add new partner
  function addPartner() {
    const newPartner: Partner = {
      lawyer_id: '',
      lawyer_name: '',
      partnership_type: '',
      ownership_percentage: partners.length === 0 ? 100 : 0,
      is_managing_partner: false,
      pro_labore_amount: 0
    };
    partners = [...partners, newPartner];
    onAddPartner?.();
  }

  // Check if can add more partners (based on available lawyers)
  const canAddMorePartners = $derived(
    lawyerStore.availableLawyers.length > partners.filter(p => p.lawyer_id).length
  );
</script>

<!-- Partnership Section -->
<FormSection title="Quadro Societário">
  {#snippet children()}
    {#if lawyerStore.loading}
      <div class="flex justify-center p-4">
        <span class="loading loading-spinner"></span>
      </div>
    {:else if partners.length > 0}
      {#each partners as partner, index}
        <div class="bg-base-200 rounded-lg p-4 mb-4">
          <div class="flex justify-between items-center mb-4">
            <h4 class="font-semibold">Sócio {index + 1}</h4>
            {#if partners.length > 1}
              <button
                class="btn btn-sm btn-error"
                onclick={() => removePartner(index)}
                type="button"
              >
                Remover
              </button>
            {/if}
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <PartnerLawyerSelect
              bind:value={partner.lawyer_id}
              availableLawyers={getAvailableLawyersForPartner(index)}
              id="partner-lawyer-{index}"
              onchange={(lawyer) => handlePartnerFieldChange(index, 'lawyer_id', lawyer)}
              required
            />

            <PartnershipType
              bind:value={partner.partnership_type}
              id="partner-type-{index}"
              onchange={(value) => handlePartnerFieldChange(index, 'partnership_type', value)}
            />

            {#if partners.length > 1}
              <OwnershipPercentage
                bind:value={partner.ownership_percentage}
                id="partner-percentage-{index}"
                showRangeSlider={partners.length === 2}
                onchange={(value) => handlePartnerFieldChange(index, 'ownership_percentage', value)}
              />
            {:else}
              <div></div>
            {/if}
          </div>

          {#if partner.partnership_type === 'socio'}
            <ManagingPartnerCheckbox
              bind:checked={partner.is_managing_partner}
              id="managing-partner-{index}"
              onchange={(checked) => handlePartnerFieldChange(index, 'is_managing_partner', checked)}
            />
          {/if}
        </div>
      {/each}
    {/if}

    <PercentageWarning
      totalPercentage={getTotalPercentage()}
      showWarning={checkIsOverPercentage()}
    />

    <div class="flex flex-col items-start">
      <button
        class="btn btn-outline"
        disabled={!canAddMorePartners}
        onclick={addPartner}
        type="button"
      >
        ➕ Adicionar Sócio
      </button>

      {#if !canAddMorePartners}
        <p class="text-sm text-gray-500 mt-2">
          Cadastre mais advogados para alterar seu quadro societário.
          <button type="button" class="link link-primary bg-transparent border-none p-0">
            Cadastrar novo usuário
          </button>
        </p>
      {/if}
    </div>
  {/snippet}
</FormSection>

<!-- Profit Distribution Section -->
<FormSection title="Distribuição de Lucros">
  {#snippet children()}
    <ProfitDistribution
      bind:value={profitDistribution}
      id="profit-distribution"
    />

    <ProfitDistributionInfo
      distributionType={profitDistribution}
      {partners}
    />
  {/snippet}
</FormSection>

<!-- Pro-Labore Section -->
<FormSection title="Pro-Labore">
  {#snippet children()}
    <ProLaboreCheckbox
      bind:checked={partnersWithProLabore}
    />

    {#if partnersWithProLabore}
      <ProLaboreInfo />

      <div class="space-y-4">
        <h4 class="font-semibold">Valores de Pro-Labore por Sócio:</h4>

        {#each partners as partner, index}
          {#if partner.lawyer_name}
            <ProLaboreInput
              partnerName={partner.lawyer_name}
              partnershipType={partner.partnership_type}
              bind:value={partner.pro_labore_amount}
              error={proLaboreErrors[index]}
              id="pro-labore-{index}"
              onchange={(value) => {
                handlePartnerFieldChange(index, 'pro_labore_amount', value);
                validateProLabore(index, value);
              }}
            />
          {/if}
        {/each}

        {#if partners.filter((p) => p.lawyer_name).length === 0}
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
            <span>Adicione e selecione sócios para definir os valores de pro-labore.</span>
          </div>
        {/if}
      </div>
    {/if}
  {/snippet}
</FormSection>