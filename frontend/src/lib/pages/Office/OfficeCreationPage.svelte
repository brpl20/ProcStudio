<script lang="ts">
  import { RenderScan } from 'svelte-render-scan';
  import OfficeBasicInformation from '../../components/forms_commons_wrappers/OfficeBasicInformation.svelte';
  import AddressCepWrapper from '../../components/forms_commons_wrappers/AddressCepWrapper.svelte';
  import OabInformation from '../../components/forms_commons_wrappers/OabInformation.svelte';
  import PartnershipManagement from '../../components/forms_offices_wrappers/PartnershipManagement.svelte';
  import OfficeQuotesWrapper from '../../components/forms_offices_wrappers/OfficeQuotesWrapper.svelte';
  import SocialContractCheckbox from '../../components/forms_offices/SocialContractCheckbox.svelte';
  import FormSection from '../../components/ui/FormSection.svelte';
  import Phone from '../../components/forms_commons/Phone.svelte';
  import Email from '../../components/forms_commons/Email.svelte';
  import Bank from '../../components/forms_commons/Bank.svelte';
  import { newOfficeStore } from '../../stores/newOfficeStore.svelte';
  import { lawyerStore } from '../../stores/lawyerStore.svelte';
  import type { FormValidationConfig } from '../../schemas/new-office-form';
  import type { PartnerFormData } from '../../api/types/office.types';

  // URL parameter handling
  let newOfficeParam = $state(false);
  let urlParams = $state({});

  // OAB data that syncs with the store
  let oabData = $state({
    oab_id: newOfficeStore.formData.oab_id || '',
    oab_status: newOfficeStore.formData.oab_status || '',
    oab_link: newOfficeStore.formData.oab_link || ''
  });

  // Partnership data - synced with store
  let partners = $state<PartnerFormData[]>(newOfficeStore.formData.partners || []);
  let partnersWithProLabore = $state(newOfficeStore.formData.partnersWithProLabore);
  let proLaboreErrors = $state({});
  
  // Sync partners back to store
  $effect(() => {
    newOfficeStore.updatePartners(partners);
  });
  
  $effect(() => {
    newOfficeStore.updateField('partnersWithProLabore', partnersWithProLabore);
  });

  // Sync OAB data changes back to the store
  $effect(() => {
    newOfficeStore.updateField('oab_id', oabData.oab_id);
    newOfficeStore.updateField('oab_status', oabData.oab_status);
    newOfficeStore.updateField('oab_link', oabData.oab_link);
  });

  // Initialize URL parameters
  function initializeUrlParams() {
    if (typeof window !== 'undefined') {
      const params = new URLSearchParams(window.location.search);
      newOfficeParam = params.get('new_office') === 'true';

      // Store all URL parameters for debug
      urlParams = {};
      for (const [key, value] of params.entries()) {
        urlParams[key] = value;
      }
    }
  }

  // Initialize on component mount
  initializeUrlParams();

  // Initialize lawyer store once for all child components
  $effect(() => {
    if (!lawyerStore.initialized) {
      lawyerStore.init();
    }
    
    return () => {
      // Cleanup on unmount if needed
      lawyerStore.cancel();
    };
  });

  // Debug tracking with derived state (no effects to avoid loops)
  let renderCount = $state(0);
  let lastUpdate = $state('');

  // Simple render tracking without effects
  function updateRenderInfo() {
    renderCount++;
    lastUpdate = new Date().toISOString();
  }

  // Handle form submission
  async function handleSubmit() {
    try {
      updateRenderInfo();
      const result = await newOfficeStore.saveNewOffice();
      if (result) {
        console.log('Office created successfully:', result);
      }
    } catch (error) {
      console.error('Error creating office:', error);
    }
  }

  // Reset function with render tracking
  function resetForm() {
    newOfficeStore.resetForm();
    updateRenderInfo();
  }

  // Handle validation configuration changes from wrapper
  function handleValidationConfigChange(config: FormValidationConfig) {
    newOfficeStore.setValidationConfig(config);
    updateRenderInfo();
  }
</script>

<RenderScan />

