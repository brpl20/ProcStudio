<script lang="ts">
  import OfficeBasicInformation from '../../components/forms_commons_wrappers/OfficeBasicInformation.svelte';
  import AddressCepWrapper from '../../components/forms_commons_wrappers/AddressCepWrapper.svelte';
  import OabInformation from '../../components/forms_commons_wrappers/OabInformation.svelte';
  import PartnershipManagement from '../../components/forms_offices_wrappers/PartnershipManagement.svelte';
  import OfficeQuotesWrapper from '../../components/forms_offices_wrappers/OfficeQuotesWrapper.svelte';
  import SocialContractCheckbox from '../../components/forms_offices/SocialContractCheckbox.svelte';
  import Phone from '../../components/forms_commons/Phone.svelte';
  import Email from '../../components/forms_commons/Email.svelte';
  import Bank from '../../components/forms_commons/Bank.svelte';
  import { newOfficeStore } from '../../stores/newOfficeStore.svelte';
  import { lawyerStore } from '../../stores/lawyerStore.svelte';
  import type { FormValidationConfig } from '../../schemas/new-office-form';
  import type { PartnerFormData } from '../../api/types/office.types';

  import FileUpload from '../../components/forms_commons/FileUpload.svelte';


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

  
  let logoFiles = $state<File[]>([]);
  let socialContractFiles = $state<File[]>([]);

  $effect(() => {
    const file = logoFiles[0] || null;
    if (newOfficeStore.formData.logo_file !== file) {
      newOfficeStore.updateField('logo_file', file);
    }
  });

  $effect(() => {
    // Evita atualizações desnecessárias se os arquivos não mudaram.
    if (newOfficeStore.formData.social_contract_files !== socialContractFiles) {
        newOfficeStore.updateField('social_contract_files', socialContractFiles);
    }
  });


  $effect(() => {
    newOfficeStore.updatePartners(partners);
  });

  $effect(() => {
    newOfficeStore.updateField('partnersWithProLabore', partnersWithProLabore);
  });

  $effect(() => {
    newOfficeStore.updateField('oab_id', oabData.oab_id);
    newOfficeStore.updateField('oab_status', oabData.oab_status);
    newOfficeStore.updateField('oab_link', oabData.oab_link);
  });

  function initializeUrlParams() {
    if (typeof window !== 'undefined') {
      const params = new URLSearchParams(window.location.search);
      newOfficeParam = params.get('new_office') === 'true';

      urlParams = {};
      for (const [key, value] of params.entries()) {
        urlParams[key] = value;
      }
    }
  }

  initializeUrlParams();

  $effect(() => {
    if (!lawyerStore.initialized) {
      lawyerStore.init();
    }

    return () => {
      lawyerStore.cancel();
    };
  });

  async function handleSubmit() {
    try {
      const result = await newOfficeStore.saveNewOffice();
      if (result) {
       
        logoFiles = [];
        socialContractFiles = [];
      }
    } catch (error) {
      console.error('Error creating office:', error);
    }
  }

  function resetForm() {
    newOfficeStore.resetForm();
    logoFiles = [];
    socialContractFiles = [];
  }

  function handleValidationConfigChange(config: FormValidationConfig) {
    newOfficeStore.setValidationConfig(config);
  }
</script>

