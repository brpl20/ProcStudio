<script lang="ts">
  import { onMount } from 'svelte';
  import api from '../../api';
  import Cnpj from '../forms_commons/Cnpj.svelte';
  import Address from '../forms_commons/Address.svelte';
  import Cep from '../forms_commons/Cep.svelte';
  import Phone from '../forms_commons/Phone.svelte';
  import Email from '../forms_commons/Email.svelte';
  import Bank from '../forms_commons/Bank.svelte';
  import SocietyBasicInformation from '../forms_commons_wrappers/SocietyBasicInformation.svelte';
  import OabInformation from '../forms_commons_wrappers/OabInformation.svelte';
  import { createCepAddressHandler } from '../../utils/cep-address-mapper';

  // Import the new Svelte 5 store
  import { officeFormLawyersStore } from '../../stores/officeFormStore.svelte';

  import {
    PARTNERSHIP_TYPES,
    getCurrentInssConstants
  } from '../../constants/formOptions';
  import { validateProLaboreAmount } from '../../validation';
  import FormSection from '../ui/FormSection.svelte';
  import {
    createDefaultOfficeFormData,
    createDefaultPartner,
    transformFromOffice,
    validateOfficeForm,
    calculateTotalPercentage,
    isOverPercentage,
    type OfficeFormData,
    type PartnerFormData
  } from '../../schemas/office-form';
  import {
    adjustPartnerPercentages,
    validatePartners,
    submitOfficeForm
  } from '../../utils/office-form-processor';

  let {
    office = null,
    onClose = () => {},
    onSuccess = () => {}
  }: {
    office?: any;
    onClose?: () => void;
    onSuccess?: () => void;
  } = $props();

  const isEdit = $derived(!!office);

  // Use typed form data from schema
  let formData = $state<OfficeFormData>(createDefaultOfficeFormData());

  let logoFile = $state(null);
  let contractFiles = $state([]);
  let logoPreview = $state(null);
  let loading = $state(false);
  let error = $state(null);
  let success = $state(null);

  // Partnership management - using typed data
  let partners = $state<PartnerFormData[]>([createDefaultPartner(true)]);
  let profitDistribution = $state<'proportional' | 'disproportional'>('proportional');
  let createSocialContract = $state(false);
  let partnersWithProLabore = $state(true);
  const { minimumWage, inssCeiling } = getCurrentInssConstants();
  let proLaboreErrors = $state<Record<number, string>>({});

  // Direct access to store - no need for $derived or subscriptions
  const store = officeFormLawyersStore;

  // Create a reactive computation for available lawyers per partner
  const availableLawyersPerPartner = $derived.by(() => {
    if (!store.lawyers || !Array.isArray(store.lawyers)) {
      return [];
    }

    // Create an array of available lawyers for each partner index
    return partners.map((_, partnerIndex) => {
      // Get all selected lawyer IDs except for the current partner index
      const selectedIds = partners
        .filter((_, index) => index !== partnerIndex)
        .map((p) => p.lawyer_id)
        .filter((id) => id && id !== '');

      // Return lawyers that are not selected by other partners
      // Convert both to strings for comparison
      return store.lawyers.filter(
        (lawyer) => !selectedIds.some((selectedId) => String(selectedId) === String(lawyer.id))
      );
    });
  });

  function handleClose() {
    onClose();
  }

  function handleLogoChange(event) {
    const file = event.target.files?.[0];
    if (file) {
      logoFile = file;
      // Create preview
      const reader = new FileReader();
      reader.onload = (e) => {
        logoPreview = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }

  function handleContractsChange(event) {
    const files = Array.from(event.target.files || []);
    contractFiles = files;
  }

  // Partnership management functions
  function handlePartnerChange(index: number, field: keyof PartnerFormData, value: any) {
    if (field === 'lawyer_id' && value && typeof value === 'object') {
      // Create a new partners array to trigger reactivity
      const newPartners = [...partners];
      newPartners[index] = {
        ...newPartners[index],
        lawyer_id: value.id,
        lawyer_name: `${value.attributes.name} ${value.attributes.last_name}`
      };
      partners = newPartners;
    } else if (field === 'ownership_percentage') {
      const newPercentage = Math.max(0, Math.min(100, Number(value) || 0));
      partners = adjustPartnerPercentages(partners, index, newPercentage);
    } else if (field === 'pro_labore_amount') {
      const amount = Number(value) || 0;
      const error = validateProLaboreAmount(amount);

      // Update errors
      if (error) {
        proLaboreErrors[index] = error;
      } else {
        delete proLaboreErrors[index];
      }
      proLaboreErrors = { ...proLaboreErrors };

      const newPartners = [...partners];
      newPartners[index] = { ...newPartners[index], pro_labore_amount: amount };
      partners = newPartners;
    } else {
      const newPartners = [...partners];
      newPartners[index] = { ...newPartners[index], [field]: value };
      partners = newPartners;
    }
  }

  function addPartner() {
    if (!store.canAddMorePartners(partners.length)) {
      return;
    }

    // If adding second partner, split 50/50
    if (partners.length === 1) {
      partners[0] = { ...partners[0], ownership_percentage: 50 };
    }

    // Add new partner
    const newPartner = createDefaultPartner();
    newPartner.ownership_percentage = partners.length === 1 ? 50 : 0;
    partners = [...partners, newPartner];
  }

  function removePartner(index) {
    if (partners.length === 1) {
      return;
    }

    // Remove the partner from the array
    partners = partners.filter((_, i) => i !== index);

    // Adjust percentages if now 2 partners
    if (partners.length === 2) {
      partners = partners.map((partner, i) => ({
        ...partner,
        ownership_percentage: 50
      }));
    }
  }

  function getTotalPercentage() {
    return calculateTotalPercentage(partners);
  }

  function checkIsOverPercentage() {
    return isOverPercentage(partners);
  }

  // Generic add/remove functions
  function createAddFunction(attributeName, defaultValue) {
    return () => {
      formData[attributeName] = [...formData[attributeName], defaultValue];
    };
  }

  function createRemoveFunction(attributeName) {
    return (index) => {
      if (formData[attributeName].length > 1) {
        formData[attributeName] = formData[attributeName].filter((_, i) => i !== index);
      }
    };
  }

  // Specific add/remove functions using the generic pattern
  const addPhone = createAddFunction('phones_attributes', { phone_number: '' });
  const removePhone = createRemoveFunction('phones_attributes');

  const addEmail = createAddFunction('emails_attributes', { email: '' });
  const removeEmail = createRemoveFunction('emails_attributes');

  const addAddress = createAddFunction('addresses_attributes', {
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    zip_code: '',
    address_type: 'secondary'
  });
  const removeAddress = createRemoveFunction('addresses_attributes');

  // Create CEP address handler using utility
  const handleAddressFound = createCepAddressHandler((mappedAddress) => {
    if (formData.addresses_attributes.length > 0) {
      formData.addresses_attributes[0] = {
        ...formData.addresses_attributes[0],
        ...mappedAddress
      };
    }
  });

  // Keep zip_code in sync between CEP field and first address
  $effect(() => {
    if (formData.zip_code && formData.addresses_attributes.length > 0) {
      formData.addresses_attributes[0].zip_code = formData.zip_code;
    }
  });

  const addBankAccount = createAddFunction('bank_accounts_attributes', {
    bank_name: '',
    type_account: '',
    agency: '',
    account: '',
    operation: '',
    pix: ''
  });
  const removeBankAccount = createRemoveFunction('bank_accounts_attributes');

  async function handleSubmit() {
    try {
      loading = true;
      error = null;
      success = null;

      // Validate form
      const validationErrors = validateOfficeForm(formData, partners);
      if (validationErrors.length > 0) {
        error = validationErrors.join(', ');
        return;
      }

      // Validate partners
      const partnerValidation = validatePartners(partners);
      if (!partnerValidation.isValid) {
        error = partnerValidation.errors.join(', ');
        return;
      }

      // Submit form using the processor
      const response = await submitOfficeForm(
        formData,
        partners,
        profitDistribution,
        createSocialContract,
        partnersWithProLabore,
        logoFile,
        contractFiles,
        isEdit ? office.id : undefined
      );

      if (response.success) {
        success = response.message || `Escritório ${isEdit ? 'atualizado' : 'criado'} com sucesso!`;
        setTimeout(() => {
          onSuccess();
        }, 1500);
      } else {
        error = response.message || 'Erro ao salvar escritório';
      }
    } catch (err: any) {
      // Error logged to user via error state
      error = err.message || 'Erro ao salvar escritório';
    } finally {
      loading = false;
    }
  }

  onMount(async () => {
    try {
      // Load lawyers using the store - always try to load to ensure fresh data
      await store.loadLawyers();

      // Wait a tick to ensure stores are updated
      await new Promise((resolve) => setTimeout(resolve, 0));

      // Stores are now reactive and will update automatically
    } catch (error) {
      // Error loading lawyers
    }

    if (office) {
      // Populate form with existing data using transformer
      formData = transformFromOffice(office);

      if (office.logo_url) {
        logoPreview = office.logo_url;
      }

      // Initialize partners store with existing selections if any
      if (office.user_offices?.length > 0) {
        const lawyerIds = office.user_offices.map((uo) => uo.user_id).filter((id) => id);
        store.setAllPartners(lawyerIds);
      }
    }

    // Stores are reactive and will update automatically
  });
</script>

<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
  <div class="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto">
    <!-- Header -->
    <div
      class="sticky top-0 bg-white border-b border-gray-200 p-6 flex justify-between items-center"
    >
      <h2 class="text-2xl font-bold text-gray-900">
        {isEdit ? 'Editar Escritório' : 'Novo Escritório'}
      </h2>
      <button class="btn btn-ghost btn-circle" onclick={handleClose}>✕</button>
    </div>

    <!-- Form Content -->
    <div class="p-6 space-y-8">
      {#if success}
        <div class="alert alert-success">
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
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>{success}</span>
        </div>
      {/if}

      {#if error}
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
              d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>{error}</span>
        </div>
      {/if}

      <!-- Basic Information -->
      <BasicInformation bind:formData={formData} title="Informações Básicas" showSite={true} />

      <!-- OAB Information -->
      <OabInformation bind:formData={formData} />

      <!-- Financial Information -->
      <FormSection title="Informações Financeiras">
        {#snippet children()}
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="form-control flex flex-col">
              <label class="label pb-1" for="office-quote-value">
                <span class="label-text">Valor da Cota</span>
              </label>
              <input
                id="office-quote-value"
                type="number"
                class="input input-bordered w-full"
                bind:value={formData.quote_value}
                placeholder="0.00"
                step="0.01"
                min="0"
              />
            </div>

            <div class="form-control flex flex-col">
              <label class="label pb-1" for="office-number-quotes">
                <span class="label-text">Número de Cotas</span>
              </label>
              <input
                id="office-number-quotes"
                type="number"
                class="input input-bordered w-full"
                bind:value={formData.number_of_quotes}
                placeholder="0"
                min="0"
              />
            </div>
          </div>
        {/snippet}
      </FormSection>

      <!-- Phones -->
      <FormSection title="Telefones">
        {#snippet children()}
          <div class="flex justify-end mb-4">
            <button class="btn btn-outline btn-sm" onclick={addPhone}>➕ Adicionar</button>
          </div>

          {#each formData.phones_attributes as phone, index (index)}
            <div class="flex gap-2 mb-2">
              <div class="flex-1">
                <Phone bind:value={formData.phones_attributes[index].phone_number} />
              </div>
              {#if formData.phones_attributes.length > 1}
                <button class="btn btn-error btn-sm" onclick={() => removePhone(index)}>🗑️</button>
              {/if}
            </div>
          {/each}
        {/snippet}
      </FormSection>

      <!-- Emails -->
      <FormSection title="E-mails">
        {#snippet children()}
          <div class="flex justify-end mb-4">
            <button class="btn btn-outline btn-sm" onclick={addEmail}>➕ Adicionar</button>
          </div>

          {#each formData.emails_attributes as email, index (index)}
            <div class="flex gap-2 mb-2">
              <div class="flex-1">
                <Email
                  bind:value={formData.emails_attributes[index].email}
                  id="office-email-{index}"
                  labelText=""
                  placeholder="email@exemplo.com"
                />
              </div>
              {#if formData.emails_attributes.length > 1}
                <button class="btn btn-error btn-sm" onclick={() => removeEmail(index)}>🗑️</button>
              {/if}
            </div>
          {/each}
        {/snippet}
      </FormSection>

      <!-- Cep -->
      <h3 class="card-title text-lg font-semibold">Cep</h3>
      <Cep
        bind:value={formData.zip_code}
        id="office-zip_code"
        labelText={'CEP'}
        useAPIValidation={false}
        showAddressInfo={false}
        required={false}
        on:address-found={handleAddressFound}
      />

      <!-- Addresses -->
      <h3 class="card-title text-lg font-semibold">Endereços</h3>
      <button class="btn btn-outline btn-sm" onclick={addAddress} type="button">➕ Adicionar</button
      >
      {#each formData.addresses_attributes as address, idx (idx)}
        <Address
          bind:address={formData.addresses_attributes[idx]}
          index={idx}
          showRemoveButton={formData.addresses_attributes.length > 1}
          on:remove={() => removeAddress(idx)}
        />
      {/each}

      <!-- Bank Accounts -->
      <FormSection title="Contas Bancárias">
        {#snippet children()}
          <div class="flex justify-end mb-4">
            <button class="btn btn-outline btn-sm" onclick={addBankAccount}>➕ Adicionar</button>
          </div>
          {#each formData.bank_accounts_attributes as bankAccount, index (index)}
            <Bank
              bind:bankAccount={formData.bank_accounts_attributes[index]}
              {index}
              showRemoveButton={formData.bank_accounts_attributes.length > 1}
              showPixHelpers={true}
              pixDocumentType="cnpj"
              pixHelperData={{
                email: formData.emails_attributes[0]?.email || '',
                cpf: '',
                cnpj: formData.cnpj,
                phone: formData.phones_attributes[0]?.phone_number || ''
              }}
              labelPrefix="office-bank"
              on:remove={() => removeBankAccount(index)}
            />
          {/each}
        {/snippet}
      </FormSection>

      <!-- Partners Section - UPDATED -->
      <FormSection title="Sócios do Escritório">
        {#snippet children()}
          <!-- Loading/Error States -->
          {#if store.loading}
            <div class="alert alert-info mb-4">
              <span class="loading loading-spinner loading-sm"></span>
              <span>Carregando advogados...</span>
            </div>
          {:else if store.error}
            <div class="alert alert-error mb-4">
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
                  d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <span>Erro: {store.error}</span>
              <button class="btn btn-sm" onclick={() => store.loadLawyers()}
                >Tentar novamente</button
              >
            </div>
          {:else}
            <!-- Debug info -->
            <div class="alert alert-info mb-4">
              <div>
                <div class="text-sm">
                  <strong>Debug:</strong>
                  {store.lawyers.length} advogados carregados
                  {#if store.lawyers.length > 0}
                    <div class="mt-2">
                      {#each store.lawyers as lawyer, i}
                        <div class="text-xs">
                          {i + 1}: ID={lawyer.id}, Nome={lawyer.attributes?.name}
                          {lawyer.attributes?.last_name}
                        </div>
                      {/each}
                    </div>
                  {/if}
                </div>
              </div>
            </div>
          {/if}

          {#if !store.lawyers || store.lawyers.length === 0}
            <div class="alert alert-info">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                class="stroke-info shrink-0 w-6 h-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                ></path>
              </svg>
              <span>Cadastre um advogado para alterar seu quadro societário.</span>
            </div>
          {:else}
            {#each partners as partner, index (index)}
              <div class="border rounded-lg p-4 mb-4 bg-base-50">
                <div class="flex justify-between items-center mb-4">
                  <h4 class="font-semibold text-base">Sócio {index + 1}</h4>
                  {#if partners.length > 1}
                    <button class="btn btn-error btn-sm" onclick={() => removePartner(index)}>
                      🗑️
                    </button>
                  {/if}
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                  <!-- Lawyer Selection -->
                  <div class="form-control flex flex-col">
                    <label class="label pb-1" for="partner-lawyer-{index}">
                      <span class="label-text">Advogado</span>
                    </label>
                    <select
                      id="partner-lawyer-{index}"
                      class="select select-bordered w-full"
                      value={partner.lawyer_id}
                      onchange={(e) => {
                        const selectedLawyer = store.findById(e.target.value);
                        if (selectedLawyer) {
                          handlePartnerChange(index, 'lawyer_id', selectedLawyer);
                        }
                      }}
                    >
                      <option value="">Selecione o Advogado</option>
                      {#each availableLawyersPerPartner[index] || [] as lawyer}
                        <option value={lawyer.id}>
                          {store.getFullName(lawyer)}
                        </option>
                      {/each}
                    </select>
                  </div>

                  <!-- Partnership Type -->
                  <div class="form-control flex flex-col">
                    <label class="label pb-1" for="partner-type-{index}">
                      <span class="label-text">Função</span>
                    </label>
                    <select
                      bind:value={partners[index].partnership_type}
                      id="partner-type-{index}"
                      class="select select-bordered w-full"
                      onchange={(e) =>
                        handlePartnerChange(index, 'partnership_type', e.target.value)}
                    >
                      <option value="">Selecione a Função</option>
                      {#each PARTNERSHIP_TYPES as type}
                        <option value={type.value}>{type.label}</option>
                      {/each}
                    </select>
                  </div>

                  <!-- Ownership Percentage - Only show when more than one partner -->
                  {#if partners.length > 1}
                    <div class="form-control flex flex-col">
                      <label class="label pb-1" for="partner-percentage-{index}">
                        <span class="label-text">Participação (%)</span>
                      </label>
                      <div class="flex items-center gap-2">
                        <input
                          id="partner-percentage-{index}"
                          type="number"
                          class="input input-bordered w-20"
                          min="0"
                          max="100"
                          step="0.01"
                          bind:value={partners[index].ownership_percentage}
                          oninput={(e) =>
                            handlePartnerChange(index, 'ownership_percentage', e.target.value)}
                        />
                        <span>%</span>
                      </div>

                      <!-- Range slider for 2 partners -->
                      {#if partners.length === 2}
                        <div class="mt-2">
                          <label class="label" for="partner-range-{index}">
                            <span class="label-text-alt">Ajuste proporcional</span>
                          </label>
                          <input
                            id="partner-range-{index}"
                            type="range"
                            class="range range-sm"
                            min="0"
                            max="100"
                            bind:value={partner.ownership_percentage}
                            oninput={(e) =>
                              handlePartnerChange(index, 'ownership_percentage', e.target.value)}
                          />
                        </div>
                      {/if}
                    </div>
                  {:else}
                    <!-- Hidden placeholder to maintain grid layout -->
                    <div></div>
                  {/if}
                </div>

                <!-- Managing Partner checkbox for "socio" -->
                {#if partner.partnership_type === 'socio'}
                  <div class="form-control">
                    <label class="label cursor-pointer justify-start gap-2">
                      <input
                        type="checkbox"
                        class="checkbox checkbox-primary"
                        bind:checked={partners[index].is_managing_partner}
                        onchange={(e) =>
                          handlePartnerChange(index, 'is_managing_partner', e.target.checked)}
                      />
                      <span class="label-text">Sócio Administrador</span>
                    </label>
                  </div>
                {/if}
              </div>
            {/each}
          {/if}

          <!-- Percentage warning -->
          {#if checkIsOverPercentage()}
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
              <span
                >O total de participação ({getTotalPercentage()}%) excede 100%. Ajuste as
                porcentagens para que somem no máximo 100%.</span
              >
            </div>
          {/if}

          <!-- Add Partner Button -->
          <div class="flex flex-col items-start">
            <button
              class="btn btn-outline"
              disabled={!store.canAddMorePartners(partners.length)}
              onclick={addPartner}
            >
              ➕ Adicionar Sócio
            </button>

            {#if !store.canAddMorePartners(partners.length)}
              <p class="text-sm text-gray-500 mt-2">
                Cadastre mais advogados para alterar seu quadro societário.
                <button type="button" class="link link-primary bg-transparent border-none p-0"
                  >Cadastrar novo usuário</button
                >
              </p>
            {/if}
          </div>
        {/snippet}
      </FormSection>

      <!-- Profit Distribution Section -->
      <FormSection title="Distribuição de Lucros">
        {#snippet children()}
          <div class="form-control flex flex-col mb-4">
            <fieldset>
              <legend class="label pb-1">
                <span class="label-text">Como será a distribuição de lucros?</span>
              </legend>

              <div class="flex gap-6">
                <label class="label cursor-pointer">
                  <input
                    type="radio"
                    class="radio radio-primary"
                    bind:group={profitDistribution}
                    value="proportional"
                  />
                  <span class="label-text ml-2">Proporcional à participação</span>
                </label>

                <label class="label cursor-pointer">
                  <input
                    type="radio"
                    class="radio radio-primary"
                    bind:group={profitDistribution}
                    value="disproportional"
                  />
                  <span class="label-text ml-2">Desproporcional</span>
                </label>
              </div>
            </fieldset>
          </div>

          {#if profitDistribution === 'proportional'}
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
              <span
                >Distribuição desproporcional será definida de acordo com cada trabalho/processo.</span
              >
            </div>
          {/if}
        {/snippet}
      </FormSection>

      <!-- Social Contract Section -->
      <FormSection title="Contrato Social">
        {#snippet children()}
          <div class="form-control">
            <label class="label cursor-pointer justify-start gap-2">
              <input
                type="checkbox"
                class="checkbox checkbox-primary"
                bind:checked={createSocialContract}
              />
              <span class="label-text">Sim, desejo criar um contrato social</span>
            </label>
          </div>

          {#if createSocialContract}
            <div class="alert alert-info mt-4">
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
              <span>A lógica para criação do contrato social será implementada posteriormente.</span
              >
            </div>
          {/if}
        {/snippet}
      </FormSection>

      <!-- Pro-Labore Section -->
      <FormSection title="Pro-Labore">
        {#snippet children()}
          <div class="form-control mb-4">
            <label class="label cursor-pointer justify-start gap-2">
              <input
                type="checkbox"
                class="checkbox checkbox-primary"
                bind:checked={partnersWithProLabore}
              />
              <span class="label-text">Sim, os sócios retirarão pro-labore</span>
            </label>
          </div>

          {#if partnersWithProLabore}
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
                <div class="font-bold">Faixas de Valor:</div>
                <div class="text-sm mt-1">
                  <div>
                    • Salário Mínimo: R$ {minimumWage.toLocaleString('pt-BR', {
                      minimumFractionDigits: 2
                    })}
                  </div>
                  <div>
                    • Teto INSS: R$ {inssCeiling.toLocaleString('pt-BR', {
                      minimumFractionDigits: 2
                    })}
                  </div>
                  <div class="mt-1">Valor R$ 0,00 = sócio não receberá pro-labore</div>
                </div>
              </div>
            </div>

            <div class="space-y-4">
              <h4 class="font-semibold">Valores de Pro-Labore por Sócio:</h4>

              {#each partners as partner, index}
                {#if partner.lawyer_name}
                  <div class="border rounded p-4">
                    <div class="flex justify-between items-center mb-2">
                      <span class="font-bold">{partner.lawyer_name}</span>
                      <span class="text-sm text-gray-500">
                        {PARTNERSHIP_TYPES.find((t) => t.value === partner.partnership_type)
                          ?.label || partner.partnership_type}
                      </span>
                    </div>

                    <div class="flex items-center gap-2">
                      <span class="w-20">Pro-Labore:</span>
                      <span class="text-lg">R$</span>
                      <input
                        id="pro-labore-{index}"
                        type="number"
                        class="input input-bordered input-sm w-32"
                        min="0"
                        step="0.01"
                        bind:value={partners[index].pro_labore_amount}
                        oninput={(e) =>
                          handlePartnerChange(index, 'pro_labore_amount', e.target.value)}
                        class:input-error={proLaboreErrors[index]}
                      />
                    </div>

                    {#if proLaboreErrors[index]}
                      <div class="text-error text-sm mt-1">
                        ⚠️ {proLaboreErrors[index]}
                      </div>
                    {:else if partner.pro_labore_amount === 0}
                      <div class="text-success text-sm mt-1">
                        ✓ Este sócio não receberá pro-labore
                      </div>
                    {:else if partner.pro_labore_amount > 0}
                      <div class="text-success text-sm mt-1">✓ Valor válido</div>
                    {/if}
                  </div>
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

      <!-- File Attachments -->
      <FormSection title="Anexos">
        {#snippet children()}
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Logo -->
            <div class="form-control flex flex-col">
              <label class="label pb-1" for="office-logo">
                <span class="label-text">Logo do Escritório</span>
              </label>
              <input
                id="office-logo"
                type="file"
                class="file-input file-input-bordered w-full"
                accept="image/*"
                onchange={handleLogoChange}
              />
              {#if logoPreview}
                <div class="mt-2">
                  <img
                    src={logoPreview}
                    alt="Preview do logo"
                    class="w-24 h-24 object-cover rounded"
                  />
                </div>
              {/if}
              <div class="label">
                <span class="label-text-alt">Formatos aceitos: JPG, PNG, GIF, WEBP</span>
              </div>
            </div>

            <!-- Social Contracts -->
            <div class="form-control flex flex-col">
              <label class="label pb-1" for="office-contracts">
                <span class="label-text">Contratos Sociais</span>
              </label>
              <input
                id="office-contracts"
                type="file"
                class="file-input file-input-bordered w-full"
                accept=".pdf,.docx"
                multiple
                onchange={handleContractsChange}
              />
              {#if contractFiles.length > 0}
                <div class="mt-2 space-y-1">
                  {#each contractFiles as file}
                    <div class="badge badge-outline">{file.name}</div>
                  {/each}
                </div>
              {/if}
              <div class="label">
                <span class="label-text-alt">Formatos aceitos: PDF, DOCX</span>
              </div>
            </div>
          </div>
        {/snippet}
      </FormSection>
    </div>

    <!-- Footer -->
    <div class="sticky bottom-0 bg-white border-t border-gray-200 p-6 flex justify-end gap-4">
      <button class="btn btn-ghost" onclick={handleClose} disabled={loading}> Cancelar </button>
      <button class="btn btn-primary" onclick={handleSubmit} disabled={loading}>
        {#if loading}
          <span class="loading loading-spinner loading-sm"></span>
        {/if}
        {isEdit ? 'Atualizar' : 'Criar'} Escritório
      </button>
    </div>
  </div>
</div>
