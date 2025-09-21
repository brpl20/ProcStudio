/**
 * Office Form Processor
 *
 * Handles data transformation and processing for office forms,
 * ensuring proper serialization of nested attributes for API requests.
 */

import type { OfficeFormData, PartnerFormData, UserOfficeAttributes } from '../schemas/office-form';
import api from '../api';

export interface ProcessedOfficeData {
  formData: FormData | Record<string, unknown>;
  isMultipart: boolean;
}

/**
 * Process office form data for API submission
 * Handles both JSON and FormData based on file presence
 */
export function processOfficeFormData(
  formData: OfficeFormData,
  partners: PartnerFormData[],
  profitDistribution: string,
  createSocialContract: boolean,
  partnersWithProLabore: boolean,
  logoFile?: File | null,
  contractFiles?: File[]
): ProcessedOfficeData {
  // Determine if we need FormData (when files are present)
  const hasFiles = !!logoFile || (contractFiles && contractFiles.length > 0);

  // Filter and clean nested attributes
  const cleanedData = {
    // Basic fields
    name: formData.name,
    cnpj: formData.cnpj.replace(/\D/g, ''), // Remove formatting from CNPJ
    society: formData.society,
    foundation: formData.foundation,
    site: formData.site,
    accounting_type: formData.accounting_type,

    // OAB fields
    oab_id: formData.oab_id,
    oab_status: formData.oab_status,
    oab_inscricao: formData.oab_inscricao,
    oab_link: formData.oab_link,

    // Financial fields
    quote_value: formData.quote_value ? parseFloat(formData.quote_value) : undefined,
    number_of_quotes: formData.number_of_quotes ? parseInt(formData.number_of_quotes) : undefined,

    // Partnership metadata (only profit_distribution, others handled via user_offices_attributes)
    profit_distribution: profitDistribution
  };

  // Process nested attributes - filter out empty entries
  const processedPhones = formData.phones_attributes
    .filter((p) => p.phone_number?.trim())
    .map((p) => ({
      phone_number: p.phone_number.trim(),
      ...(p.id && { id: p.id })
    }));

  const processedEmails = formData.emails_attributes
    .filter((e) => e.email?.trim())
    .map((e) => ({
      email: e.email.trim(),
      ...(e.id && { id: e.id })
    }));

  const processedAddresses = formData.addresses_attributes
    .filter((a) => a.street?.trim() || a.zip_code?.trim())
    .map((a) => ({
      street: a.street.trim(),
      number: a.number.trim(),
      complement: a.complement?.trim() || '',
      neighborhood: a.neighborhood.trim(),
      city: a.city.trim(),
      state: a.state.trim(),
      zip_code: a.zip_code.trim(),
      address_type: a.address_type,
      ...(a.id && { id: a.id })
    }));

  const processedBankAccounts = formData.bank_accounts_attributes
    .filter((b) => b.bank_name?.trim())
    .map((b) => ({
      bank_name: b.bank_name.trim(),
      bank_number: b.bank_number?.trim() || '',
      type_account: b.type_account,
      agency: b.agency.trim(),
      account: b.account.trim(),
      operation: b.operation?.trim() || '',
      pix: b.pix?.trim() || '',
      ...(b.id && { id: b.id })
    }));

  // Process partners to user_offices_attributes
  const processedUserOffices: UserOfficeAttributes[] = partners
    .filter((p) => p.lawyer_id && p.partnership_type)
    .map((p) => ({
      user_id: typeof p.lawyer_id === 'string' ? parseInt(p.lawyer_id) : p.lawyer_id,
      partnership_type: p.partnership_type,
      partnership_percentage: p.ownership_percentage.toString(),
      pro_labore_amount: p.pro_labore_amount,
      is_managing_partner: p.is_managing_partner,
      _destroy: false
    }));

  // If we have files, create FormData
  if (hasFiles) {
    const formDataPayload = new FormData();

    // Add files
    if (logoFile) {
      formDataPayload.append('office[logo]', logoFile);
    }

    // Add scalar fields
    Object.entries(cleanedData).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        formDataPayload.append(`office[${key}]`, String(value));
      }
    });

    // Add nested attributes as JSON strings for Rails to parse
    if (processedPhones.length > 0) {
      formDataPayload.append('office[phones_attributes]', JSON.stringify(processedPhones));
    }
    if (processedEmails.length > 0) {
      formDataPayload.append('office[emails_attributes]', JSON.stringify(processedEmails));
    }
    if (processedAddresses.length > 0) {
      formDataPayload.append('office[addresses_attributes]', JSON.stringify(processedAddresses));
    }
    if (processedBankAccounts.length > 0) {
      formDataPayload.append(
        'office[bank_accounts_attributes]',
        JSON.stringify(processedBankAccounts)
      );
    }
    if (processedUserOffices.length > 0) {
      formDataPayload.append(
        'office[user_offices_attributes]',
        JSON.stringify(processedUserOffices)
      );
    }

    // Note: zip_code is included in addresses_attributes, no need to send separately

    return {
      formData: formDataPayload,
      isMultipart: true
    };
  }

  // Return JSON payload (zip_code is included in addresses_attributes)
  const jsonPayload = {
    ...cleanedData,
    ...(processedPhones.length > 0 && { phones_attributes: processedPhones }),
    ...(processedEmails.length > 0 && { emails_attributes: processedEmails }),
    ...(processedAddresses.length > 0 && { addresses_attributes: processedAddresses }),
    ...(processedBankAccounts.length > 0 && { bank_accounts_attributes: processedBankAccounts }),
    ...(processedUserOffices.length > 0 && { user_offices_attributes: processedUserOffices })
  };

  return {
    formData: jsonPayload,
    isMultipart: false
  };
}

