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
  // As props de ajuda do PIX foram removidas

  const dispatch = createEventDispatcher<{
    remove: void;
  }>();

  // Lógica de busca de banco
  let bankSearchTerm = '';
  let showBankDropdown = false;
  let selectedBankCode = '';
  let filteredBanks: BrazilianBank[] = [];
  let selectedDropdownIndex = -1;
  let hasFocused = false;

  $: showOperationField = selectedBankCode === '104'; // Apenas para Caixa Econômica

  $: if (bankAccount.bank_name) {
    const matchingBank = BRAZILIAN_BANKS.find((bank) => bank.label === bankAccount.bank_name);
    if (matchingBank) {
      selectedBankCode = matchingBank.value;
      bankAccount.bank_number = matchingBank.value;
    }
  }

  function handleBankSearch(event: Event) {
    const input = event.target as HTMLInputElement;
    bankSearchTerm = input.value;
    selectedDropdownIndex = -1;
    if (hasFocused && bankSearchTerm.length > 0) {
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
    if (bank.value !== '104') {
      bankAccount.operation = '';
    }
  }

  function handleBankInputFocus() {
    hasFocused = true;
    if (!bankSearchTerm && bankAccount.bank_name) {
      bankSearchTerm = bankAccount.bank_name;
    }
    if (bankSearchTerm.length > 0) {
      filteredBanks = searchBanks(bankSearchTerm).slice(0, 10);
      showBankDropdown = filteredBanks.length > 0;
    }
  }

  function handleBankInputBlur() {
    setTimeout(() => {
      showBankDropdown = false;
      selectedDropdownIndex = -1;
    }, 200);
  }

  function handleBankKeydown(event: KeyboardEvent) {
    if (!showBankDropdown) return;
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
        if (selectedDropdownIndex >= 0) selectBank(filteredBanks[selectedDropdownIndex]);
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
</script>

<div class="border rounded p-4 mb-4 {className}">
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    <!-- Nome do Banco com Busca -->
    <div class="form-control w-full relative">
      <label for="{labelPrefix}-name-{index}" class="label pb-1"><span class="label-text">Nome do Banco</span></label>
      <div class="relative">
        <input
          id="{labelPrefix}-name-{index}" type="text" class="input input-bordered input-sm w-full"
          value={bankSearchTerm || bankAccount.bank_name}
          on:input={handleBankSearch} on:focus={handleBankInputFocus} on:blur={handleBankInputBlur} on:keydown={handleBankKeydown}
          {disabled} placeholder="Digite para buscar o banco..." autocomplete="off"
        />
        {#if showBankDropdown}
          <div class="absolute z-10 w-full mt-1 bg-base-100 border border-base-300 rounded-lg shadow-lg max-h-60 overflow-y-auto">
            {#each filteredBanks as bank, dropdownIndex}
              <button
                type="button"
                class="w-full text-left px-4 py-2 hover:bg-base-200 focus:bg-base-200 focus:outline-none {selectedDropdownIndex === dropdownIndex ? 'bg-primary/20' : ''}"
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
      {#if selectedBankCode}<div class="text-sm text-base-content/60 mt-1">Código do banco: {selectedBankCode}</div>{/if}
    </div>

    <!-- Tipo de Conta -->
    <div class="form-control w-full">
      <label for="{labelPrefix}-type-{index}" class="label pb-1"><span class="label-text">Tipo de Conta</span></label>
      <select id="{labelPrefix}-type-{index}" class="select select-bordered select-sm w-full" bind:value={bankAccount.type_account} {disabled}>
        <option value="">Selecione...</option>
        {#each BANK_ACCOUNT_TYPES.filter((type) => type.value === 'Corrente' || type.value === 'Poupança') as accountType}
          <option value={accountType.value}>{accountType.label}</option>
        {/each}
      </select>
    </div>

    <!-- Agência -->
    <div class="form-control w-full">
      <label for="{labelPrefix}-agency-{index}" class="label pb-1"><span class="label-text">Agência</span></label>
      <input id="{labelPrefix}-agency-{index}" type="text" class="input input-bordered input-sm w-full" bind:value={bankAccount.agency} {disabled} placeholder="0000" />
    </div>

    <!-- Conta -->
    <div class="form-control w-full">
      <label for="{labelPrefix}-account-{index}" class="label pb-1"><span class="label-text">Conta</span></label>
      <input id="{labelPrefix}-account-{index}" type="text" class="input input-bordered input-sm w-full" bind:value={bankAccount.account} {disabled} placeholder="00000-0" />
    </div>

    <!-- Operação (Apenas para Caixa Econômica) -->
    {#if showOperationField}
      <div class="form-control w-full">
        <label for="{labelPrefix}-operation-{index}" class="label pb-1">
          <span class="label-text">Operação</span>
          <span class="label-text-alt text-info">(Caixa Econômica)</span>
        </label>
        <input id="{labelPrefix}-operation-{index}" type="text" class="input input-bordered input-sm w-full" bind:value={bankAccount.operation} {disabled} placeholder="000" />
      </div>
    {/if}

    <!-- ====================== PIX (SIMPLIFICADO) ====================== -->
    <div class="form-control w-full">
      <label for="{labelPrefix}-pix-{index}" class="label pb-1">
        <span class="label-text">PIX</span>
      </label>
      <input
        id="{labelPrefix}-pix-{index}"
        type="text"
        class="input input-bordered input-sm w-full"
        bind:value={bankAccount.pix}
        {disabled}
        placeholder="Chave PIX"
      />
    </div>
    <!-- ================================================================ -->
  </div>

  {#if showRemoveButton}
    <div class="flex justify-end mt-2">
      <button type="button" class="btn btn-error btn-sm" on:click={handleRemove} {disabled}>
        🗑️ Remover
      </button>
    </div>
  {/if}
</div>