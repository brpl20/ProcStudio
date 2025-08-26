<!-- components/customers/CustomerPersonalInfoStep.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import {
    validateCPFRequired,
    formatCPF,
    validateEmailRequired,
    validatePasswordRequired,
    createPasswordConfirmationValidator,
    validateBirthDateRequired,
    getCapacityFromBirthDate
  } from '../../validation';

  import { BRAZILIAN_STATES } from '../../constants/brazilian-states';
  import type { BrazilianState } from '../../constants/brazilian-states';
  import { BRAZILIAN_BANKS, searchBanks } from '../../constants/brazilian-banks';
  import type { BrazilianBank } from '../../constants/brazilian-banks';
  import type { CustomerFormData } from '../../schemas/customer-form';
  import {
    getCivilStatusLabel,
    getNationalityLabel,
    formatCpfForPix,
    formatPhoneForPix
  } from '../../utils/form-helpers';

  export let formData: CustomerFormData;
  export let errors: Record<string, string> = {};
  export let touched: Record<string, boolean> = {};
  export let isLoading: boolean = false;
  export let customer: any = null;

  const dispatch = createEventDispatcher<{
    fieldBlur: { field: string; value: any };
    cpfInput: Event;
    birthDateChange: Event;
  }>();

  // Local reactive variables
  $: capacityInfo = getCapacityFromBirthDate(formData.birth);
  $: capacityMessage = capacityInfo?.message || '';
  $: isProfessionRequired = formData.capacity !== 'unable';
  $: isEmailRequired = formData.capacity !== 'unable';
  $: isEmailDisabled = formData.capacity === 'unable';

  // Brazilian states
  const states: BrazilianState[] = BRAZILIAN_STATES;

  // Bank search state
  let bankSearchTerm = '';
  let showBankDropdown = false;
  let selectedBankCode = '';
  let filteredBanks: BrazilianBank[] = [];
  let selectedDropdownIndex = -1;

  // Check if Operação field should be shown (only for Caixa Econômica - code 104)
  $: showOperationField = selectedBankCode === '104';

  // Initialize bank search when bank name changes
  $: if (formData.bank_accounts_attributes[0].bank_name) {
    const matchingBank = BRAZILIAN_BANKS.find(
      (bank) => bank.label === formData.bank_accounts_attributes[0].bank_name
    );
    if (matchingBank) {
      selectedBankCode = matchingBank.value;
    }
  }

  // Event handlers
  function handleBlur(fieldName: string, value: any) {
    dispatch('fieldBlur', { field: fieldName, value });
  }

  function handleCPFInput(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.cpf = formatCPF(input.value);
    dispatch('cpfInput', { value: formData.cpf });
  }

  function handleBirthDateChange(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.birth = input.value;
    dispatch('birthDateChange', { value: formData.birth });
  }

  // Bank search handlers
  function handleBankSearch(event: Event) {
    const input = event.target as HTMLInputElement;
    bankSearchTerm = input.value;
    selectedDropdownIndex = -1; // Reset selection when searching

    if (bankSearchTerm.length > 0) {
      filteredBanks = searchBanks(bankSearchTerm).slice(0, 10); // Limit to 10 results
      showBankDropdown = filteredBanks.length > 0;
    } else {
      showBankDropdown = false;
      filteredBanks = [];
    }
  }

  function selectBank(bank: BrazilianBank) {
    formData.bank_accounts_attributes[0].bank_name = bank.label;
    formData.bank_accounts_attributes[0].bank_number = bank.value;
    selectedBankCode = bank.value;
    bankSearchTerm = bank.label;
    showBankDropdown = false;
    selectedDropdownIndex = -1;

    // Clear operation field if not Caixa Econômica
    if (bank.value !== '104') {
      formData.bank_accounts_attributes[0].operation = '';
    }
  }

  function handleBankInputFocus() {
    if (!bankSearchTerm && formData.bank_accounts_attributes[0].bank_name) {
      bankSearchTerm = formData.bank_accounts_attributes[0].bank_name;
    }
  }

  function handleBankInputBlur() {
    // Delay hiding dropdown to allow click on dropdown items
    setTimeout(() => {
      showBankDropdown = false;
      selectedDropdownIndex = -1;
    }, 200);
  }

  function handleBankKeydown(event: KeyboardEvent) {
    if (!showBankDropdown) {
      return;
    }

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        selectedDropdownIndex = Math.min(selectedDropdownIndex + 1, filteredBanks.length - 1);
        break;
      case 'ArrowUp':
        event.preventDefault();
        selectedDropdownIndex = Math.max(selectedDropdownIndex - 1, -1);
        break;
      case 'Enter':
        event.preventDefault();
        if (selectedDropdownIndex >= 0 && selectedDropdownIndex < filteredBanks.length) {
          selectBank(filteredBanks[selectedDropdownIndex]);
        }
        break;
      case 'Escape':
        event.preventDefault();
        showBankDropdown = false;
        selectedDropdownIndex = -1;
        break;
    }
  }
