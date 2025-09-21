<!-- AddressCepWrapper.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Address from '../forms_commons/Address.svelte';
  import Cep from '../forms_commons/Cep.svelte';
  import { mapCepToAddress } from '../../utils/cep-address-mapper';

  interface AddressInfo {
    logradouro: string;
    complemento?: string;
    bairro: string;
    localidade: string;
    uf: string;
    estado: string;
    cep?: string;
    ibge?: string;
    gia?: string;
    ddd?: string;
    siafi?: string;
  }

  // CEP props
  export let cepValue = '';
  export let cepErrors: string | null = null;
  export let cepTouched = false;
  export let cepId = 'cep';
  export let cepRequired = true;
  export let cepLabelText = 'CEP';
  export let cepPlaceholder = '00000-000';
  export let cepInputClass = '';
  export let cepWrapperClass = '';
  export let cepTestId: string | undefined = undefined;
  export let useAPIValidation = true;
  export let showAddressInfo = false;

  // Address props
  export let address = {
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    zip_code: '',
    address_type: 'main'
  };
  export let addressIndex = 0;
  export let showRemoveButton = true;
  export let addressDisabled = false;
  export let addressId = `address-${addressIndex}`;
  export let addressWrapperClass = '';
  export let addressRequired = false;
  export let addressErrors = {};
  export let addressTouched = {};

  // Common props
  export let disabled = false;

  const dispatch = createEventDispatcher();

  // Handle CEP events
  function handleCepInput(event: CustomEvent) {
    cepValue = event.detail.value;

    // Update zip_code in address when CEP changes
    address.zip_code = cepValue;

    dispatch('cep-input', event.detail);
  }

  function handleCepBlur(event: CustomEvent) {
    cepTouched = true;
    dispatch('cep-blur', event.detail);
  }

  function handleCepValidate(event: CustomEvent) {
    dispatch('cep-validate', event.detail);
  }

  // Handle address found from CEP validation
  function handleAddressFound(event: CustomEvent) {
    const addressData: AddressInfo = event.detail.address;

    // Map CEP response to address object
    const mappedAddress = mapCepToAddress(addressData);

    // Update address fields with data from CEP, preserving user-entered values
    address = {
      ...address,
      street: mappedAddress.street || address.street,
      neighborhood: mappedAddress.neighborhood || address.neighborhood,
      city: mappedAddress.city || address.city,
      state: mappedAddress.state || address.state,
      zip_code: cepValue // Always use the CEP value
    };

    dispatch('address-found', {
      ...event.detail,
      mappedAddress: address
    });
  }

  // Handle address input events
  function handleAddressInput(event: CustomEvent) {
    const { field, value, index } = event.detail;

    // Update CEP value if zip_code changes
    if (field === 'zip_code') {
      cepValue = value;
    }

    dispatch('address-input', event.detail);
  }

  function handleAddressBlur(event: CustomEvent) {
    dispatch('address-blur', event.detail);
  }

  function handleAddressRemove(event: CustomEvent) {
    dispatch('address-remove', event.detail);
  }
</script>

<div class="space-y-4">
  <!-- CEP Component -->
  <Cep
    bind:value={cepValue}
    bind:errors={cepErrors}
    bind:touched={cepTouched}
    id={cepId}
    required={cepRequired}
    labelText={cepLabelText}
    placeholder={cepPlaceholder}
    inputClass={cepInputClass}
    wrapperClass={cepWrapperClass}
    testId={cepTestId}
    {useAPIValidation}
    {showAddressInfo}
    {disabled}
    on:input={handleCepInput}
    on:blur={handleCepBlur}
    on:validate={handleCepValidate}
    on:address-found={handleAddressFound}
  />

  <!-- Address Component -->
  <Address
    bind:address
    index={addressIndex}
    {showRemoveButton}
    disabled={disabled || addressDisabled}
    id={addressId}
    wrapperClass={addressWrapperClass}
    required={addressRequired}
    bind:errors={addressErrors}
    bind:touched={addressTouched}
    on:input={handleAddressInput}
    on:blur={handleAddressBlur}
    on:remove={handleAddressRemove}
  />
</div>
