/**
 * CEP to Address Mapping Utility
 * Handles the conversion of CEP API response data to Address component format
 */

export interface AddressData {
  street?: string;
  logradouro?: string;
  neighborhood?: string;
  bairro?: string;
  city?: string;
  localidade?: string;
  state?: string;
  uf?: string;
  complement?: string;
  complemento?: string;
}

export interface AddressAttributes {
  street: string;
  number: string;
  complement: string;
  neighborhood: string;
  city: string;
  state: string;
  zip_code: string;
  address_type: string;
}

/**
 * Maps CEP API response data to Address component format
 * Handles both Portuguese and English field names from API
 */
export function mapCepToAddress(
  cepData: AddressData,
  zipCode: string,
  existingAddress: Partial<AddressAttributes> = {}
): AddressAttributes {
  return {
    street: cepData.street || cepData.logradouro || existingAddress.street || '',
    neighborhood: cepData.neighborhood || cepData.bairro || existingAddress.neighborhood || '',
    city: cepData.city || cepData.localidade || existingAddress.city || '',
    state: cepData.state || cepData.uf || existingAddress.state || '',
    zip_code: zipCode,
    complement: cepData.complement || cepData.complemento || existingAddress.complement || '',
    number: existingAddress.number || '',
    address_type: existingAddress.address_type || 'main'
  };
}

/**
 * Creates a handler function for CEP address-found events
 * Returns a function that can be used as an event handler
 */
export function createCepAddressHandler(
  updateAddressCallback: (addressData: AddressAttributes) => void
) {
  return (event: CustomEvent) => {
    const { address, value: zipCode } = event.detail;
    if (address && zipCode) {
      const mappedAddress = mapCepToAddress(address, zipCode);
      updateAddressCallback(mappedAddress);
    }
  };
}