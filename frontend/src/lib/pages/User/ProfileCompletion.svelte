<script lang="ts">
  import api from '../../api/index';

  // Import the new form components
  import Name from '../../components/forms_commons/Name.svelte';
  import LastName from '../../components/forms_commons/LastName.svelte';
  import Cpf from '../../components/forms_commons/Cpf.svelte';
  import Rg from '../../components/forms_commons/Rg.svelte';
  import Gender from '../../components/forms_commons/Gender.svelte';
  import Nationality from '../../components/forms_commons/Nationality.svelte';
  import CivilStatus from '../../components/forms_commons/CivilStatus.svelte';
  import Birth from '../../components/forms_commons/Birth.svelte';
  import Phone from '../../components/forms_commons/Phone.svelte';
  import AddressCepWrapper from '../../components/forms_commons_wrappers/AddressCepWrapper.svelte';
  import OabId from '../../components/forms_commons/OabId.svelte';
  import Bank from '../../components/forms_commons/Bank.svelte';

  export let isOpen = false;
  export let userData: any = {};
  export let missingFields: string[] = [];
  export let onComplete: (result: any) => void = () => {};
  export let onClose: () => void = () => {};

  const hasCriticalMissingFields =
    missingFields.includes('name') ||
    missingFields.includes('last_name') ||
    missingFields.includes('role') ||
    missingFields.includes('address');

  const formData = {
    name: userData.name || '',
    last_name: userData.last_name || '',
    role: userData.role || '',
    oab: userData.oab || '',
    cpf: '',
    rg: '',
    gender: userData.gender || '',
    civil_status: '',
    nationality: 'brazilian',
    birth: '',
    phone: '',
    address: {
      street: userData.address?.street || '',
      number: userData.address?.number || '',
      complement: '',
      neighborhood: userData.address?.neighborhood || '',
      city: userData.address?.city || '',
      state: userData.address?.state || '',
      zip_code: userData.address?.zip_code || '',
      address_type: 'main'
    },
    bank_account: {
      bank_name: '',
      bank_number: '',
      type_account: '',
      agency: '',
      account: '',
      operation: '',
      pix: ''
    }
  };

  if (userData.phone) {
    formData.phone = userData.phone;
  }

  let loading = false;
  let message = '';
  let isSuccess = false;

  let errors: Record<string, string | null> = {};
  let touched: Record<string, boolean> = {};

  const roleOptions = [
    { value: 'lawyer', label: 'Advogado(a)' }
  ];

  function isFieldRequired(fieldName: string): boolean {
    return missingFields.includes(fieldName);
  }

  function closeModal() {
    if (!loading) {
      onClose();
    }
  }

  function handleBackdropClick(event: MouseEvent) {
    if (event.target === event.currentTarget) {
      closeModal();
    }
  }

  async function handleSubmit() {
    const requiredFieldErrors: string[] = [];

    missingFields.forEach((field) => {
      if (field === 'address') {
        if (
          !formData.address.street ||
          !formData.address.number ||
          !formData.address.city ||
          !formData.address.state ||
          !formData.address.zip_code
        ) {
          requiredFieldErrors.push('endereço');
        }
      } else if (
        !formData[field as keyof typeof formData] ||
        (typeof formData[field as keyof typeof formData] === 'string' &&
          formData[field as keyof typeof formData].trim() === '')
      ) {
        requiredFieldErrors.push(field);
      }
    });

    if (requiredFieldErrors.length > 0) {
      message = `Campos obrigatórios não preenchidos: ${requiredFieldErrors.join(', ')}`;
      isSuccess = false;
      return;
    }

    loading = true;
    message = '';

    try {
      const dataToSend: any = {};

      Object.keys(formData).forEach((key) => {
        if (key !== 'address') {
          const value = formData[key as keyof typeof formData];
          if (value && typeof value === 'string' && value.trim() !== '') {
            dataToSend[key] = value.trim();
          }
        }
      });

      if (isFieldRequired('address') && formData.address.street) {
        dataToSend.addresses_attributes = [
          {
            street: formData.address.street,
            number: formData.address.number,
            complement: formData.address.complement || '',
            neighborhood: formData.address.neighborhood || '',
            city: formData.address.city,
            state: formData.address.state,
            zip_code: formData.address.zip_code
          }
        ];
      }

      if (formData.phone) {
        dataToSend.phones_attributes = [
          {
            phone_number: formData.phone
          }
        ];
      }

      if (formData.bank_account.bank_name && formData.bank_account.agency && formData.bank_account.account) {
        dataToSend.bank_accounts_attributes = [
          {
            bank_name: formData.bank_account.bank_name,
            bank_number: formData.bank_account.bank_number,
            account_type: formData.bank_account.type_account,
            agency: formData.bank_account.agency,
            account: formData.bank_account.account,
            operation: formData.bank_account.operation || '',
            pix: formData.bank_account.pix || ''
          }
        ];
      }

      const result = await api.auth.completeProfile(dataToSend);
      message = 'Perfil completado com sucesso!';
      isSuccess = true;

      setTimeout(() => {
        onComplete(result);
      }, 1500);
    } catch (error: any) {
      message = error.message || 'Erro ao completar perfil';
      isSuccess = false;
    } finally {
      loading = false;
    }
  }
