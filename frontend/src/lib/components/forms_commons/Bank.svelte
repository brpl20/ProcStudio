<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { BRAZILIAN_BANKS, searchBanks } from '../../constants/brazilian-banks';
  import { BANK_ACCOUNT_TYPES } from '../../constants/bank-account-types';
  import type { BrazilianBank } from '../../constants/brazilian-banks';

  // Props
  export let bankAccount = {
    bank_name: '',
    bank_number: '',
    type_account: '',
    agency: '',
    account: '',
    operation: '',
    pix: ''
  };
  export let index = 0;
  export let disabled = false;
  export let showRemoveButton = false;
  export let labelPrefix = 'bank';
  export let className = '';
  export let showPixHelpers = false;
  export let pixHelperData = {
    email: '',
    cpf: '',
    cnpj: '',
    phone: ''
  };
  export let pixDocumentType = 'cpf'; // 'cpf' for persons, 'cnpj' for companies

  const dispatch = createEventDispatcher<{
    remove: void;
  }>();

  // Bank search state
  let bankSearchTerm = '';
  let showBankDropdown = false;
  let selectedBankCode = '';
  let filteredBanks: BrazilianBank[] = [];
  let selectedDropdownIndex = -1;

  // Reactive variables
  $: showOperationField = selectedBankCode === '104'; // Only for Caixa Econômica

  // Initialize bank search when bank name changes
  $: if (bankAccount.bank_name) {
    const matchingBank = BRAZILIAN_BANKS.find((bank) => bank.label === bankAccount.bank_name);
    if (matchingBank) {
      selectedBankCode = matchingBank.value;
      bankAccount.bank_number = matchingBank.value;
    }
  }

  // Bank search handlers
  function handleBankSearch(event: Event) {
    const input = event.target as HTMLInputElement;
    bankSearchTerm = input.value;
    selectedDropdownIndex = -1;

    if (bankSearchTerm.length > 0) {
      filteredBanks = searchBanks(bankSearchTerm).slice(0, 10);
      showBankDropdown = filteredBanks.length > 0;
    } else {
      showBankDropdown = false;
      filteredBanks = [];
    }
  }

  function selectBank(bank: BrazilianBank) {
    bankAccount.bank_name = bank.label;
    bankAccount.bank_number = bank.value;
    selectedBankCode = bank.value;
    bankSearchTerm = bank.label;
    showBankDropdown = false;
    selectedDropdownIndex = -1;

    // Clear operation field if not Caixa Econômica
    if (bank.value !== '104') {
      bankAccount.operation = '';
    }
  }

  function handleBankInputFocus() {
    if (!bankSearchTerm && bankAccount.bank_name) {
      bankSearchTerm = bankAccount.bank_name;
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

  function handleRemove() {
    dispatch('remove');
  }

  // PIX helper functions
  function formatCpfForPix(cpf: string): string {
    if (!cpf) {
      return '';
    }
    return cpf.replace(/[^\d]/g, '');
  }

  function formatCnpjForPix(cnpj: string): string {
    if (!cnpj) {
      return '';
    }
    return cnpj.replace(/[^\d]/g, '');
  }

  function formatPhoneForPix(phone: string): string {
    if (!phone) {
      return '';
    }
    return phone.replace(/[^\d]/g, '');
  }

  function setPixEmail() {
    if (pixHelperData.email) {
      bankAccount.pix = pixHelperData.email;
    }
  }

  function setPixDocument() {
    if (pixDocumentType === 'cpf' && pixHelperData.cpf) {
      bankAccount.pix = formatCpfForPix(pixHelperData.cpf);
    } else if (pixDocumentType === 'cnpj' && pixHelperData.cnpj) {
      bankAccount.pix = formatCnpjForPix(pixHelperData.cnpj);
    }
  }

  function setPixPhone() {
    if (pixHelperData.phone) {
      bankAccount.pix = formatPhoneForPix(pixHelperData.phone);
    }
  }

  // Reactive variables for PIX helpers
  $: documentLabel = pixDocumentType === 'cpf' ? 'CPF' : 'CNPJ';
  $: hasDocumentData = pixDocumentType === 'cpf' ? !!pixHelperData.cpf : !!pixHelperData.cnpj;
</script>

<div class="border rounded p-4 mb-4 {className}">
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    <!-- Bank Name with Search -->
    <div class="form-control w-full relative">
      <label for="{labelPrefix}-name-{index}" class="label pb-1">
        <span class="label-text">Nome do Banco</span>
      </label>
      <div class="relative">
        <input
          id="{labelPrefix}-name-{index}"
          type="text"
          class="input input-bordered input-sm w-full"
          value={bankSearchTerm || bankAccount.bank_name}
          on:input={handleBankSearch}
          on:focus={handleBankInputFocus}
          on:blur={handleBankInputBlur}
          on:keydown={handleBankKeydown}
          {disabled}
          placeholder="Digite para buscar o banco..."
          autocomplete="off"
          data-testid="{labelPrefix}-name-input-{index}"
        />

        {#if showBankDropdown}
          <div
            class="absolute z-10 w-full mt-1 bg-base-100 border border-base-300 rounded-lg shadow-lg max-h-60 overflow-y-auto"
          >
            {#each filteredBanks as bank, dropdownIndex}
              <button
                type="button"
                class="w-full text-left px-4 py-2 hover:bg-base-200 focus:bg-base-200 focus:outline-none {selectedDropdownIndex ===
                dropdownIndex
                  ? 'bg-primary/20'
                  : ''}"
                on:click={() => selectBank(bank)}
                on:mouseenter={() => (selectedDropdownIndex = dropdownIndex)}
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
      <label for="{labelPrefix}-type-{index}" class="label pb-1">
        <span class="label-text">Tipo de Conta</span>
      </label>
      <select
        id="{labelPrefix}-type-{index}"
        class="select select-bordered select-sm w-full"
        bind:value={bankAccount.type_account}
        {disabled}
        data-testid="{labelPrefix}-type-input-{index}"
      >
        <option value="">Selecione...</option>
        {#each BANK_ACCOUNT_TYPES.filter((type) => type.value === 'Corrente' || type.value === 'Poupança') as accountType}
          <option value={accountType.value}>{accountType.label}</option>
        {/each}
      </select>
    </div>

    <!-- Agency -->
    <div class="form-control w-full">
      <label for="{labelPrefix}-agency-{index}" class="label pb-1">
        <span class="label-text">Agência</span>
      </label>
      <input
        id="{labelPrefix}-agency-{index}"
        type="text"
        class="input input-bordered input-sm w-full"
        bind:value={bankAccount.agency}
        {disabled}
        placeholder="0000"
        data-testid="{labelPrefix}-agency-input-{index}"
      />
    </div>

    <!-- Account -->
    <div class="form-control w-full">
      <label for="{labelPrefix}-account-{index}" class="label pb-1">
        <span class="label-text">Conta</span>
      </label>
      <input
        id="{labelPrefix}-account-{index}"
        type="text"
        class="input input-bordered input-sm w-full"
        bind:value={bankAccount.account}
        {disabled}
        placeholder="00000-0"
        data-testid="{labelPrefix}-account-input-{index}"
      />
    </div>

    <!-- Operation (Only for Caixa Econômica - code 104) -->
    {#if showOperationField}
      <div class="form-control w-full">
        <label for="{labelPrefix}-operation-{index}" class="label pb-1">
          <span class="label-text">Operação</span>
          <span class="label-text-alt text-info">(Caixa Econômica)</span>
        </label>
        <input
          id="{labelPrefix}-operation-{index}"
          type="text"
          class="input input-bordered input-sm w-full"
          bind:value={bankAccount.operation}
          {disabled}
          placeholder="000"
          data-testid="{labelPrefix}-operation-input-{index}"
        />
      </div>
    {/if}

    <!-- PIX -->
    <div class="form-control w-full {showPixHelpers ? 'col-span-full' : ''}">
      <label for="{labelPrefix}-pix-{index}" class="label pb-1">
        <span class="label-text">PIX</span>
      </label>

      {#if showPixHelpers}
        <!-- PIX Key Type Options -->
        <div class="flex gap-2 mb-2">
          <button
            type="button"
            class="btn btn-sm btn-outline"
            disabled={!pixHelperData.email || disabled}
            on:click={setPixEmail}
            aria-label="Usar e-mail como chave PIX"
            data-testid="pix-email-button-{index}"
          >
            E-mail
          </button>

          <button
            type="button"
            class="btn btn-sm btn-outline"
            disabled={!hasDocumentData || disabled}
            on:click={setPixDocument}
            aria-label="Usar {documentLabel} como chave PIX"
            data-testid="pix-document-button-{index}"
          >
            {documentLabel}
          </button>

          <button
            type="button"
            class="btn btn-sm btn-outline"
            disabled={!pixHelperData.phone || disabled}
            on:click={setPixPhone}
            aria-label="Usar telefone como chave PIX"
            data-testid="pix-phone-button-{index}"
          >
            Telefone
          </button>
        </div>
      {/if}

      <input
        id="{labelPrefix}-pix-{index}"
        type="text"
        class="input input-bordered input-sm w-full"
        bind:value={bankAccount.pix}
        {disabled}
        placeholder="Chave PIX"
        data-testid="{labelPrefix}-pix-input-{index}"
      />

      {#if showPixHelpers}
        <div class="text-sm text-gray-500 mt-2">
          Escolha um dos botões acima para preencher automaticamente.
        </div>
      {/if}
    </div>
  </div>

  {#if showRemoveButton}
    <div class="flex justify-end mt-2">
      <button type="button" class="btn btn-error btn-sm" on:click={handleRemove} {disabled}>
        🗑️ Remover
      </button>
    </div>
  {/if}
</div>