<div class="container mx-auto p-6">
  <h1 class="text-2xl font-bold mb-6">
    {newOfficeParam ? 'Criar Novo Escritório' : 'Criar Escritório'}
    {#if newOfficeParam}
      <span class="badge badge-primary ml-2">Novo</span>
    {/if}
  </h1>

  <form
    onsubmit={(e) => {
      e.preventDefault();
      handleSubmit();
    }}
  >
    <!-- Basic Information -->
    <OfficeBasicInformation
      bind:formData={newOfficeStore.formData}
      cnpjDisabled={newOfficeParam}
      cnpjRequired={!newOfficeParam}
      foundationDisabled={newOfficeParam}
      onValidationConfigChange={handleValidationConfigChange}
    />

    <!-- Quote Configuration (Required for Partners) -->
    <OfficeQuotesWrapper
      bind:proportional={newOfficeStore.formData.proportional}
      bind:quoteValue={newOfficeStore.formData.quote_value}
      bind:numberOfQuotes={newOfficeStore.formData.number_of_quotes}
      onProportionalChange={(value) => newOfficeStore.updateField('proportional', value)}
      onQuoteValueChange={(value) => newOfficeStore.updateField('quote_value', value)}
      onNumberOfQuotesChange={(value) => newOfficeStore.updateField('number_of_quotes', value)}
    />
    
    <!-- Address Information -->
    <AddressCepWrapper
      bind:address={newOfficeStore.formData.address}
      bind:cepValue={newOfficeStore.formData.address.zip_code}
      title="Endereço do Escritório"
      config={{
        cep: {
          id: 'office-cep',
          labelText: 'CEP',
          required: false
        },
        address: {
          id: 'office-address',
          required: false,
          showRemoveButton: false
        }
      }}
      useAPIValidation={true}
      showAddressInfo={false}
    />

    <!-- OAB Information -->
    <OabInformation bind:formData={oabData} title="Informações da OAB" />
    
    <!-- Contact Information -->
    <FormSection title="Informações de Contato">
      {#snippet children()}
        <!-- Email -->
        <div class="mb-4">
          <Email
            bind:value={newOfficeStore.formData.email}
            labelText="E-mail do Escritório"
            placeholder="contato@escritorio.com"
            id="office-email"
          />
        </div>
        
        <!-- Phone -->
        <div class="mb-4">
          <label class="label pb-1">
            <span class="label-text">Telefone</span>
          </label>
          {#each newOfficeStore.formData.phones as phone, index}
            <div class="flex gap-2 mb-2">
              <Phone bind:value={newOfficeStore.formData.phones[index]} />
              {#if newOfficeStore.formData.phones.length > 1}
                <button
                  type="button"
                  class="btn btn-sm btn-error"
                  onclick={() => {
                    newOfficeStore.formData.phones = newOfficeStore.formData.phones.filter((_, i) => i !== index);
                  }}
                >
                  Remover
                </button>
              {/if}
            </div>
          {/each}
          <button
            type="button"
            class="btn btn-sm btn-outline"
            onclick={() => {
              newOfficeStore.formData.phones = [...newOfficeStore.formData.phones, ''];
            }}
          >
            + Adicionar Telefone
          </button>
        </div>
      {/snippet}
    </FormSection>
    
    <!-- Bank Information -->
    <FormSection title="Informações Bancárias">
      {#snippet children()}
        <Bank
          bind:bankAccount={newOfficeStore.formData.bank_account}
          index={0}
          showRemoveButton={false}
          showPixHelpers={true}
          pixHelperData={{
            email: newOfficeStore.formData.email || '',
            cpf: '',
            cnpj: newOfficeStore.formData.cnpj || '',
            phone: newOfficeStore.formData.phones[0] || ''
          }}
          pixDocumentType="cnpj"
          on:remove={() => {
            // Bank is not removable for office
          }}
        />
      {/snippet}
    </FormSection>

    <!-- Partnership Management (Only enabled after quote configuration) -->
    {#if newOfficeStore.isQuoteConfigValid}
      <PartnershipManagement 
        bind:partners={partners}
        bind:partnersWithProLabore={partnersWithProLabore}
        bind:proLaboreErrors={proLaboreErrors}
        lawyers={lawyerStore.activeLawyers}
        lawyersLoading={lawyerStore.loading}
        lawyersError={lawyerStore.error}
        officeProportional={newOfficeStore.formData.proportional}
        officeQuoteValue={newOfficeStore.formData.quote_value}
        officeNumberOfQuotes={newOfficeStore.formData.number_of_quotes}
        officeSocietyType={newOfficeStore.formData.society}
        onPartnerChange={(index, field, value) => {
          if (partners[index]) {
            partners[index] = { ...partners[index], [field]: value };
          }
        }}
        onAddPartner={() => {
          const newPartner: PartnerFormData = {
            lawyer_id: '',
            lawyer_name: '',
            partnership_type: '',
            ownership_percentage: 0,
            is_managing_partner: false
          };
          partners = [...partners, newPartner];
        }}
        onRemovePartner={(index) => {
          partners = partners.filter((_, i) => i !== index);
        }}
      />
    {/if}
    
    <!-- Social Contract -->
    <FormSection title="Contrato Social">
      {#snippet children()}
        <SocialContractCheckbox bind:checked={newOfficeStore.formData.create_social_contract} />
      {/snippet}
    </FormSection>

    <!-- Form actions -->
    <div class="flex gap-4 mt-6">
      <button
        type="submit"
        class="btn btn-primary"
        disabled={!newOfficeStore.canSubmit}
        class:loading={newOfficeStore.formState.saving}
      >
        {newOfficeStore.formState.saving ? 'Salvando...' : 'Criar Escritório'}
      </button>

      <button type="button" class="btn btn-outline" onclick={resetForm}> Limpar </button>
    </div>

    <!-- Success/Error messages -->
    {#if newOfficeStore.formState.success}
      <div class="alert alert-success mt-4">
        {newOfficeStore.formState.success}
      </div>
    {/if}

    {#if newOfficeStore.formState.error}
      <div class="alert alert-error mt-4">
        {newOfficeStore.formState.error}
      </div>
    {/if}
    
    {#if !newOfficeStore.isValid && newOfficeStore.isDirty}
      <div class="alert alert-warning mt-4">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z" />
        </svg>
        <div>
          <div class="font-bold">Erros de Validação:</div>
          <ul class="list-disc list-inside text-sm mt-1">
            {#each newOfficeStore.getValidationErrors() as error}
              <li>{error}</li>
            {/each}
          </ul>
        </div>
      </div>
    {/if}
  </form>

  <!-- Debug Section -->
  <div class="mt-8 bg-gray-50 border rounded-lg p-4">
    <h3 class="text-lg font-semibold mb-3">Debug Information</h3>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Basic Debug Info -->
      <div class="space-y-4">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 text-sm">
          <div class="bg-white p-3 rounded">
            <strong>Form Valid:</strong>
            {newOfficeStore.isValid ? '✅' : '❌'}
          </div>
          <div class="bg-white p-3 rounded">
            <strong>Form Dirty:</strong>
            {newOfficeStore.isDirty ? '✅' : '❌'}
          </div>
          <div class="bg-white p-3 rounded">
            <strong>Can Submit:</strong>
            {newOfficeStore.canSubmit ? '✅' : '❌'}
          </div>
          <div class="bg-white p-3 rounded">
            <strong>New Office:</strong>
            {newOfficeParam ? '✅' : '❌'}
          </div>
        </div>

        <!-- URL Parameters Debug -->
        <div class="bg-blue-50 border border-blue-200 rounded p-3">
          <strong class="text-blue-700">URL Parameters:</strong>
          <div class="mt-2 space-y-1">
            <div class="text-sm">
              <strong>new_office:</strong>
              <span class="font-mono bg-white px-2 py-1 rounded">
                {newOfficeParam ? 'true' : 'false'}
              </span>
            </div>
            {#if Object.keys(urlParams).length > 0}
              <div class="text-sm">
                <strong>All Parameters:</strong>
                <pre class="text-xs bg-white p-2 rounded mt-1 overflow-auto">{JSON.stringify(
                    urlParams,
                    null,
                    2
                  )}</pre>
              </div>
            {:else}
              <div class="text-sm text-gray-500">No URL parameters found</div>
            {/if}
          </div>
        </div>

        {#if newOfficeStore.getValidationErrors().length > 0}
          <div class="bg-red-50 border border-red-200 rounded p-3">
            <strong class="text-red-700">Validation Errors:</strong>
            <ul class="list-disc list-inside text-red-600 mt-1">
              {#each newOfficeStore.getValidationErrors() as error}
                <li>{error}</li>
              {/each}
            </ul>
          </div>
        {/if}
      </div>

      <!-- Enhanced Debug Info -->
      <div class="space-y-4">
        <!-- Form Data -->
        <div class="bg-blue-50 border border-blue-200 rounded p-3">
          <h4 class="font-semibold text-blue-700 mb-2">1. Form Data</h4>
          <pre class="text-xs bg-white p-2 rounded overflow-auto max-h-32">{JSON.stringify(
              newOfficeStore.formData,
              null,
              2
            )}</pre>
        </div>

        <!-- Store Form Data -->
        <div class="bg-indigo-50 border border-indigo-200 rounded p-3">
          <h4 class="font-semibold text-indigo-700 mb-2">2. Store Form Data</h4>
          <pre class="text-xs bg-white p-2 rounded overflow-auto max-h-32">{JSON.stringify(
              newOfficeStore.formData,
              null,
              2
            )}</pre>
        </div>

        <!-- Store Debug Information -->
        <div class="bg-green-50 border border-green-200 rounded p-3">
          <h4 class="font-semibold text-green-700 mb-2">3. Store Debug Information</h4>
          <div class="text-xs space-y-1">
            <div><strong>Valid:</strong> {newOfficeStore.isValid ? 'true' : 'false'}</div>
            <div><strong>Dirty:</strong> {newOfficeStore.isDirty ? 'true' : 'false'}</div>
            <div><strong>Errors Count:</strong> {newOfficeStore.getValidationErrors().length}</div>
          </div>
        </div>

        <!-- Render Count -->
        <div class="bg-yellow-50 border border-yellow-200 rounded p-3">
          <h4 class="font-semibold text-yellow-700 mb-2">4. Render Count:</h4>
          <div class="text-sm font-mono">{renderCount}</div>
        </div>

        <!-- Last Update -->
        <div class="bg-purple-50 border border-purple-200 rounded p-3">
          <h4 class="font-semibold text-purple-700 mb-2">5. Last Update:</h4>
          <div class="text-xs font-mono">{lastUpdate}</div>
        </div>

        <!-- Store State -->
        <div class="bg-gray-50 border border-gray-200 rounded p-3">
          <h4 class="font-semibold text-gray-700 mb-2">Store State:</h4>
          <div class="text-xs space-y-1">
            <div><strong>Saving:</strong> {newOfficeStore.formState.saving}</div>
            <div><strong>Loading:</strong> {newOfficeStore.formState.loading}</div>
            <div><strong>Can Submit:</strong> {newOfficeStore.canSubmit}</div>
          </div>
        </div>

        <!-- Lawyer Store Info -->
        <div class="bg-green-50 border border-green-200 rounded p-3">
          <h4 class="font-semibold text-green-700 mb-2">🔍 Lawyer Store (Single Source of Truth):</h4>
          <div class="text-xs space-y-2">
            <div><strong>Total Lawyers:</strong> {lawyerStore.lawyersCount}</div>
            <div><strong>Active Lawyers:</strong> {lawyerStore.activeLawyers.length}</div>
            <div><strong>Available Lawyers:</strong> {lawyerStore.availableLawyers.length}</div>
            <div><strong>Selected Lawyers:</strong> {lawyerStore.selectedLawyers.length}</div>
            <div><strong>Loading:</strong> {lawyerStore.loading ? 'Yes' : 'No'}</div>
            <div><strong>Initialized:</strong> {lawyerStore.initialized ? 'Yes' : 'No'}</div>
            
            {#if lawyerStore.selectedLawyers.length > 0}
              <div class="mt-2 pt-2 border-t border-green-300">
                <strong>Selected Lawyers Details:</strong>
                <div class="mt-1 space-y-1">
                  {#each lawyerStore.selectedLawyers as lawyer, idx}
                    <div class="bg-white p-2 rounded text-xs">
                      <div><strong>#{idx + 1}:</strong> {lawyer.attributes.name} {lawyer.attributes.last_name || ''}</div>
                      <div class="text-gray-600">ID: {lawyer.id}</div>
                      <div class="text-gray-600">Status: {lawyer.attributes.status}</div>
                    </div>
                  {/each}
                </div>
              </div>
            {/if}
          </div>
        </div>
      </div>
    </div>

    <div class="mt-4 flex gap-2">
      <a href="/lawyers-test-debug" class="btn btn-info btn-sm"> 🐛 Go to Debug Page </a>
      <button class="btn btn-outline btn-sm" onclick={updateRenderInfo}>
        Update Render Count
      </button>
      <button
        class="btn btn-outline btn-sm"
        onclick={() =>
          console.log('Debug State:', {
            renderCount,
            lastUpdate,
            newOfficeParam,
            urlParams,
            formData: newOfficeStore.formData,
            formState: newOfficeStore.formState,
            lawyerStore: {
              total: lawyerStore.lawyersCount,
              active: lawyerStore.activeLawyers.length,
              selected: lawyerStore.selectedLawyers.length,
              loading: lawyerStore.loading,
              initialized: lawyerStore.initialized
            }
          })}
      >
        Log Debug State
      </button>
    </div>
  </div>
</div>
