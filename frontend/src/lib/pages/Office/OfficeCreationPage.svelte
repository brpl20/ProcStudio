<script lang="ts">
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
        // Office created successfully
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
                    newOfficeStore.formData.phones = newOfficeStore.formData.phones.filter(
                      (_, i) => i !== index
                    );
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
        />
      {/snippet}
    </FormSection>

    <!-- Partnership Management (Only enabled after quote configuration) -->
    {#if newOfficeStore.isQuoteConfigValid}
      <PartnershipManagement
        bind:partners
        bind:partnersWithProLabore
        bind:proLaboreErrors
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
          // Partner addition is handled internally by PartnershipManagement
        }}
        onRemovePartner={(index) => {
          // Partner removal is handled internally by PartnershipManagement
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
</div>