<div class="container mx-auto p-6">
  <div class="mb-8">
    <h2 class="text-3xl font-bold text-[#01013D]">
      {newOfficeParam ? 'Criar Novo Escritório' : 'Criar Escritório'}
    </h2>
    <div class="h-1 w-20 bg-gradient-to-r from-[#0277EE] to-[#01013D] mt-3 rounded-full"></div>
  </div>

  <form class="space-y-6" on:submit|preventDefault={handleSubmit}>
    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Informações Básicas</h3>
          </div>
        </div>
        <div class="p-6">
          <OfficeBasicInformation
            bind:formData={newOfficeStore.formData}
            cnpjDisabled={newOfficeParam}
            cnpjRequired={!newOfficeParam}
            foundationDisabled={newOfficeParam}
            onValidationConfigChange={handleValidationConfigChange}
          />

          
          <div class="mt-4">
              <FileUpload
                  bind:files={logoFiles}
                  labelText="Logo do Escritório"
                  accept="image/png, image/jpeg, image/webp"
                  multiple={false}
                  preview={true}
                  hint="Envie o logo em formato PNG, JPG ou WEBP."
                  id="office-logo"
              />
          </div>

        </div>
      </div>

    <OfficeQuotesWrapper
      bind:proportional={newOfficeStore.formData.proportional}
      bind:quoteValue={newOfficeStore.formData.quote_value}
      bind:numberOfQuotes={newOfficeStore.formData.number_of_quotes}
      onProportionalChange={(value) => newOfficeStore.updateField('proportional', value)}
      onQuoteValueChange={(value) => newOfficeStore.updateField('quote_value', value)}
      onNumberOfQuotesChange={(value) => newOfficeStore.updateField('number_of_quotes', value)}
    />

    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Endereço do Escritório</h3>
          </div>
        </div>
        <div class="p-6">
            <AddressCepWrapper
                bind:address={newOfficeStore.formData.address}
                bind:cepValue={newOfficeStore.formData.address.zip_code}
                title=""
                config={{
                    cep: { id: 'office-cep', labelText: 'CEP', required: false },
                    address: { id: 'office-address', required: false, showRemoveButton: false }
                }}
                useAPIValidation={true}
                showAddressInfo={false}
            />
        </div>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"></path></svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Informações da OAB</h3>
          </div>
        </div>
        <div class="p-6">
            <OabInformation bind:formData={oabData} title="" />
        </div>
    </div>
    
    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/></svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Informações de Contato</h3>
          </div>
        </div>
        <div class="p-6 space-y-4">
            <Email
                bind:value={newOfficeStore.formData.email}
                labelText="E-mail do Escritório"
                placeholder="contato@escritorio.com"
                id="office-email"
            />
            <div>
                <label class="block text-sm font-medium text-[#01013D] mb-2" for="office-phone-0">Telefone(s)</label>
                {#each newOfficeStore.formData.phones as phone, index}
                    <div class="flex items-center gap-2 mb-2">
                        <Phone bind:value={newOfficeStore.formData.phones[index]} id={`office-phone-${index}`} />
                        {#if newOfficeStore.formData.phones.length > 1}
                            <button
                                type="button"
                                class="w-8 h-8 flex-shrink-0 flex items-center justify-center bg-red-100 rounded-lg hover:bg-red-200 text-red-600 transition-colors"
                                on:click={() => {
                                    newOfficeStore.formData.phones = newOfficeStore.formData.phones.filter((_, i) => i !== index);
                                }}
                                aria-label="Remover telefone"
                            >
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                            </button>
                        {/if}
                    </div>
                {/each}
                 <button
                    type="button"
                    class="px-4 py-2 mt-2 text-sm rounded-lg border border-gray-300 text-[#01013D] font-medium hover:bg-gray-50 transition-colors duration-200 disabled:opacity-50"
                    on:click={() => {
                        newOfficeStore.formData.phones = [...newOfficeStore.formData.phones, ''];
                    }}
                >
                    + Adicionar Telefone
                </button>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/></svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Informações Bancárias</h3>
          </div>
        </div>
        <div class="p-6">
            <Bank
                bind:bankAccount={newOfficeStore.formData.bank_account}
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
        </div>
    </div>

    {#if newOfficeStore.isQuoteConfigValid}
        <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
            <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.653-.124-1.282-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.653.124-1.282.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
                </div>
                <h3 class="text-lg font-semibold text-white">Gestão de Sócios</h3>
              </div>
            </div>
            <div class="p-6">
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
                />
            </div>
        </div>
    {/if}

    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Contrato Social</h3>
          </div>
        </div>
        <div class="p-6 space-y-4">
            <SocialContractCheckbox bind:checked={newOfficeStore.formData.create_social_contract} />

           
            <div>
              <FileUpload
                bind:files={socialContractFiles}
                labelText="Upload do Contrato Social"
                accept=".pdf"
                multiple={true}
                hint="Você pode enviar um ou mais arquivos PDF."
                id="social-contract-pdf"
              />
            </div>
        </div>
    </div>
    
    {#if newOfficeStore.formState.success}
        <div class="bg-green-50 border border-green-200 rounded-lg p-4 flex items-start gap-3">
            <svg class="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            <div>
                <h4 class="font-semibold text-green-900">Sucesso</h4>
                <p class="text-sm text-green-700">{newOfficeStore.formState.success}</p>
            </div>
        </div>
    {/if}

    {#if newOfficeStore.formState.error}
        <div class="bg-red-50 border border-red-200 rounded-lg p-4 flex items-start gap-3">
            <svg class="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            <div>
                <h4 class="font-semibold text-red-900">Ocorreu um Erro</h4>
                <p class="text-sm text-red-700">{newOfficeStore.formState.error}</p>
            </div>
        </div>
    {/if}

    {#if !newOfficeStore.isValid && newOfficeStore.isDirty}
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 flex items-start gap-3">
            <svg class="w-5 h-5 text-yellow-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"></path></svg>
            <div>
                <h4 class="font-bold text-yellow-900">Erros de Validação:</h4>
                <ul class="list-disc list-inside text-sm mt-1 text-yellow-700">
                    {#each newOfficeStore.getValidationErrors() as error}
                    <li>{error}</li>
                    {/each}
                </ul>
            </div>
        </div>
    {/if}

    <div class="flex justify-end gap-3 pt-6 border-t border-[#eef0ef]">
        <button
            type="button"
            class="px-6 py-3 rounded-lg border border-gray-300 text-[#01013D] font-medium hover:bg-gray-50 transition-colors duration-200"
            on:click={resetForm}
        >
            Limpar
        </button>
        <button
            type="submit"
            class="px-6 py-3 rounded-lg bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-medium hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
            disabled={!newOfficeStore.canSubmit || newOfficeStore.formState.saving}
        >
            {#if newOfficeStore.formState.saving}
                <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Salvando...
            {:else}
                Criar Escritório
            {/if}
        </button>
    </div>
  </form>
</div>