/**
 * Submit office form data to API
 */
export async function submitOfficeForm(
  formData: OfficeFormData,
  partners: PartnerFormData[],
  profitDistribution: string,
  createSocialContract: boolean,
  partnersWithProLabore: boolean,
  logoFile?: File | null,
  contractFiles?: File[],
  officeId?: number
) {
  // Process form data
  const processed = processOfficeFormData(
    formData,
    partners,
    profitDistribution,
    createSocialContract,
    partnersWithProLabore,
    logoFile,
    contractFiles
  );

  let response;

  if (officeId) {
    // Update existing office
    response = await api.offices.updateOffice(officeId, processed.formData);
  } else {
    // Create new office
    response = await api.offices.createOffice(processed.formData);
  }

  // Upload contracts separately if provided and office was created/updated successfully
  if (response.success && contractFiles && contractFiles.length > 0 && response.data?.id) {
    try {
      await api.offices.uploadSocialContracts(response.data.id, contractFiles);
    } catch {
      // Contract upload failed but office was saved
      // Don't fail the whole operation
    }
  }

  return response;
}

/**
 * Validate partners data
 */
export function validatePartners(partners: PartnerFormData[]): {
  isValid: boolean;
  errors: string[];
} {
  const errors: string[] = [];

  if (partners.length === 0) {
    return { isValid: true, errors };
  }

  // Check for required fields
  partners.forEach((partner, index) => {
    if (partner.lawyer_id && !partner.partnership_type) {
      errors.push(`Sócio ${index + 1}: Função é obrigatória`);
    }
    if (partner.partnership_type && !partner.lawyer_id) {
      errors.push(`Sócio ${index + 1}: Advogado é obrigatório`);
    }
  });

  // Check percentage total for multiple partners
  if (partners.length > 1) {
    const validPartners = partners.filter((p) => p.lawyer_id && p.partnership_type);
    if (validPartners.length > 1) {
      const total = validPartners.reduce((sum, p) => sum + (p.ownership_percentage || 0), 0);
      if (total !== 100) {
        errors.push(`A soma das participações deve ser 100% (atual: ${total}%)`);
      }
    }
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}

/**
 * Auto-adjust partner percentages
 */
export function adjustPartnerPercentages(
  partners: PartnerFormData[],
  changedIndex: number,
  newPercentage: number
): PartnerFormData[] {
  const updatedPartners = [...partners];

  // For 2 partners, automatically adjust the other
  if (partners.length === 2) {
    const otherIndex = changedIndex === 0 ? 1 : 0;
    updatedPartners[changedIndex].ownership_percentage = newPercentage;
    updatedPartners[otherIndex].ownership_percentage = 100 - newPercentage;
  } else {
    updatedPartners[changedIndex].ownership_percentage = newPercentage;
  }

  return updatedPartners;
}

/**
 * Format partner display name
 */
export function formatPartnerName(partner: PartnerFormData): string {
  if (!partner.lawyer_name) {
    return 'Sócio não selecionado';
  }
  return partner.lawyer_name;
}

/**
 * Check if can add more partners based on available lawyers
 */
export function canAddMorePartners(
  currentPartnersCount: number,
  availableLawyersCount: number
): boolean {
  return currentPartnersCount < availableLawyersCount;
}
