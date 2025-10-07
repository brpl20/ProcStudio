<!-- AddressCepWrapper.svelte -->
<script lang="ts">
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

  type Props = {
    // CEP props
    cepValue: string;
    cepErrors?: string | null;
    cepTouched?: boolean;
    cepId?: string;
    cepRequired?: boolean;
    cepLabelText?: string;
    cepPlaceholder?: string;
    cepInputClass?: string;
    cepWrapperClass?: string;
    cepTestId?: string;
    useAPIValidation?: boolean;
    showAddressInfo?: boolean;

    // Address props
    address: {
      street: string;
      number: string;
      complement: string;
      neighborhood: string;
      city: string;
      state: string;
      zip_code: string;
      address_type: string;
    };
    addressIndex?: number;
    showRemoveButton?: boolean;
    addressDisabled?: boolean;
    addressId?: string;
    addressWrapperClass?: string;
    addressRequired?: boolean;
    addressErrors?: Record<string, any>;
    addressTouched?: Record<string, any>;

    // Common props
    disabled?: boolean;

    // Event handlers
    onaddressfound?: (event: { detail: any; mappedAddress: any }) => void;
  };

  let {
    // CEP props
    cepValue = $bindable(''),
    cepErrors = $bindable(null),
    cepTouched = $bindable(false),
    cepId = 'cep',
    cepRequired = true,
    cepLabelText = 'CEP',
    cepPlaceholder = '00000-000',
    cepInputClass = '',
    cepWrapperClass = '',
    cepTestId = undefined,
    useAPIValidation = true,
    showAddressInfo = false,

    // Address props
    address = $bindable({
      street: '',
      number: '',
      complement: '',
      neighborhood: '',
      city: '',
      state: '',
      zip_code: '',
      address_type: 'main'
    }),
    addressIndex = 0,
    showRemoveButton = true,
    addressDisabled = false,
    addressId = `address-${addressIndex}`,
    addressWrapperClass = '',
    addressRequired = false,
    addressErrors = $bindable({}),
    addressTouched = $bindable({}),

    // Common props
    disabled = false,

    // Event handlers
    onaddressfound
  }: Props = $props();

  // Handle CEP events
  function handleCepInput(event: CustomEvent) {
    cepValue = event.detail.value;

    // Update zip_code in address when CEP changes
    address.zip_code = cepValue;

    // Additional event handling can be added here if needed
  }

  function handleCepBlur(event: CustomEvent) {
    cepTouched = true;
    // Additional event handling can be added here if needed
  }

  function handleCepValidate(event: CustomEvent) {
    // Additional event handling can be added here if needed
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

    onaddressfound?.({
      detail: event.detail,
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

    // Additional event handling can be added here if needed
  }

  function handleAddressBlur(event: CustomEvent) {
    // Additional event handling can be added here if needed
  }

  function handleAddressRemove(event: CustomEvent) {
    // Additional event handling can be added here if needed
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
    oninput={handleCepInput}
    onblur={handleCepBlur}
    onvalidate={handleCepValidate}
    onaddressfound={handleAddressFound}
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
    oninput={handleAddressInput}
    onblur={handleAddressBlur}
    onremove={handleAddressRemove}
  />
</div>
