<script lang="ts">
  import { untrack } from 'svelte';
  import FormSection from '../ui/FormSection.svelte';
  import SingleLawyerPartner from '../forms_offices/SingleLawyerPartner.svelte';
  import SingleLawyerProLabore from '../forms_offices/SingleLawyerProLabore.svelte';
  import PartnerLawyerSelect from '../forms_offices/PartnerLawyerSelect.svelte';
  import PartnershipType from '../forms_offices/PartnershipType.svelte';
  import OwnershipPercentage from '../forms_offices/OwnershipPercentage.svelte';
  import ManagingPartnerCheckbox from '../forms_offices/ManagingPartnerCheckbox.svelte';
  import PercentageWarning from '../forms_offices/PercentageWarning.svelte';
  import ProLaboreCheckbox from '../forms_offices/ProLaboreCheckbox.svelte';
  import ProLaboreInfo from '../forms_offices/ProLaboreInfo.svelte';
  import ProLaboreInput from '../forms_offices/ProLaboreInput.svelte';
  import type { Lawyer } from '../../api/types/user.lawyer';
  import { validateProLaboreAmount } from '../../validation';
  import { getFullName } from '../../utils/lawyer.utils';
  import { lawyerStore } from '../../stores/lawyerStore.svelte';

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
    partnersWithProLabore: boolean;
    proLaboreErrors?: { [key: number]: string | null };
    lawyers?: Lawyer[];
    lawyersLoading?: boolean;
    lawyersError?: string | null;
    // Office-level configuration
    officeProportional?: boolean;
    officeQuoteValue?: number;
    officeNumberOfQuotes?: number;
    officeSocietyType?: string;
    // Callbacks
    onPartnerChange?: (index: number, field: string, value: any) => void;
    onAddPartner?: () => void;
    onRemovePartner?: (index: number) => void;
  };

  let {
    partners = $bindable([]),
    partnersWithProLabore = $bindable(false),
    proLaboreErrors = $bindable({}),
    lawyers = [],
    lawyersLoading = false,
    lawyersError = null,
    officeProportional = true,
    officeQuoteValue = 0,
    officeNumberOfQuotes = 0,
    officeSocietyType = '',
    onPartnerChange,
    onAddPartner,
    onRemovePartner
  }: Props = $props();


  // Derived state for single lawyer scenario
  const isSingleLawyer = $derived(lawyers.length === 1);
  const singleLawyer = $derived(isSingleLawyer ? lawyers[0] : null);
  
  // Check if society type is individual
  const isIndividualSociety = $derived(officeSocietyType === 'individual');
  const maxPartnersAllowed = $derived(isIndividualSociety ? 1 : Infinity);

  // Auto-setup for single lawyer
  $effect(() => {
    if (isSingleLawyer && singleLawyer && partners.length === 0) {
      const newPartner: Partner = {
        lawyer_id: singleLawyer.id,
        lawyer_name:
          `${singleLawyer.attributes.name} ${singleLawyer.attributes.last_name || ''}`.trim(),
        partnership_type: 'socio',
        ownership_percentage: 100,
        is_managing_partner: true,
        pro_labore_amount: 0
      };
      partners = [newPartner];
    }
  });
  
  // Sync LawyerStore with partner selections
  // Track only partners array changes, not store changes
  let lastSyncedIds = $state<string[]>([]);
  
  $effect(() => {
    // Extract lawyer_id and ensure it's a string
    const selectedIds = partners
      .map(p => {
        const id = p.lawyer_id;
        // Handle case where lawyer_id might be an object instead of string
        if (typeof id === 'object' && id !== null && 'id' in id) {
          console.warn('⚠️ lawyer_id is an object, extracting id:', id);
          return (id as any).id;
        }
        return id;
      })
      .filter(id => typeof id === 'string' && id.length > 0);
    
    // Only update if the IDs actually changed
    const idsChanged = JSON.stringify(selectedIds.sort()) !== JSON.stringify(lastSyncedIds.sort());
    
    if (idsChanged) {
      console.log('🔵 [PartnershipManagement] $effect running - selectedIds:', selectedIds);
      console.log('🔵 [PartnershipManagement] partners:', partners.map(p => ({ lawyer_id: p.lawyer_id, lawyer_name: p.lawyer_name })));
      
      lastSyncedIds = [...selectedIds];
      
      // Use untrack to prevent reading from store triggering this effect
      untrack(() => {
        lawyerStore.clearSelectedLawyers();
        
        selectedIds.forEach(lawyerId => {
          console.log('🔍 Looking for lawyer with ID:', lawyerId, 'Type:', typeof lawyerId);
          const lawyer = lawyers.find(l => l.id === lawyerId);
          if (lawyer) {
            console.log('✅ [PartnershipManagement] Selecting lawyer:', lawyer.attributes.name, lawyer.id);
            lawyerStore.selectLawyer(lawyer);
          } else {
            console.log('❌ [PartnershipManagement] Lawyer NOT FOUND for ID:', lawyerId);
            console.log('❌ Available lawyer IDs:', lawyers.map(l => l.id));
          }
        });
        
        console.log('🔵 [PartnershipManagement] Sync complete');
      });
    }
  });

  // Calculate total percentage
  function getTotalPercentage(): number {
    return partners.reduce((sum, p) => sum + (p.ownership_percentage || 0), 0);
  }

  // Check if percentage is over 100
  function checkIsOverPercentage(): boolean {
    return getTotalPercentage() > 100;
  }

  // Get all selected lawyer IDs except for the current index
  function getSelectedLawyerIds(excludeIndex: number = -1): string[] {
    return partners
      .filter((_, i) => i !== excludeIndex)
      .map((p) => {
        const id = p.lawyer_id;
        // Extract string ID if it's an object
        if (typeof id === 'object' && id !== null && 'id' in id) {
          return (id as any).id;
        }
        return id;
      })
      .filter((id): id is string => typeof id === 'string' && id.length > 0);
  }

  // Handle partner field changes
  function handlePartnerFieldChange(index: number, field: string, value: any) {
    console.log('🟡 [handlePartnerFieldChange] Called:', { index, field, value });
    
    if (field === 'lawyer_id' && value) {
      const lawyer = value as Lawyer;
      const lawyerId = typeof lawyer === 'string' ? lawyer : lawyer.id;
      const lawyerName = typeof lawyer === 'string' 
        ? '' 
        : `${lawyer.attributes.name} ${lawyer.attributes.last_name || ''}`.trim();
      
      console.log('🟡 [handlePartnerFieldChange] Extracting - ID:', lawyerId, 'Name:', lawyerName);
      
      const updatedPartner = {
        ...partners[index],
        lawyer_id: lawyerId,  // Ensure it's always a string
        lawyer_name: lawyerName
      };
      partners = [...partners.slice(0, index), updatedPartner, ...partners.slice(index + 1)];
      console.log('🟡 [handlePartnerFieldChange] Updated partner:', updatedPartner);
    } else if (field === 'ownership_percentage' && partners.length === 2) {
      // For 2 partners, automatically adjust the other's percentage
      const newValue = parseFloat(value) || 0;
      const updated = [...partners];
      updated[index] = { ...updated[index], ownership_percentage: newValue };
      updated[1 - index] = {
        ...updated[1 - index],
        ownership_percentage: Math.max(0, 100 - newValue)
      };
      partners = updated;
    } else {
      const updated = [...partners];
      updated[index] = { ...updated[index], [field]: value };
      partners = updated;
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

  // Check if can add more partners (based on available lawyers and society type)
  const canAddMorePartners = $derived(
    !isSingleLawyer &&
      lawyers.length > partners.filter((p) => p.lawyer_id).length &&
      partners.length < maxPartnersAllowed
  );
  
  // Calculate quotas for each partner based on percentage
  function calculatePartnerQuotas(percentage: number): number {
    if (officeNumberOfQuotes === 0) return 0;
    return Math.floor((percentage / 100) * officeNumberOfQuotes);
  }
  
  // Check if office is configured
  const isOfficeConfigured = $derived(
    officeQuoteValue > 0 && officeNumberOfQuotes > 0
  );
  
  // Debug pro-labore changes
  $effect(() => {
    console.log('🟠 [PartnershipManagement] partnersWithProLabore changed:', partnersWithProLabore);
  });
  
  // Calculate total pro-labore
  function getTotalProLabore(): number {
    return partners.reduce((sum, p) => sum + (p.pro_labore_amount || 0), 0);
  }
  
  // Format currency
  function formatCurrency(val: number): string {
    return val.toLocaleString('pt-BR', { 
      minimumFractionDigits: 2, 
      maximumFractionDigits: 2 
    });
  }
</script>

<!-- DEBUG PANEL -->
<div class="bg-yellow-100 border-2 border-yellow-500 rounded p-4 mb-4">
  <h3 class="font-bold text-yellow-800 mb-2">🔍 Partnership Management Debug</h3>
  <div class="grid grid-cols-2 gap-4 text-xs">
    <div class="bg-white p-2 rounded">
      <strong>Partners Array ({partners.length}):</strong>
      <pre class="mt-1 text-xs overflow-auto max-h-32">{JSON.stringify(partners.map(p => ({ lawyer_id: p.lawyer_id, lawyer_name: p.lawyer_name, raw: p })), null, 2)}</pre>
    </div>
    <div class="bg-white p-2 rounded">
      <strong>Lawyers Prop ({lawyers.length}):</strong>
      <pre class="mt-1 text-xs overflow-auto max-h-32">{JSON.stringify(lawyers.map(l => ({ id: l.id, name: l.attributes.name })), null, 2)}</pre>
    </div>
    <div class="bg-white p-2 rounded">
      <strong>LawyerStore Selected ({lawyerStore.selectedLawyers.length}):</strong>
      <pre class="mt-1 text-xs overflow-auto max-h-32">{JSON.stringify(lawyerStore.selectedLawyers.map(l => ({ id: l.id, name: l.attributes.name })), null, 2)}</pre>
    </div>
    <div class="bg-white p-2 rounded">
      <strong>LawyerStore Available ({lawyerStore.availableLawyers.length}):</strong>
      <pre class="mt-1 text-xs overflow-auto max-h-32">{JSON.stringify(lawyerStore.availableLawyers.map(l => ({ id: l.id, name: l.attributes.name })), null, 2)}</pre>
    </div>
  </div>
</div>

<!-- Partnership Section -->
<FormSection title="Quadro Societário">
  {#snippet children()}
    {#if lawyersLoading}
      <div class="flex justify-center p-4">
        <span class="loading loading-spinner"></span>
      </div>
    {:else if lawyersError}
      <div class="alert alert-error">
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
        <span>Erro ao carregar advogados: {lawyersError}</span>
      </div>
    {:else}
      {#if isSingleLawyer && singleLawyer}
        <!-- Show single lawyer info -->
        <SingleLawyerPartner lawyer={singleLawyer} />
      {/if}

      {#if !isSingleLawyer && partners.length > 0}
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
                value={typeof partner.lawyer_id === 'string' ? partner.lawyer_id : (partner.lawyer_id?.id || '')}
                allLawyers={lawyers}
                selectedByOthers={getSelectedLawyerIds(index)}
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
                  onchange={(value) =>
                    handlePartnerFieldChange(index, 'ownership_percentage', value)}
                />
              {:else}
                <div></div>
              {/if}
            </div>

            {#if partner.partnership_type === 'socio'}
              <ManagingPartnerCheckbox
                bind:checked={partner.is_managing_partner}
                id="managing-partner-{index}"
                onchange={(checked) =>
                  handlePartnerFieldChange(index, 'is_managing_partner', checked)}
              />
            {/if}
          </div>
        {/each}
      {/if}

      {#if !isSingleLawyer}
        <PercentageWarning
          totalPercentage={getTotalPercentage()}
          showWarning={checkIsOverPercentage()}
        />
      {/if}
    {/if}

    {#if !isSingleLawyer}
      <div class="flex flex-col items-start">
        <button
          class="btn btn-outline"
          disabled={!canAddMorePartners || !isOfficeConfigured}
          onclick={addPartner}
          type="button"
        >
          Adicionar Sócio
        </button>

        {#if isIndividualSociety && partners.length >= 1}
          <div class="alert alert-warning mt-2">
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
            <span>Mude o tipo societário para selecionar múltiplos advogados</span>
          </div>
        {:else if !canAddMorePartners && lawyers.length <= partners.filter((p) => p.lawyer_id).length}
          <p class="text-sm text-gray-500 mt-2">
            Cadastre mais advogados para alterar seu quadro societário.
            <button type="button" class="link link-primary bg-transparent border-none p-0">
              Cadastrar novo usuário
            </button>
          </p>
        {/if}
      </div>
    {:else}
      <p class="text-sm text-gray-500">
        Cadastre mais advogados para habilitar o quadro societário.
        <button type="button" class="link link-primary bg-transparent border-none p-0">
          Cadastrar novo usuário
        </button>
      </p>
    {/if}
  {/snippet}
</FormSection>

<!-- Quota Distribution Section -->
<FormSection title="Distribuição de Cotas">
  {#snippet children()}
    {#if isOfficeConfigured}
      <div class="alert alert-info mb-4">
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
          <div class="font-bold">Configuração do Capital Social</div>
          <div class="text-sm mt-1">
            <div>Total de cotas: <strong>{officeNumberOfQuotes}</strong></div>
            <div>Valor por cota: <strong>R$ {officeQuoteValue.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</strong></div>
            <div>Capital total: <strong>R$ {(officeQuoteValue * officeNumberOfQuotes).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</strong></div>
            <div class="mt-2">Distribuição: <strong>{officeProportional ? 'Proporcional' : 'Desproporcional'}</strong></div>
          </div>
        </div>
      </div>
      
      {#if partners.length > 0}
        <div class="space-y-2">
          <h4 class="font-semibold">Distribuição de Cotas por Sócio:</h4>
          {#each partners as partner}
            {#if partner.lawyer_name}
              <div class="flex justify-between items-center p-2 bg-base-100 rounded">
                <span>{partner.lawyer_name}</span>
                <div class="text-right">
                  <div class="font-bold">{partner.ownership_percentage}%</div>
                  <div class="text-sm text-gray-500">
                    {calculatePartnerQuotas(partner.ownership_percentage)} cotas
                  </div>
                </div>
              </div>
            {/if}
          {/each}
        </div>
      {/if}
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
        <span>Configure o capital social e as cotas do escritório antes de adicionar sócios.</span>
      </div>
    {/if}
  {/snippet}
</FormSection>

<!-- Pro-Labore Section -->
<FormSection title="Pro-Labore">
  {#snippet children()}
    <!-- Debug -->
    <div class="text-xs bg-orange-100 p-2 rounded mb-2">
      partnersWithProLabore: {partnersWithProLabore ? 'true' : 'false'}
    </div>
    
    <ProLaboreCheckbox bind:checked={partnersWithProLabore} />

    {#if partnersWithProLabore}
      {#if !isSingleLawyer}
        <ProLaboreInfo />

        <div class="space-y-4">
          <h4 class="font-semibold">Valores de Pro-Labore por Sócio:</h4>

          {#each partners as partner, index}
            {#if partner.lawyer_name}
              <ProLaboreInput
                partnerName={partner.lawyer_name}
                partnershipType={partner.partnership_type}
                value={partner.pro_labore_amount || 0}
                error={proLaboreErrors[index]}
                id="pro-labore-{index}"
                tip="valor mensal pela prestação dos serviços"
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
          
          <!-- Pro-Labore Summary -->
          {#if partners.filter((p) => p.lawyer_name && p.pro_labore_amount > 0).length > 0}
            <div class="mt-4 p-4 bg-base-200 rounded-lg">
              <div class="flex justify-between items-center">
                <span class="font-semibold">Total Pro-Labore Mensal:</span>
                <span class="text-lg font-bold text-primary">
                  R$ {formatCurrency(getTotalProLabore())}
                </span>
              </div>
              {#if getTotalProLabore() > 0}
                <div class="text-sm text-gray-600 mt-2">
                  Custo anual estimado: R$ {formatCurrency(getTotalProLabore() * 13.33)}
                  <span class="text-xs">(incluindo 13º e férias)</span>
                </div>
              {/if}
            </div>
          {/if}
        </div>
      {:else if singleLawyer}
        <SingleLawyerProLabore
          lawyerName={getFullName(singleLawyer)}
          value={partners[0]?.pro_labore_amount || 0}
          onchange={(value) => {
            if (partners[0]) {
              handlePartnerFieldChange(0, 'pro_labore_amount', value);
            }
          }}
        />
        
        <!-- Pro-Labore Summary for Single Lawyer -->
        {#if partners[0]?.pro_labore_amount > 0}
          <div class="mt-4 p-4 bg-base-200 rounded-lg">
            <div class="flex justify-between items-center">
              <span class="font-semibold">Total Pro-Labore Mensal:</span>
              <span class="text-lg font-bold text-primary">
                R$ {formatCurrency(partners[0].pro_labore_amount)}
              </span>
            </div>
            <div class="text-sm text-gray-600 mt-2">
              Custo anual estimado: R$ {formatCurrency(partners[0].pro_labore_amount * 13.33)}
              <span class="text-xs">(incluindo 13º e férias)</span>
            </div>
          </div>
        {/if}
      {/if}
    {/if}
  {/snippet}
</FormSection>