</script>

{#if isOpen}
  <div
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"
    onclick={handleBackdropClick}
    role="button"
    tabindex="0"
    onkeydown={(e) => e.key === 'Escape' && closeModal()}
  >
    <div class="bg-white rounded-xl shadow-2xl max-w-5xl max-h-[90vh] overflow-y-auto w-full mx-4" role="dialog" aria-modal="true">
      <div class="space-y-6 p-6">
        <div class="mb-8">
          <h2 class="text-3xl font-bold text-[#01013D]">
            {hasCriticalMissingFields ? 'Complete seu Cadastro' : 'Complete seu Perfil'}
          </h2>
          <div class="h-1 w-20 bg-gradient-to-r from-[#01013D] to-[#01013D] mt-3 rounded-full"></div>
        </div>

        {#if userData.oab || userData.name || userData.email}
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div class="flex items-start gap-3">
              <svg class="w-5 h-5 text-blue-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <div class="flex-1">
                <div class="font-semibold text-blue-900">Informações do Usuário</div>
                <div class="text-sm text-blue-800 mt-2 space-y-1">
                  {#if userData.name}
                    <p><strong>Nome:</strong> {userData.name} {userData.last_name || ''}</p>
                  {/if}
                  {#if userData.email}
                    <p><strong>E-mail:</strong> {userData.email}</p>
                  {/if}
                  {#if userData.oab}
                    <p><strong>OAB:</strong> {userData.oab}</p>
                  {/if}
                  {#if userData.role}
                    <p><strong>Função:</strong> {userData.role}</p>
                  {/if}
                </div>
              </div>
            </div>
          </div>
        {/if}

        {#if hasCriticalMissingFields}
          <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 flex items-start gap-3">
            <svg class="w-5 h-5 text-yellow-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
            </svg>
            <div>
              <h4 class="font-semibold text-yellow-900">Atenção</h4>
              <p class="text-sm text-yellow-800">Alguns dados não foram preenchidos automaticamente. Por favor, complete as informações manualmente.</p>
            </div>
          </div>
        {/if}

        <form onsubmit={(e) => {
 e.preventDefault(); handleSubmit();
}}>
          <div class="space-y-6">
            {#if isFieldRequired('name') || isFieldRequired('last_name') || isFieldRequired('role') || ((formData.role === 'lawyer' || userData.role === 'lawyer') && (isFieldRequired('oab') || !userData.oab))}
              <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
                <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                      <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                      </svg>
                    </div>
                    <h3 class="text-lg font-semibold text-white">Dados Básicos</h3>
                  </div>
                </div>
                <div class="p-6">
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {#if isFieldRequired('name')}
                      <Name
                        bind:value={formData.name}
                        required={true}
                        disabled={loading}
                      />
                    {/if}

                    {#if isFieldRequired('last_name')}
                      <LastName
                        bind:value={formData.last_name}
                        required={true}
                        disabled={loading}
                      />
                    {/if}

                    {#if isFieldRequired('role')}
                      <div class="form-control">
                        <label class="block text-sm font-medium text-[#01013D] mb-2" for="role">
                          <span>Função *</span>
                        </label>
                        <select
                          id="role"
                          class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:border-[#01013D] focus:ring-2 focus:ring-[#01013D]/20 outline-none transition-all duration-200 text-[#01013D]"
                          bind:value={formData.role}
                          required
                          disabled={loading}
                        >
                          <option value="">Selecione...</option>
                          {#each roleOptions as option}
                            <option value={option.value}>{option.label}</option>
                          {/each}
                        </select>
                      </div>
                    {/if}

                    {#if (formData.role === 'lawyer' || userData.role === 'lawyer') && (isFieldRequired('oab') || !userData.oab)}
                      <OabId
                        bind:value={formData.oab}
                        type="lawyer"
                        required={formData.role === 'lawyer'}
                        disabled={loading}
                      />
                    {/if}
                  </div>
                </div>
              </div>
            {/if}

            {#if isFieldRequired('cpf') || isFieldRequired('rg') || isFieldRequired('gender') || isFieldRequired('civil_status') || isFieldRequired('nationality') || isFieldRequired('birth')}
              <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
                <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                      <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2"/>
                      </svg>
                    </div>
                    <h3 class="text-lg font-semibold text-white">Informações Pessoais</h3>
                  </div>
                </div>
                <div class="p-6">
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {#if isFieldRequired('cpf')}
                      <Cpf
                        bind:value={formData.cpf}
                        required={true}
                        disabled={loading}
                      />
                    {/if}

                    {#if isFieldRequired('rg')}
                      <Rg
                        bind:value={formData.rg}
                        required={true}
                        disabled={loading}
                      />
                    {/if}

                    {#if isFieldRequired('gender')}
                      <Gender
                        bind:value={formData.gender}
                        required={true}
                        disabled={loading}
                      />
                    {/if}

                    {#if isFieldRequired('civil_status')}
                      <CivilStatus
                        bind:value={formData.civil_status}
                        gender={formData.gender}
                        required={true}
                        disabled={loading}
                      />
                    {/if}

                    {#if isFieldRequired('nationality')}
                      <Nationality
                        bind:value={formData.nationality}
                        gender={formData.gender}
                        required={true}
                        disabled={loading}
                      />
                    {/if}

                    {#if isFieldRequired('birth')}
                      <Birth
                        bind:value={formData.birth}
                        required={true}
                        disabled={loading}
                      />
                    {/if}
                  </div>
                </div>
              </div>
            {/if}

            {#if isFieldRequired('phone') || !userData.phone}
              <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
                <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                      <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/>
                      </svg>
                    </div>
                    <h3 class="text-lg font-semibold text-white">Informações de Contato</h3>
                  </div>
                </div>
                <div class="p-6">
                  <Phone
                    bind:value={formData.phone}
                    required={isFieldRequired('phone')}
                    disabled={loading}
                  />
                </div>
              </div>
            {/if}

            {#if isFieldRequired('address')}
              <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
                <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                      <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                      </svg>
                    </div>
                    <h3 class="text-lg font-semibold text-white">Endereço</h3>
                  </div>
                </div>
                <div class="p-6">
                  <AddressCepWrapper
                    bind:address={formData.address}
                    config={{
                      cep: { show: true, required: true },
                      address: { required: true, disabled: loading }
                    }}
                    title=""
                    disabled={loading}
                  />
                </div>
              </div>
            {/if}

            <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
              <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
                    </svg>
                  </div>
                  <h3 class="text-lg font-semibold text-white">Dados Bancários</h3>
                  <span class="ml-auto text-xs text-white/70 bg-white/20 px-3 py-1 rounded-full">Opcional</span>
                </div>
              </div>
              <div class="p-6">
                <Bank
                  bind:bankAccount={formData.bank_account}
                  index={0}
                  disabled={loading}
                  showPixHelpers={true}
                  pixHelperData={{
                    email: userData.email || '',
                    cpf: formData.cpf,
                    cnpj: '',
                    phone: formData.phone
                  }}
                  pixDocumentType="cpf"
                />
              </div>
            </div>
          </div>

          <div class="flex justify-end gap-3 pt-6 border-t border-[#eef0ef] mt-6">
            <button
              type="button"
              class="px-6 py-3 rounded-lg border border-gray-300 text-[#01013D] font-medium hover:bg-gray-50 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
              onclick={closeModal}
              disabled={loading}
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="px-6 py-3 rounded-lg bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-medium hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              disabled={loading}
            >
              {#if loading}
                <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Salvando...
              {:else}
                Completar Cadastro
              {/if}
            </button>
          </div>

          {#if message}
            <div class="mt-4 bg-{isSuccess ? 'green' : 'red'}-50 border border-{isSuccess ? 'green' : 'red'}-200 rounded-lg p-4 flex items-start gap-3">
              <svg class="w-5 h-5 text-{isSuccess ? 'green' : 'red'}-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="{isSuccess ? 'M5 13l4 4L19 7' : 'M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'}"/>
              </svg>
              <div>
                <h4 class="font-semibold text-{isSuccess ? 'green' : 'red'}-900">{isSuccess ? 'Sucesso' : 'Erro'}</h4>
                <p class="text-sm text-{isSuccess ? 'green' : 'red'}-700">{message}</p>
              </div>
            </div>
          {/if}
        </form>
      </div>
    </div>
  </div>
{/if}
