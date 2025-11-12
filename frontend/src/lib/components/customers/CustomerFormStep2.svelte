<!-- components/customers/CustomerFormStep2.svelte -->
<script lang="ts">
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

  let {
    formData,
    errors = {},
    touched = {},
    isLoading = false,
    guardianLabel = 'Responsável',
    useSameAddress = $bindable(false),
    useSameBankAccount = $bindable(false),
    onFieldBlur = () => {},
    onCpfInput = () => {},
    onBirthDateChange = () => {},
    onUseSameAddressChange = () => {},
    onUseSameBankAccountChange = () => {}
  }: {
    formData: CustomerFormData;
    errors?: Record<string, string>;
    touched?: Record<string, boolean>;
    isLoading?: boolean;
    guardianLabel?: string;
    useSameAddress?: boolean;
    useSameBankAccount?: boolean;
    onFieldBlur?: (detail: { field: string; value: any }) => void;
    onCpfInput?: (detail: { value: string }) => void;
    onBirthDateChange?: (detail: { value: string }) => void;
    onUseSameAddressChange?: (detail: { checked: boolean }) => void;
    onUseSameBankAccountChange?: (detail: { checked: boolean }) => void;
  } = $props();

  // Brazilian states
  const states: BrazilianState[] = BRAZILIAN_STATES;

  // Bank search state
  let bankSearchTerm = $state('');
  let showBankDropdown = $state(false);
  let selectedBankCode = $state('');
  let filteredBanks = $state<BrazilianBank[]>([]);
  let selectedDropdownIndex = $state(-1);

  // Check if Operação field should be shown (only for Caixa Econômica - code 104)
  let showOperationField = $derived(selectedBankCode === '104');

  // Initialize bank search when bank name changes
  $effect(() => {
    if (formData.bank_accounts_attributes[0].bank_name) {
      const matchingBank = BRAZILIAN_BANKS.find(
        (bank) => bank.label === formData.bank_accounts_attributes[0].bank_name
      );
      if (matchingBank) {
        selectedBankCode = matchingBank.value;
      }
    }
  });

  // Event handlers - EXACTLY like Step1
  function handleBlur(fieldName: string, value: any) {
    onFieldBlur({ field: fieldName, value });
  }

  function handleCPFInput(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.cpf = formatCPF(input.value);
    onCpfInput({ value: formData.cpf });
  }

  function handleBirthDateChange(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.birth = input.value;
    onBirthDateChange({ value: formData.birth });
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

<!-- Guardian/Representative Information Section -->
<div class="divider" aria-label="Seção de informações pessoais do {guardianLabel.toLowerCase()}">
  Informações Pessoais - {guardianLabel}
</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Name -->
  <div class="form-control w-full">
    <label for="guardian_name" class="label justify-start">
      <span class="label-text font-medium">Nome *</span>
    </label>
    <input
      id="guardian_name"
      type="text"
      class="input input-bordered w-full {errors.name && touched.name ? 'input-error' : ''}"
      bind:value={formData.name}
      onblur={() => handleBlur('name', formData.name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.name && touched.name ? 'true' : 'false'}
      aria-describedby={errors.name && touched.name ? 'name-error' : undefined}
      data-testid="guardian-name-input"
    />
    {#if errors.name && touched.name}
      <div id="name-error" class="text-error text-sm mt-1">{errors.name}</div>
    {/if}
  </div>

  <!-- Last Name -->
  <div class="form-control w-full">
    <label for="guardian_last_name" class="label justify-start">
      <span class="label-text font-medium">Sobrenome *</span>
    </label>
    <input
      id="guardian_last_name"
      type="text"
      class="input input-bordered w-full {errors.last_name && touched.last_name
        ? 'input-error'
        : ''}"
      bind:value={formData.last_name}
      onblur={() => handleBlur('last_name', formData.last_name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.last_name && touched.last_name ? 'true' : 'false'}
      aria-describedby={errors.last_name && touched.last_name ? 'last_name-error' : undefined}
      data-testid="guardian-lastname-input"
    />
    {#if errors.last_name && touched.last_name}
      <div id="last_name-error" class="text-error text-sm mt-1">{errors.last_name}</div>
    {/if}
  </div>

  <!-- CPF -->
  <div class="form-control w-full">
    <label for="guardian_cpf" class="label justify-start">
      <span class="label-text font-medium">CPF *</span>
    </label>
    <input
      id="guardian_cpf"
      type="text"
      class="input input-bordered w-full {errors.cpf && touched.cpf ? 'input-error' : ''}"
      bind:value={formData.cpf}
      oninput={handleCPFInput}
      onblur={() => handleBlur('cpf', formData.cpf)}
      disabled={isLoading}
      placeholder="000.000.000-00"
      maxlength="14"
      aria-required="true"
      aria-invalid={errors.cpf && touched.cpf ? 'true' : 'false'}
      aria-describedby={errors.cpf && touched.cpf ? 'cpf-error' : undefined}
      data-testid="guardian-cpf-input"
    />
    {#if errors.cpf && touched.cpf}
      <div id="cpf-error" class="text-error text-sm mt-1">{errors.cpf}</div>
    {/if}
  </div>

  <!-- RG -->
  <div class="form-control w-full">
    <label for="guardian_rg" class="label justify-start">
      <span class="label-text font-medium">RG *</span>
    </label>
    <input
      id="guardian_rg"
      type="text"
      class="input input-bordered w-full {errors.rg && touched.rg ? 'input-error' : ''}"
      bind:value={formData.rg}
      onblur={() => handleBlur('rg', formData.rg)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.rg && touched.rg ? 'true' : 'false'}
      aria-describedby={errors.rg && touched.rg ? 'rg-error' : undefined}
      data-testid="guardian-rg-input"
    />
    {#if errors.rg && touched.rg}
      <div id="rg-error" class="text-error text-sm mt-1">{errors.rg}</div>
    {/if}
  </div>

  <!-- Birth Date -->
  <div class="form-control w-full">
    <label for="guardian_birth" class="label justify-start">
      <span class="label-text font-medium">Data de Nascimento *</span>
    </label>
    <input
      id="guardian_birth"
      type="date"
      class="input input-bordered w-full {errors.birth && touched.birth ? 'input-error' : ''}"
      bind:value={formData.birth}
      onchange={handleBirthDateChange}
      onblur={() => handleBlur('birth', formData.birth)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.birth && touched.birth ? 'true' : 'false'}
      aria-describedby={errors.birth && touched.birth ? 'birth-error' : undefined}
      data-testid="guardian-birth-input"
    />
    {#if errors.birth && touched.birth}
      <div id="birth-error" class="text-error text-sm mt-1">{errors.birth}</div>
    {/if}
  </div>

  <!-- Gender -->
  <div class="form-control w-full">
    <label for="guardian_gender" class="label justify-start">
      <span class="label-text font-medium">Gênero *</span>
    </label>
    <select
      id="guardian_gender"
      class="select select-bordered w-full"
      bind:value={formData.gender}
      disabled={isLoading}
      aria-required="true"
      data-testid="guardian-gender-input"
    >
      <option value="male">Masculino</option>
      <option value="female">Feminino</option>
    </select>
  </div>

  <!-- Civil Status -->
  <div class="form-control w-full">
    <label for="guardian_civil_status" class="label justify-start">
      <span class="label-text font-medium">Estado Civil *</span>
    </label>
    <select
      id="guardian_civil_status"
      class="select select-bordered w-full"
      bind:value={formData.civil_status}
      disabled={isLoading}
      aria-required="true"
      data-testid="guardian-civil-status-input"
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
    <label for="guardian_nationality" class="label justify-start">
      <span class="label-text font-medium">Nacionalidade *</span>
    </label>
    <select
      id="guardian_nationality"
      class="select select-bordered w-full"
      bind:value={formData.nationality}
      disabled={isLoading}
      aria-required="true"
      data-testid="guardian-nationality-input"
    >
      <option value="brazilian">{getNationalityLabel('brazilian', formData.gender)}</option>
      <option value="foreigner">{getNationalityLabel('foreigner', formData.gender)}</option>
    </select>
  </div>

  <!-- Profession -->
  <div class="form-control w-full">
    <label for="guardian_profession" class="label justify-start">
      <span class="label-text font-medium">Profissão *</span>
    </label>
    <input
      id="guardian_profession"
      type="text"
      class="input input-bordered w-full {errors.profession && touched.profession
        ? 'input-error'
        : ''}"
      bind:value={formData.profession}
      onblur={() => handleBlur('profession', formData.profession)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.profession && touched.profession ? 'true' : 'false'}
      aria-describedby={errors.profession && touched.profession ? 'profession-error' : undefined}
      data-testid="guardian-profession-input"
    />
    {#if errors.profession && touched.profession}
      <div id="profession-error" class="text-error text-sm mt-1">{errors.profession}</div>
    {/if}
  </div>

  <!-- Mother's Name -->
  <div class="form-control w-full">
    <label for="guardian_mother_name" class="label justify-start">
      <span class="label-text font-medium">Nome da Mãe *</span>
    </label>
    <input
      id="guardian_mother_name"
      type="text"
      class="input input-bordered w-full {errors.mother_name && touched.mother_name
        ? 'input-error'
        : ''}"
      bind:value={formData.mother_name}
      onblur={() => handleBlur('mother_name', formData.mother_name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.mother_name && touched.mother_name ? 'true' : 'false'}
      aria-describedby={errors.mother_name && touched.mother_name ? 'mother_name-error' : undefined}
      data-testid="guardian-mother-name-input"
    />
    {#if errors.mother_name && touched.mother_name}
      <div id="mother_name-error" class="text-error text-sm mt-1">{errors.mother_name}</div>
    {/if}
  </div>
</div>

<!-- Login Information Section -->
<div class="divider" aria-label="Seção de informações de acesso">
  Informações de Acesso - {guardianLabel}
</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Email -->
  <div class="form-control w-full">
    <label for="guardian_email" class="label justify-start">
      <span class="label-text font-medium">Email *</span>
    </label>
    <input
      id="guardian_email"
      type="email"
      class="input input-bordered w-full {errors.email && touched.email ? 'input-error' : ''}"
      bind:value={formData.customer_attributes.email}
      onblur={() => handleBlur('email', formData.customer_attributes.email)}
      disabled={isLoading}
      placeholder="responsavel@exemplo.com"
      aria-required="true"
      aria-invalid={errors.email && touched.email ? 'true' : 'false'}
      aria-describedby={errors.email && touched.email ? 'email-error' : undefined}
      data-testid="guardian-email-input"
    />
    {#if errors.email && touched.email}
      <div id="email-error" class="text-error text-sm mt-1">{errors.email}</div>
    {/if}
  </div>

  <!-- Phone -->
  <div class="form-control w-full">
    <label for="guardian_phone" class="label justify-start">
      <span class="label-text font-medium">Telefone</span>
    </label>
    <input
      id="guardian_phone"
      type="tel"
      class="input input-bordered w-full"
      bind:value={formData.phones_attributes[0].number}
      disabled={isLoading}
      placeholder="+55 11 98765-4321"
      data-testid="guardian-phone-input"
    />
  </div>

  <!-- Password -->
  <div class="form-control w-full">
    <label for="guardian_password" class="label justify-start">
      <span class="label-text font-medium">Senha *</span>
    </label>
    <input
      id="guardian_password"
      type="password"
      class="input input-bordered w-full {errors.password && touched.password ? 'input-error' : ''}"
      bind:value={formData.customer_attributes.password}
      onblur={() => handleBlur('password', formData.customer_attributes.password)}
      disabled={isLoading}
      placeholder="Mínimo 6 caracteres"
      aria-required="true"
      aria-invalid={errors.password && touched.password ? 'true' : 'false'}
      aria-describedby={errors.password && touched.password ? 'password-error' : undefined}
      data-testid="guardian-password-input"
    />
    {#if errors.password && touched.password}
      <div id="password-error" class="text-error text-sm mt-1">{errors.password}</div>
    {/if}
  </div>

  <!-- Password Confirmation -->
  <div class="form-control w-full">
    <label for="guardian_password_confirmation" class="label justify-start">
      <span class="label-text font-medium">Confirmar Senha *</span>
    </label>
    <input
      id="guardian_password_confirmation"
      type="password"
      class="input input-bordered w-full {errors.password_confirmation &&
      touched.password_confirmation
        ? 'input-error'
        : ''}"
      bind:value={formData.customer_attributes.password_confirmation}
      onblur={() =>
        handleBlur('password_confirmation', formData.customer_attributes.password_confirmation)}
      disabled={isLoading}
      placeholder="Digite a senha novamente"
      aria-required="true"
      aria-invalid={errors.password_confirmation && touched.password_confirmation
        ? 'true'
        : 'false'}
      aria-describedby={errors.password_confirmation && touched.password_confirmation
        ? 'password_confirmation-error'
        : undefined}
      data-testid="guardian-password-confirmation-input"
    />
    {#if errors.password_confirmation && touched.password_confirmation}
      <div id="password_confirmation-error" class="text-error text-sm mt-1">
        {errors.password_confirmation}
      </div>
    {/if}
  </div>
</div>

<!-- Address Section -->
<div class="divider" aria-label="Seção de endereço">Endereço - {guardianLabel}</div>

<!-- Checkbox to use same address -->
<div class="form-control">
  <label class="label cursor-pointer justify-start gap-2">
    <input
      type="checkbox"
      class="checkbox checkbox-primary"
      bind:checked={useSameAddress}
      onchange={() => onUseSameAddressChange({ checked: useSameAddress })}
      disabled={isLoading}
    />
    <span class="label-text">Usar mesmo endereço do representado</span>
  </label>
</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- ZIP Code -->
  <div class="form-control w-full">
    <label for="guardian_zip_code" class="label justify-start">
      <span class="label-text font-medium">CEP</span>
    </label>
    <input
      id="guardian_zip_code"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].zip_code}
      disabled={isLoading || useSameAddress}
      placeholder="00000-000"
      data-testid="guardian-zipcode-input"
    />
  </div>

  <!-- Street -->
  <div class="form-control w-full">
    <label for="guardian_street" class="label justify-start">
      <span class="label-text font-medium">Rua</span>
    </label>
    <input
      id="guardian_street"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].street}
      disabled={isLoading || useSameAddress}
      data-testid="guardian-street-input"
    />
  </div>

  <!-- Number -->
  <div class="form-control w-full">
    <label for="guardian_number" class="label justify-start">
      <span class="label-text font-medium">Número</span>
    </label>
    <input
      id="guardian_number"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].number}
      disabled={isLoading || useSameAddress}
      data-testid="guardian-number-input"
    />
  </div>

  <!-- Neighborhood -->
  <div class="form-control w-full">
    <label for="guardian_neighborhood" class="label justify-start">
      <span class="label-text font-medium">Bairro</span>
    </label>
    <input
      id="guardian_neighborhood"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].neighborhood}
      disabled={isLoading || useSameAddress}
      data-testid="guardian-neighborhood-input"
    />
  </div>

  <!-- City -->
  <div class="form-control w-full">
    <label for="guardian_city" class="label justify-start">
      <span class="label-text font-medium">Cidade</span>
    </label>
    <input
      id="guardian_city"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].city}
      disabled={isLoading || useSameAddress}
      data-testid="guardian-city-input"
    />
  </div>

  <!-- State -->
  <div class="form-control w-full">
    <label for="guardian_state" class="label justify-start">
      <span class="label-text font-medium">Estado</span>
    </label>
    <select
      id="guardian_state"
      class="select select-bordered w-full"
      bind:value={formData.addresses_attributes[0].state}
      disabled={isLoading || useSameAddress}
      data-testid="guardian-state-input"
    >
      <option value="">Selecione...</option>
      {#each states as state}
        <option value={state.value}>{state.label}</option>
      {/each}
    </select>
  </div>
</div>

<!-- Bank Account Section -->
<div class="divider" aria-label="Seção de dados bancários">Dados Bancários - {guardianLabel}</div>

<!-- Checkbox to use same bank account -->
<div class="form-control">
  <label class="label cursor-pointer justify-start gap-2">
    <input
      type="checkbox"
      class="checkbox checkbox-primary"
      bind:checked={useSameBankAccount}
      onchange={() => onUseSameBankAccountChange({ checked: useSameBankAccount })}
      disabled={isLoading}
    />
    <span class="label-text">Usar mesma conta bancária do representado</span>
  </label>
</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Bank Name with Search -->
  <div class="form-control w-full relative">
    <label for="guardian_bank_name" class="label justify-start">
      <span class="label-text font-medium">Banco</span>
    </label>
    <div class="relative">
      <input
        id="guardian_bank_name"
        type="text"
        class="input input-bordered w-full"
        value={bankSearchTerm || formData.bank_accounts_attributes[0].bank_name}
        oninput={handleBankSearch}
        onfocus={handleBankInputFocus}
        onblur={handleBankInputBlur}
        onkeydown={handleBankKeydown}
        disabled={isLoading || useSameBankAccount}
        placeholder="Digite para buscar o banco..."
        autocomplete="off"
        data-testid="guardian-bank-name-input"
      />

      {#if showBankDropdown && !useSameBankAccount}
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
              onclick={() => selectBank(bank)}
              onmouseenter={() => (selectedDropdownIndex = index)}
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
    <label for="guardian_type_account" class="label justify-start">
      <span class="label-text font-medium">Tipo de Conta</span>
    </label>
    <select
      id="guardian_type_account"
      class="select select-bordered w-full"
      bind:value={formData.bank_accounts_attributes[0].type_account}
      disabled={isLoading || useSameBankAccount}
      data-testid="guardian-account-type-input"
    >
      <option value="Corrente">Corrente</option>
      <option value="Poupança">Poupança</option>
    </select>
  </div>

  <!-- Agency -->
  <div class="form-control w-full">
    <label for="guardian_agency" class="label justify-start">
      <span class="label-text font-medium">Agência</span>
    </label>
    <input
      id="guardian_agency"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.bank_accounts_attributes[0].agency}
      disabled={isLoading || useSameBankAccount}
      placeholder="0000-0"
      data-testid="guardian-agency-input"
    />
  </div>

  <!-- Account -->
  <div class="form-control w-full">
    <label for="guardian_account" class="label justify-start">
      <span class="label-text font-medium">Conta</span>
    </label>
    <input
      id="guardian_account"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.bank_accounts_attributes[0].account}
      disabled={isLoading || useSameBankAccount}
      placeholder="00000-0"
      data-testid="guardian-account-input"
    />
  </div>

  <!-- Operation (Only for Caixa Econômica - code 104) -->
  {#if showOperationField}
    <div class="form-control w-full">
      <label for="guardian_operation" class="label justify-start">
        <span class="label-text font-medium">Operação</span>
        <span class="label-text-alt text-info">(Caixa Econômica)</span>
      </label>
      <input
        id="guardian_operation"
        type="text"
        class="input input-bordered w-full"
        bind:value={formData.bank_accounts_attributes[0].operation}
        disabled={isLoading || useSameBankAccount}
        placeholder="Ex: 001, 013"
        data-testid="guardian-operation-input"
      />
    </div>
  {/if}

  <!-- PIX with reactive options (similar to Step 1) -->
  <div class="form-control w-full">
    <label for="guardian_pix" class="label justify-start">
      <span class="label-text font-medium">Chave PIX</span>
    </label>

    <!-- PIX Key Type Options -->
    <div class="flex gap-2 mb-2">
      <button
        type="button"
        class="btn btn-sm btn-outline"
        disabled={!formData.customer_attributes.email || isLoading || useSameBankAccount}
        onclick={() =>
          (formData.bank_accounts_attributes[0].pix = formData.customer_attributes.email)}
        aria-label="Usar e-mail como chave PIX"
        data-testid="guardian-pix-email-button"
      >
        E-mail
      </button>

      <button
        type="button"
        class="btn btn-sm btn-outline"
        disabled={!formData.cpf || isLoading || useSameBankAccount}
        onclick={() => (formData.bank_accounts_attributes[0].pix = formatCpfForPix(formData.cpf))}
        aria-label="Usar CPF como chave PIX"
        data-testid="guardian-pix-cpf-button"
      >
        CPF
      </button>

      <button
        type="button"
        class="btn btn-sm btn-outline"
        disabled={!formData.phones_attributes[0].number || isLoading || useSameBankAccount}
        onclick={() =>
          (formData.bank_accounts_attributes[0].pix = formatPhoneForPix(
            formData.phones_attributes[0].number
          ))}
        aria-label="Usar telefone como chave PIX"
        data-testid="guardian-pix-phone-button"
      >
        Telefone
      </button>
    </div>

    <input
      id="guardian_pix"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.bank_accounts_attributes[0].pix}
      disabled={isLoading || useSameBankAccount}
      data-testid="guardian-pix-input"
    />
    <div class="text-sm text-gray-500 mt-2">
      Escolha um dos botões acima para preencher automaticamente.
    </div>
  </div>
</div>
