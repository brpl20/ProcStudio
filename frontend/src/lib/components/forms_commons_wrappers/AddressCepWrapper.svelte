<script lang="ts">
  import FormSection from '../ui/FormSection.svelte';
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

  interface AddressData {
    street: string;
    number: string;
    complement: string;
    neighborhood: string;
    city: string;
    state: string;
    zip_code: string;
    address_type: string;
  }

  interface FieldConfig {
    id?: string;
    labelText?: string;
    placeholder?: string;
    required?: boolean;
    disabled?: boolean;
    show?: boolean;
  }

  interface AddressCepConfig {
    cep: FieldConfig;
    address: FieldConfig & {
      showRemoveButton?: boolean;
    };
  }

  type Props = {
    address?: AddressData;
    cepValue?: string;
    config: AddressCepConfig;
    title?: string;
    useAPIValidation?: boolean;
    showAddressInfo?: boolean;
    disabled?: boolean;
    onaddressfound?: (event: { detail: any; mappedAddress: AddressData }) => void;
  };

  let {
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
    cepValue = $bindable(''),
    config,
    title = 'Endereço',
    useAPIValidation = true,
    showAddressInfo = false,
    disabled = false,
    onaddressfound
  }: Props = $props();

  let cepErrors = $state<string | null>(null);
  let cepTouched = $state(false);
  let addressErrors = $state<Record<string, string>>({});
  let addressTouched = $state<Record<string, boolean>>({});

  function handleCepInput(event: CustomEvent) {
    cepValue = event.detail.value;
    address.zip_code = cepValue;
  }

  function handleCepBlur() {
    cepTouched = true;
  }

  function handleAddressFound(event: CustomEvent) {
    const addressData: AddressInfo = event.detail.address;
    const mappedAddress = mapCepToAddress(addressData);

    address = {
      ...address,
      street: mappedAddress.street || address.street,
      neighborhood: mappedAddress.neighborhood || address.neighborhood,
      city: mappedAddress.city || address.city,
      state: mappedAddress.state || address.state,
      zip_code: cepValue
    };

    onaddressfound?.({
      detail: event.detail,
      mappedAddress: address
    });

    // Focus on number field after successful CEP validation
    setTimeout(() => {
      const numberField = document.getElementById(`${config.address.id}-number`);
      numberField?.focus();
    }, 100);
  }

  function handleAddressInput(event: CustomEvent) {
    const { field, value } = event.detail;
    if (field === 'zip_code') {
      cepValue = value;
    }
  }
</script>

<FormSection {title}>
  {#snippet children()}
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      {#if config.cep.show !== false}
        <Cep
          bind:value={cepValue}
          bind:errors={cepErrors}
          bind:touched={cepTouched}
          id={config.cep.id || 'cep'}
          required={config.cep.required ?? false}
          labelText={config.cep.labelText || 'CEP'}
          placeholder={config.cep.placeholder || '00000-000'}
          {useAPIValidation}
          {showAddressInfo}
          disabled={disabled || config.cep.disabled}
          oninput={handleCepInput}
          onblur={handleCepBlur}
          onaddressfound={handleAddressFound}
        />
      {/if}
    </div>

    {#if config.address.show !== false}
      <Address
        bind:address
        showRemoveButton={config.address.showRemoveButton ?? false}
        disabled={disabled || config.address.disabled}
        id={config.address.id || 'address'}
        required={config.address.required ?? false}
        bind:errors={addressErrors}
        bind:touched={addressTouched}
        oninput={handleAddressInput}
      />
    {/if}
  {/snippet}
</FormSection>