</script>

<!-- Personal Information Section -->
<div class="divider" aria-label="Seção de informações pessoais">Informações Pessoais</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Name -->
  <div class="form-control w-full">
    <label for="name" class="label justify-start">
      <span class="label-text font-medium">Nome *</span>
    </label>
    <input
      id="name"
      type="text"
      class="input input-bordered w-full {errors.name && touched.name ? 'input-error' : ''}"
      bind:value={formData.name}
      on:blur={() => handleBlur('name', formData.name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.name && touched.name ? 'true' : 'false'}
      aria-describedby={errors.name && touched.name ? 'name-error' : undefined}
      data-testid="customer-name-input"
    />
    {#if errors.name && touched.name}
      <div id="name-error" class="text-error text-sm mt-1">{errors.name}</div>
    {/if}
  </div>

  <!-- Last Name -->
  <div class="form-control w-full">
    <label for="last_name" class="label justify-start">
      <span class="label-text font-medium">Sobrenome *</span>
    </label>
    <input
      id="last_name"
      type="text"
      class="input input-bordered w-full {errors.last_name && touched.last_name
        ? 'input-error'
        : ''}"
      bind:value={formData.last_name}
      on:blur={() => handleBlur('last_name', formData.last_name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.last_name && touched.last_name ? 'true' : 'false'}
      aria-describedby={errors.last_name && touched.last_name ? 'last_name-error' : undefined}
      data-testid="customer-lastname-input"
    />
    {#if errors.last_name && touched.last_name}
      <div id="last_name-error" class="text-error text-sm mt-1">{errors.last_name}</div>
    {/if}
  </div>

  <!-- CPF -->
  <div class="form-control w-full">
    <label for="cpf" class="label justify-start">
      <span class="label-text font-medium">CPF *</span>
    </label>
    <input
      id="cpf"
      type="text"
      class="input input-bordered w-full {errors.cpf && touched.cpf ? 'input-error' : ''}"
      bind:value={formData.cpf}
      on:input={handleCPFInput}
      on:blur={() => handleBlur('cpf', formData.cpf)}
      disabled={isLoading}
      placeholder="000.000.000-00"
      maxlength="14"
      aria-required="true"
      aria-invalid={errors.cpf && touched.cpf ? 'true' : 'false'}
      aria-describedby={errors.cpf && touched.cpf ? 'cpf-error' : undefined}
      data-testid="customer-cpf-input"
    />
    {#if errors.cpf && touched.cpf}
      <div id="cpf-error" class="text-error text-sm mt-1">{errors.cpf}</div>
    {/if}
  </div>

  <!-- RG -->
  <div class="form-control w-full">
    <label for="rg" class="label justify-start">
      <span class="label-text font-medium">RG *</span>
    </label>
    <input
      id="rg"
      type="text"
      class="input input-bordered w-full {errors.rg && touched.rg ? 'input-error' : ''}"
      bind:value={formData.rg}
      on:blur={() => handleBlur('rg', formData.rg)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.rg && touched.rg ? 'true' : 'false'}
      aria-describedby={errors.rg && touched.rg ? 'rg-error' : undefined}
      data-testid="customer-rg-input"
    />
    {#if errors.rg && touched.rg}
      <div id="rg-error" class="text-error text-sm mt-1">{errors.rg}</div>
    {/if}
  </div>

  <!-- Birth Date -->
  <div class="form-control w-full">
    <label for="birth" class="label justify-start">
      <span class="label-text font-medium">Data de Nascimento *</span>
    </label>
    <input
      id="birth"
      type="date"
      class="input input-bordered w-full {errors.birth && touched.birth ? 'input-error' : ''}"
      bind:value={formData.birth}
      on:change={handleBirthDateChange}
      on:blur={() => handleBlur('birth', formData.birth)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.birth && touched.birth ? 'true' : 'false'}
      aria-describedby={(errors.birth && touched.birth) || capacityMessage
        ? 'birth-message'
        : undefined}
      data-testid="customer-birth-input"
    />
    {#if (errors.birth && touched.birth) || capacityMessage}
      <div
        id="birth-message"
        class="text-sm mt-1 {errors.birth && touched.birth ? 'text-error' : 'text-warning'}"
      >
        {errors.birth || capacityMessage}
      </div>
    {/if}
  </div>

  <!-- Gender -->
  <div class="form-control w-full">
    <label for="gender" class="label justify-start">
      <span class="label-text font-medium">Gênero *</span>
    </label>
    <select
      id="gender"
      class="select select-bordered w-full"
      bind:value={formData.gender}
      disabled={isLoading}
      aria-required="true"
      data-testid="customer-gender-input"
    >
      <option value="male">Masculino</option>
      <option value="female">Feminino</option>
    </select>
  </div>

  <!-- Civil Status -->
  <div class="form-control w-full">
    <label for="civil_status" class="label justify-start">
      <span class="label-text font-medium">Estado Civil *</span>
    </label>
    <select
      id="civil_status"
      class="select select-bordered w-full"
      bind:value={formData.civil_status}
      disabled={isLoading}
      aria-required="true"
      data-testid="customer-civil-status-input"
    >
      <option value="single">{getCivilStatusLabel('single', formData.gender)}</option>
      <option value="married">{getCivilStatusLabel('married', formData.gender)}</option>
      <option value="divorced">{getCivilStatusLabel('divorced', formData.gender)}</option>
      <option value="widower">{getCivilStatusLabel('widower', formData.gender)}</option>
      <option value="union">{getCivilStatusLabel('union', formData.gender)}</option>
    </select>
  </div>

  <!-- Nationality -->
  <div class="form-control w-full">
    <label for="nationality" class="label justify-start">
      <span class="label-text font-medium">Nacionalidade *</span>
    </label>
    <select
      id="nationality"
      class="select select-bordered w-full"
      bind:value={formData.nationality}
      disabled={isLoading}
      aria-required="true"
      data-testid="customer-nationality-input"
    >
      <option value="brazilian">{getNationalityLabel('brazilian', formData.gender)}</option>
      <option value="foreigner">{getNationalityLabel('foreigner', formData.gender)}</option>
    </select>
  </div>

  <!-- Profession -->
  <div class="form-control w-full">
    <label for="profession" class="label justify-start">
      <span class="label-text font-medium"
        >Profissão {isProfessionRequired ? '*' : '(Opcional)'}</span
      >
    </label>
    <input
      id="profession"
      type="text"
      class="input input-bordered w-full {errors.profession &&
      touched.profession &&
      isProfessionRequired
        ? 'input-error'
        : ''}"
      bind:value={formData.profession}
      on:blur={() => handleBlur('profession', formData.profession)}
      disabled={isLoading || !isProfessionRequired}
      aria-required={isProfessionRequired ? 'true' : 'false'}
      aria-invalid={errors.profession && touched.profession && isProfessionRequired
        ? 'true'
        : 'false'}
      aria-describedby={errors.profession && touched.profession && isProfessionRequired
        ? 'profession-error'
        : undefined}
      data-testid="customer-profession-input"
    />
    {#if !isProfessionRequired}
      <div class="text-sm text-gray-500 mt-1">Não obrigatório para menores de 16 anos</div>
    {/if}
    {#if errors.profession && touched.profession && isProfessionRequired}
      <div id="profession-error" class="text-error text-sm mt-1">{errors.profession}</div>
    {/if}
  </div>

  <!-- Mother's Name -->
  <div class="form-control w-full">
    <label for="mother_name" class="label justify-start">
      <span class="label-text font-medium">Nome da Mãe *</span>
    </label>
    <input
      id="mother_name"
      type="text"
      class="input input-bordered w-full {errors.mother_name && touched.mother_name
        ? 'input-error'
        : ''}"
      bind:value={formData.mother_name}
      on:blur={() => handleBlur('mother_name', formData.mother_name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.mother_name && touched.mother_name ? 'true' : 'false'}
      aria-describedby={errors.mother_name && touched.mother_name ? 'mother_name-error' : undefined}
      data-testid="customer-mother-name-input"
    />
    {#if errors.mother_name && touched.mother_name}
      <div id="mother_name-error" class="text-error text-sm mt-1">{errors.mother_name}</div>
    {/if}
  </div>

  <!-- Capacity Selection -->
  <div class="form-control w-full">
    <label for="capacity" class="label justify-start">
      <span class="label-text font-medium">Capacidade</span>
    </label>
    <select
      id="capacity"
      class="select select-bordered w-full"
      bind:value={formData.capacity}
      disabled={isLoading}
      data-testid="customer-capacity-input"
    >
      <option value="able">Capaz</option>
      <option value="relatively">Relativamente Incapaz</option>
      <option value="unable">Absolutamente Incapaz</option>
    </select>
    {#if capacityMessage}
      <div class="text-sm text-warning mt-1">{capacityMessage}</div>
    {/if}
  </div>
</div>

<!-- Login Information Section -->
<div class="divider" aria-label="Seção de informações de acesso">Informações de Acesso</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Email -->
  <div class="form-control w-full">
    <label for="email" class="label justify-start">
      <span class="label-text font-medium">Email {isEmailRequired ? '*' : '(Opcional)'}</span>
    </label>
    <input
      id="email"
      type="email"
      class="input input-bordered w-full {errors.email && touched.email && isEmailRequired
        ? 'input-error'
        : ''}"
      bind:value={formData.customer_attributes.email}
      on:blur={() => handleBlur('email', formData.customer_attributes.email)}
      disabled={isLoading || isEmailDisabled}
      placeholder="cliente@exemplo.com"
      aria-required={isEmailRequired ? 'true' : 'false'}
      aria-invalid={errors.email && touched.email && isEmailRequired ? 'true' : 'false'}
      aria-describedby={errors.email && touched.email && isEmailRequired
        ? 'email-error'
        : undefined}
      data-testid="customer-email-input"
    />
    {#if !isEmailRequired}
      <div class="text-sm text-gray-500 mt-1">
        Este email pode ser compartilhado com a conta do responsável
      </div>
    {/if}
    {#if errors.email && touched.email && isEmailRequired}
      <div id="email-error" class="text-error text-sm mt-1">{errors.email}</div>
    {/if}
  </div>

  <!-- Phone -->
  <div class="form-control w-full">
    <label for="phone" class="label justify-start">
      <span class="label-text font-medium">Telefone</span>
    </label>
    <input
      id="phone"
      type="tel"
      class="input input-bordered w-full"
      bind:value={formData.phones_attributes[0].number}
      disabled={isLoading}
      placeholder="+55 11 98765-4321"
      data-testid="customer-phone-input"
    />
  </div>

  <!-- Password -->
  <div class="form-control w-full">
    <label for="password" class="label justify-start">
      <span class="label-text font-medium">
        {customer ? 'Nova Senha (deixe em branco para manter)' : 'Senha *'}
      </span>
    </label>
    <input
      id="password"
      type="password"
      class="input input-bordered w-full {errors.password && touched.password ? 'input-error' : ''}"
      bind:value={formData.customer_attributes.password}
      on:blur={() => handleBlur('password', formData.customer_attributes.password)}
      disabled={isLoading}
      placeholder="Mínimo 6 caracteres"
      aria-required={customer ? 'false' : 'true'}
      aria-invalid={errors.password && touched.password ? 'true' : 'false'}
      aria-describedby={errors.password && touched.password ? 'password-error' : undefined}
      data-testid="customer-password-input"
    />
    {#if errors.password && touched.password}
      <div id="password-error" class="text-error text-sm mt-1">{errors.password}</div>
    {/if}
  </div>

  <!-- Password Confirmation -->
  <div class="form-control w-full">
    <label for="password_confirmation" class="label justify-start">
      <span class="label-text font-medium">
        {customer ? 'Confirmar Nova Senha' : 'Confirmar Senha *'}
      </span>
    </label>
    <input
      id="password_confirmation"
      type="password"
      class="input input-bordered w-full {errors.password_confirmation &&
      touched.password_confirmation
        ? 'input-error'
        : ''}"
      bind:value={formData.customer_attributes.password_confirmation}
      on:blur={() =>
        handleBlur('password_confirmation', formData.customer_attributes.password_confirmation)}
      disabled={isLoading}
      placeholder="Digite a senha novamente"
      aria-required={customer ? 'false' : 'true'}
      aria-invalid={errors.password_confirmation && touched.password_confirmation
        ? 'true'
        : 'false'}
      aria-describedby={errors.password_confirmation && touched.password_confirmation
        ? 'password_confirmation-error'
        : undefined}
      data-testid="customer-password-confirmation-input"
    />
    {#if errors.password_confirmation && touched.password_confirmation}
      <div id="password_confirmation-error" class="text-error text-sm mt-1">
        {errors.password_confirmation}
      </div>
    {/if}
  </div>
</div>

<!-- Address Section -->
<div class="divider" aria-label="Seção de endereço">Endereço</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- ZIP Code -->
  <div class="form-control w-full">
    <label for="zip_code" class="label justify-start">
      <span class="label-text font-medium">CEP</span>
    </label>
    <input
      id="zip_code"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].zip_code}
      disabled={isLoading}
      placeholder="00000-000"
      data-testid="customer-zipcode-input"
    />
  </div>

  <!-- Street -->
  <div class="form-control w-full">
    <label for="street" class="label justify-start">
      <span class="label-text font-medium">Rua</span>
    </label>
    <input
      id="street"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].street}
      disabled={isLoading}
      data-testid="customer-street-input"
    />
  </div>

  <!-- Number -->
  <div class="form-control w-full">
    <label for="number" class="label justify-start">
      <span class="label-text font-medium">Número</span>
    </label>
    <input
      id="number"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].number}
      disabled={isLoading}
      data-testid="customer-number-input"
    />
  </div>

  <!-- Neighborhood -->
  <div class="form-control w-full">
    <label for="neighborhood" class="label justify-start">
      <span class="label-text font-medium">Bairro</span>
    </label>
    <input
      id="neighborhood"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].neighborhood}
      disabled={isLoading}
      data-testid="customer-neighborhood-input"
    />
  </div>

  <!-- City -->
  <div class="form-control w-full">
    <label for="city" class="label justify-start">
      <span class="label-text font-medium">Cidade</span>
    </label>
    <input
      id="city"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].city}
      disabled={isLoading}
      data-testid="customer-city-input"
    />
  </div>

  <!-- State -->
  <div class="form-control w-full">
    <label for="state" class="label justify-start">
      <span class="label-text font-medium">Estado</span>
    </label>
    <select
      id="state"
      class="select select-bordered w-full"
      bind:value={formData.addresses_attributes[0].state}
      disabled={isLoading}
      data-testid="customer-state-input"
    >
      <option value="">Selecione...</option>
      {#each states as state}
        <option value={state.value}>{state.label}</option>
      {/each}
    </select>
  </div>
</div>

<!-- Bank Account Section -->
<div class="divider" aria-label="Seção de dados bancários">Dados Bancários</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Bank Name with Search -->
  <div class="form-control w-full relative">
    <label for="bank_name" class="label justify-start">
      <span class="label-text font-medium">Banco</span>
    </label>
    <div class="relative">
      <input
        id="bank_name"
        type="text"
        class="input input-bordered w-full"
        value={bankSearchTerm || formData.bank_accounts_attributes[0].bank_name}
        on:input={handleBankSearch}
        on:focus={handleBankInputFocus}
        on:blur={handleBankInputBlur}
        on:keydown={handleBankKeydown}
        disabled={isLoading}
        placeholder="Digite para buscar o banco..."
        autocomplete="off"
        data-testid="customer-bank-name-input"
      />

      {#if showBankDropdown}
        <div
          class="absolute z-10 w-full mt-1 bg-base-100 border border-base-300 rounded-lg shadow-lg max-h-60 overflow-y-auto"
        >
          {#each filteredBanks as bank, index}
            <button
              type="button"
              class="w-full text-left px-4 py-2 hover:bg-base-200 focus:bg-base-200 focus:outline-none {selectedDropdownIndex ===
              index
                ? 'bg-primary/20'
                : ''}"
              on:click={() => selectBank(bank)}
              on:mouseenter={() => (selectedDropdownIndex = index)}
            >
              <div class="font-medium">{bank.label}</div>
              <div class="text-sm text-base-content/60">Código: {bank.value}</div>
            </button>
          {/each}
        </div>
      {/if}
    </div>
    {#if selectedBankCode}
      <div class="text-sm text-base-content/60 mt-1">
        Código do banco: {selectedBankCode}
      </div>
    {/if}
  </div>

  <!-- Account Type -->
  <div class="form-control w-full">
    <label for="type_account" class="label justify-start">
      <span class="label-text font-medium">Tipo de Conta</span>
    </label>
    <select
      id="type_account"
      class="select select-bordered w-full"
      bind:value={formData.bank_accounts_attributes[0].type_account}
      disabled={isLoading}
      data-testid="customer-account-type-input"
    >
      <option value="Corrente">Corrente</option>
      <option value="Poupança">Poupança</option>
    </select>
  </div>

  <!-- Agency -->
  <div class="form-control w-full">
    <label for="agency" class="label justify-start">
      <span class="label-text font-medium">Agência</span>
    </label>
    <input
      id="agency"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.bank_accounts_attributes[0].agency}
      disabled={isLoading}
      placeholder="0000-0"
      data-testid="customer-agency-input"
    />
  </div>

  <!-- Account -->
  <div class="form-control w-full">
    <label for="account" class="label justify-start">
      <span class="label-text font-medium">Conta</span>
    </label>
    <input
      id="account"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.bank_accounts_attributes[0].account}
      disabled={isLoading}
      placeholder="00000-0"
      data-testid="customer-account-input"
    />
  </div>

  <!-- Operation (Only for Caixa Econômica - code 104) -->
  {#if showOperationField}
    <div class="form-control w-full">
      <label for="operation" class="label justify-start">
        <span class="label-text font-medium">Operação</span>
        <span class="label-text-alt text-info">(Caixa Econômica)</span>
      </label>
      <input
        id="operation"
        type="text"
        class="input input-bordered w-full"
        bind:value={formData.bank_accounts_attributes[0].operation}
        disabled={isLoading}
        placeholder="Ex: 001, 013"
        data-testid="customer-operation-input"
      />
    </div>
  {/if}

  <!-- PIX with reactive options -->
  <div class="form-control w-full">
    <label for="pix" class="label justify-start">
      <span class="label-text font-medium">Chave PIX</span>
    </label>

    <!-- PIX Key Type Options -->
    <div class="flex gap-2 mb-2">
      <button
        type="button"
        class="btn btn-sm btn-outline"
        disabled={!formData.customer_attributes.email || isLoading}
        on:click={() =>
          (formData.bank_accounts_attributes[0].pix = formData.customer_attributes.email)}
        aria-label="Usar e-mail como chave PIX"
        data-testid="pix-email-button"
      >
        E-mail
      </button>

      <button
        type="button"
        class="btn btn-sm btn-outline"
        disabled={!formData.cpf || isLoading}
        on:click={() => (formData.bank_accounts_attributes[0].pix = formatCpfForPix(formData.cpf))}
        aria-label="Usar CPF como chave PIX"
        data-testid="pix-cpf-button"
      >
        CPF
      </button>

      <button
        type="button"
        class="btn btn-sm btn-outline"
        disabled={!formData.phones_attributes[0].number || isLoading}
        on:click={() =>
          (formData.bank_accounts_attributes[0].pix = formatPhoneForPix(
            formData.phones_attributes[0].number
          ))}
        aria-label="Usar telefone como chave PIX"
        data-testid="pix-phone-button"
      >
        Telefone
      </button>
    </div>

    <input
      id="pix"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.bank_accounts_attributes[0].pix}
      disabled={isLoading}
      data-testid="customer-pix-input"
    />
    <div class="text-sm text-gray-500 mt-2">
      Escolha um dos botões acima para preencher automaticamente.
    </div>
  </div>
</div>

<!-- Social Security Information Section -->
<div class="divider" aria-label="Seção de informações previdenciárias">
  Informações Previdenciárias
</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Benefit Number -->
  <div class="form-control w-full">
    <label for="number_benefit" class="label justify-start">
      <span class="label-text font-medium">Número de Benefício (Opcional)</span>
    </label>
    <input
      id="number_benefit"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.number_benefit}
      disabled={isLoading}
      placeholder="Número do benefício INSS"
      data-testid="customer-benefit-input"
    />
  </div>

  <!-- NIT -->
  <div class="form-control w-full">
    <label for="nit" class="label justify-start">
      <span class="label-text font-medium">NIT (Opcional)</span>
    </label>
    <input
      id="nit"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.nit}
      disabled={isLoading}
      placeholder="Número de Inscrição do Trabalhador"
      data-testid="customer-nit-input"
    />
  </div>

  <!-- INSS Password -->
  <div class="form-control w-full md:col-span-2">
    <label for="inss_password" class="label justify-start">
      <span class="label-text font-medium">Senha do MeuINSS (Opcional)</span>
    </label>
    <input
      id="inss_password"
      type="password"
      class="input input-bordered w-full"
      bind:value={formData.inss_password}
      disabled={isLoading}
      placeholder="Senha de acesso ao MeuINSS"
      data-testid="customer-inss-password-input"
    />
    <div class="text-sm text-warning mt-1">
      Esta informação é armazenada de forma segura e criptografada
    </div>
  </div>
</div>
