<script lang="ts">
  import OfficeBasicInformation from '../../components/forms_commons_wrappers/OfficeBasicInformation.svelte';
  import AddressCepWrapper from '../../components/forms_commons_wrappers/AddressCepWrapper.svelte';
  import OabInformation from '../../components/forms_commons_wrappers/OabInformation.svelte';
  import PartnershipManagement from '../../components/forms_offices_wrappers/PartnershipManagement.svelte';
  import OfficeQuotesWrapper from '../../components/forms_offices_wrappers/OfficeQuotesWrapper.svelte';
  import Phone from '../../components/forms_commons/Phone.svelte';
  import Email from '../../components/forms_commons/Email.svelte';
  import Bank from '../../components/forms_commons/Bank.svelte';
  import FileUpload from '../../components/forms_commons/FileUpload.svelte';
  import { newOfficeStore } from '../../stores/newOfficeStore.svelte';
  import { lawyerStore } from '../../stores/lawyerStore.svelte';
  import type { FormValidationConfig } from '../../schemas/new-office-form';
  import type { PartnerFormData } from '../../api/types/office.types';

  let newOfficeParam = $state(false);
  let urlParams = $state({});

  let oabData = $state({
    oab_id: newOfficeStore.formData.oab_id || '',
    oab_status: newOfficeStore.formData.oab_status || '',
    oab_link: newOfficeStore.formData.oab_link || ''
  });

  let partners = $state<PartnerFormData[]>(newOfficeStore.formData.partners || []);
  let partnersWithProLabore = $state(newOfficeStore.formData.partnersWithProLabore);
  let proLaboreErrors = $state({});

  let logoFiles = $state<File[]>([]);
  
  $effect(() => {
    newOfficeStore.updateField('logoFile', logoFiles[0] || null);
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

  async function handleSubmit(event: Event) {
    event.preventDefault(); 
    try {
      const result = await newOfficeStore.saveNewOffice();
      if (result) {
        console.log('Office created successfully:', result);
      }
    } catch (error) {
      console.error('Error creating office:', error);
    }
  }

  function resetForm() {
    newOfficeStore.resetForm();
    logoFiles = [];
  }

  function handleValidationConfigChange(config: FormValidationConfig) {
    newOfficeStore.setValidationConfig(config);
  }

  function addPhone() {
    newOfficeStore.formData.phones = [...newOfficeStore.formData.phones, ''];
  }

  function removePhone(index: number) {
     newOfficeStore.formData.phones = newOfficeStore.formData.phones.filter(
        (_, i) => i !== index
      );
  }
</script>

<form class="space-y-6 p-6" on:submit={handleSubmit}>
  <div class="mb-8">
    <h2 class="text-3xl font-bold text-[#01013D]">
        {newOfficeParam ? 'Criar Novo Escritório' : 'Criar Escritório'}
    </h2>
    <div class="h-1 w-20 bg-gradient-to-r from-[#0277EE] to-[#01013D] mt-3 rounded-full"></div>
  </div>

  <div class="space-y-6">
    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
      <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2"></path></svg>
          </div>
          <h3 class="text-lg font-semibold text-white">Dados Básicos do Escritório</h3>
        </div>
      </div>
      <div class="p-6 space-y-4">
        <OfficeBasicInformation
          bind:formData={newOfficeStore.formData}
          cnpjDisabled={newOfficeParam}
          cnpjRequired={!newOfficeParam}
          foundationDisabled={newOfficeParam}
          onValidationConfigChange={handleValidationConfigChange}
        />
        <FileUpload
          bind:files={logoFiles}
          id="logo-upload"
          labelText="Logo do Escritório"
          accept="image/jpeg, image/png, image/gif, image/webp"
          hint="Formatos aceitos: JPG, PNG, GIF, WEBP."
          multiple={false}
        />
      </div>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
            <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Configuração de Cotas</h3>
            </div>
        </div>
        <div class="p-6">
            <OfficeQuotesWrapper
                bind:proportional={newOfficeStore.formData.proportional}
                bind:quoteValue={newOfficeStore.formData.quote_value}
                bind:numberOfQuotes={newOfficeStore.formData.number_of_quotes}
                onProportionalChange={(value) => newOfficeStore.updateField('proportional', value)}
                onQuoteValueChange={(value) => newOfficeStore.updateField('quote_value', value)}
                onNumberOfQuotesChange={(value) => newOfficeStore.updateField('number_of_quotes', value)}
            />
        </div>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
            <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path></svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Endereço e Contato</h3>
            </div>
        </div>
        <div class="p-6 space-y-4">
            <AddressCepWrapper
                bind:address={newOfficeStore.formData.address}
                bind:cepValue={newOfficeStore.formData.address.zip_code}
                config={{
                    cep: { id: 'office-cep', labelText: 'CEP', required: false },
                    address: { id: 'office-address', required: false, showRemoveButton: false }
                }}
                useAPIValidation={true}
                showAddressInfo={false}
            />
            <Email
                bind:value={newOfficeStore.formData.email}
                labelText="E-mail do Escritório"
                placeholder="contato@escritorio.com"
                id="office-email"
            />
             <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Telefone(s)</label>
                {#each newOfficeStore.formData.phones as phone, index}
                  <div class="flex items-center gap-2 mb-2">
                    <div class="flex-grow">
                      <Phone bind:value={newOfficeStore.formData.phones[index]} />
                    </div>
                    {#if newOfficeStore.formData.phones.length > 1}
                      <button
                        type="button"
                        class="w-8 h-8 flex-shrink-0 flex items-center justify-center bg-red-100 rounded-full hover:bg-red-200 text-red-700"
                        on:click={() => removePhone(index)}
                        aria-label="Remover telefone"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
                      </button>
                    {/if}
                  </div>
                {/each}
                <button
                  type="button"
                  class="text-sm font-medium text-[#0277EE] hover:text-[#01013D] transition-colors duration-200 mt-1"
                  on:click={addPhone}
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
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Informações da OAB</h3>
            </div>
        </div>
        <div class="p-6">
            <OabInformation bind:formData={oabData} />
        </div>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>
                </div>
                <h3 class="text-lg font-semibold text-white">Dados Bancários</h3>
                <span class="ml-auto text-xs text-white/70 bg-white/20 px-3 py-1 rounded-full">Opcional</span>
            </div>
        </div>
        <div class="p-6">
            <Bank
                bind:bankAccount={newOfficeStore.formData.bank_account}
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
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.653-.125-1.274-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.653.125-1.274.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
                </div>
                <h3 class="text-lg font-semibold text-white">Gerenciamento de Sócios</h3>
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
                    onAddPartner={() => {}}
                    onRemovePartner={(index) => {}}
                />
            </div>
        </div>
    {/if}

    {#if !newOfficeParam}
      <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
          <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
              <div class="flex items-center gap-3">
              <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
              </div>
              <h3 class="text-lg font-semibold text-white">Contrato Social</h3>
              <span class="ml-auto text-xs text-white/70 bg-white/20 px-3 py-1 rounded-full">Opcional</span>
              </div>
          </div>
          <div class="p-6">
              <FileUpload
                  bind:files={newOfficeStore.formData.contractFiles}
                  id="contract-upload"
                  labelText="Upload de Contrato Social"
                  accept=".pdf,.docx,application/pdf,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                  hint="Anexe um ou mais contratos em PDF ou DOCX."
                  multiple={true}
              />
          </div>
      </div>
    {/if}
  </div>

  <div class="flex justify-end gap-3 pt-6 border-t border-[#eef0ef]">
    <button
      type="button"
      class="px-6 py-3 rounded-lg border border-gray-300 text-[#01013D] font-medium hover:bg-gray-50 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
      on:click={resetForm}
      disabled={newOfficeStore.formState.saving}
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
        <span>Salvando...</span>
      {:else}
        Criar Escritório
      {/if}
    </button>
  </div>

  {#if newOfficeStore.formState.success}
    <div class="bg-emerald-50 border-l-4 border-emerald-500 rounded-r-lg p-4 shadow-sm">
      <div class="flex items-start gap-3">
        <div class="flex-shrink-0">
          <svg class="w-5 h-5 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        </div>
        <div class="flex-1">
          <h4 class="text-sm font-semibold text-emerald-800 mb-1">
            Sucesso
          </h4>
          <p class="text-sm text-emerald-700">{newOfficeStore.formState.success}</p>
        </div>
      </div>
    </div>
  {/if}

  {#if newOfficeStore.formState.error}
    <div class="bg-red-50 border-l-4 border-red-500 rounded-r-lg p-4 shadow-sm">
      <div class="flex items-start gap-3">
        <div class="flex-shrink-0">
          <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        </div>
        <div class="flex-1">
          <h4 class="text-sm font-semibold text-red-800 mb-1">
            Ocorreu um Erro
          </h4>
          <p class="text-sm text-red-700">{newOfficeStore.formState.error}</p>
        </div>
      </div>
    </div>
  {/if}

  {#if !newOfficeStore.isValid && newOfficeStore.isDirty}
    <div class="bg-amber-50 border-l-4 border-amber-500 rounded-r-lg p-4 shadow-sm">
      <div class="flex items-start gap-3">
        <div class="flex-shrink-0">
          <svg class="w-5 h-5 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"></path></svg>
        </div>
        <div class="flex-1">
          <h4 class="text-sm font-semibold text-amber-800 mb-2">
            Erros de Validação
          </h4>
          <ul class="space-y-1.5">
            {#each newOfficeStore.getValidationErrors() as error, index}
              <li class="text-sm text-amber-700 flex items-start gap-2">
                <span class="text-amber-500 mt-0.5">•</span>
                <span>{error}</span>
              </li>
            {/each}
          </ul>
        </div>
      </div>
    </div>
  {/if}
</form>