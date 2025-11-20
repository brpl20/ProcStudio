import type { HttpClient } from '../utils/http-client';
import type {
  Office,
  OfficeWithLawyers,
  CreateOfficeRequest,
  UpdateOfficeRequest,
  OfficesListResponse,
  OfficeResponse,
  CreateOfficeResponse,
  UpdateOfficeResponse,
  DeleteOfficeResponse,
  RestoreOfficeResponse,
  OfficesWithLawyersResponse,
  JsonApiOfficeData,
  JsonApiOfficeWithLawyersData,
  JsonApiOfficeResponse,
  JsonApiOfficesListResponse,
  JsonApiOfficesWithLawyersResponse,
  UploadLogoRequest,
  UploadContractsRequest,
  UpdateAttachmentMetadataRequest,
  AttachmentOperationResponse
} from '../types/office.types';

export class OfficeService {
  private httpClient: HttpClient;

  constructor(httpClient: HttpClient) {
    this.httpClient = httpClient;
  }

  /**
   * Transform JSON:API office data to our Office type
   */
  private transformJsonApiOffice(jsonApiData: JsonApiOfficeData): Office {
    return {
      id: parseInt(jsonApiData.id),
      name: jsonApiData.attributes.name,
      cnpj: jsonApiData.attributes.cnpj,
      site: jsonApiData.attributes.site,
      quote_value: jsonApiData.attributes.quote_value,
      number_of_quotes: jsonApiData.attributes.number_of_quotes,
      total_quotes_value: jsonApiData.attributes.total_quotes_value,
      city: jsonApiData.attributes.city,
      state: jsonApiData.attributes.state,
      deleted: jsonApiData.attributes.deleted,
      // Additional attributes for 'show' action
      society: jsonApiData.attributes.society,
      foundation: jsonApiData.attributes.foundation,
      addresses: jsonApiData.attributes.addresses,
      phones: jsonApiData.attributes.phones,
      emails: jsonApiData.attributes.emails,
      bank_accounts: jsonApiData.attributes.bank_accounts,
      works: jsonApiData.attributes.works,
      accounting_type: jsonApiData.attributes.accounting_type,
      oab_id: jsonApiData.attributes.oab_id,
      oab_inscricao: jsonApiData.attributes.oab_inscricao,
      oab_link: jsonApiData.attributes.oab_link,
      oab_status: jsonApiData.attributes.oab_status,
      formatted_total_quotes_value: jsonApiData.attributes.formatted_total_quotes_value,
      // Attachments
      logo_url: jsonApiData.attributes.logo_url,
      social_contracts_with_metadata: jsonApiData.attributes.social_contracts_with_metadata
    };
  }

  /**
   * Transform JSON:API office with lawyers data
   */
  private transformJsonApiOfficeWithLawyers(
    jsonApiData: JsonApiOfficeWithLawyersData
  ): OfficeWithLawyers {
    return {
      id: parseInt(jsonApiData.id),
      name: jsonApiData.attributes.name,
      quote_value: jsonApiData.attributes.quote_value,
      number_of_quotes: jsonApiData.attributes.number_of_quotes,
      total_quotes_value: jsonApiData.attributes.total_quotes_value,
      lawyers: jsonApiData.attributes.lawyers
    };
  }

  /**
   * Get all offices
   */
  async getOffices(filters?: { deleted?: boolean }): Promise<OfficesListResponse> {
    try {
      const params = new URLSearchParams();
      if (filters?.deleted !== undefined) {
        params.append('deleted', filters.deleted.toString());
      }

      const queryString = params.toString();
      const url = queryString ? `/offices?${queryString}` : '/offices';

      const response: JsonApiOfficesListResponse = await this.httpClient.get(url);

      // Transform JSON:API data to our Office type
      const offices = Array.isArray(response.data)
        ? response.data.map((jsonApiData) => this.transformJsonApiOffice(jsonApiData))
        : [];

      return {
        success: response.success,
        message: response.message,
        data: offices,
        meta: response.meta
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao carregar escritórios',
        data: []
      };
    }
  }

  /**
   * Get a specific office by ID
   */
  async getOffice(id: number): Promise<OfficeResponse> {
    try {
      const response: JsonApiOfficeResponse = await this.httpClient.get(`/offices/${id}`, {
        headers: {
          'Cache-Control': 'no-cache',
          Pragma: 'no-cache'
        }
      });

      // Handle empty response
      if (!response || !response.data) {
        return {
          success: false,
          message: 'Nenhum dado de escritório recebido',
          data: {} as Office
        };
      }

      // Transform JSON:API data to our Office type
      const office = this.transformJsonApiOffice(response.data);

      return {
        success: response.success,
        message: response.message,
        data: office
      };
    } catch (error: unknown) {
      // console.error('getOffice error:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao carregar escritório',
        data: {} as Office
      };
    }
  }

  /**
   * Create a new office
   */
  async createOffice(officeData: CreateOfficeRequest | FormData): Promise<CreateOfficeResponse> {
    try {
      // Handle FormData (when files are present) or direct data from processor
      if (officeData instanceof FormData) {
        // FormData is already properly formatted by the processor
        const response = await this.httpClient.post('/offices', officeData, {
          headers: {} // Override default Content-Type
        });

        return {
          success: response.success,
          message: response.message,
          data: this.transformJsonApiOffice(response.data)
        };
      }

      // Handle legacy File object check for backwards compatibility
      if (officeData.logo instanceof File) {
        const formData = new FormData();
        formData.append('office[logo]', officeData.logo);

        // Add other fields to FormData
        Object.keys(officeData).forEach((key) => {
          if (key !== 'logo') {
            const value = officeData[key as keyof CreateOfficeRequest];
            if (value !== undefined && value !== null) {
              if (typeof value === 'object') {
                formData.append(`office[${key}]`, JSON.stringify(value));
              } else {
                formData.append(`office[${key}]`, value);
              }
            }
          }
        });

        // Note: When using FormData, don't set Content-Type header
        // The browser will set it automatically with the correct boundary
        const response = await this.httpClient.post('/offices', formData, {
          headers: {} // Override default Content-Type
        });

        return {
          success: response.success,
          message: response.message,
          data: this.transformJsonApiOffice(response.data)
        };
      }

      // Regular JSON request - wrap in office key as expected by Rails API
      const payload: { office: CreateOfficeRequest } = {
        office: officeData
      };

      const response: JsonApiOfficeResponse = await this.httpClient.post('/offices', payload);

      // Transform JSON:API data to our Office type
      const office = this.transformJsonApiOffice(response.data);

      return {
        success: response.success,
        message: response.message,
        data: office
      };
    } catch (error: unknown) {
      // console.error('Office creation error:', error);

      // Handle API validation errors
      if (error?.status === 422 && error?.data?.errors) {
        return {
          success: false,
          message: error?.data?.message || 'Erro de validação',
          data: {} as Office,
          errors: error.data.errors
        };
      }

      return {
        success: false,
        message:
          error instanceof Error
            ? error.message
            : error?.data?.message || 'Erro ao criar escritório',
        data: {} as Office
      };
    }
  }

  /**
   * Update an existing office
   */
  async updateOffice(
    id: number,
    officeData: UpdateOfficeRequest | FormData
  ): Promise<UpdateOfficeResponse> {
    try {
      // Handle FormData (when files are present) or direct data from processor
      if (officeData instanceof FormData) {
        // FormData is already properly formatted by the processor
        const response = await this.httpClient.patch(`/offices/${id}`, officeData, {
          headers: {} // Override default Content-Type
        });

        return {
          success: response.success,
          message: response.message,
          data: this.transformJsonApiOffice(response.data)
        };
      }

      // Handle legacy File object check for backwards compatibility
      if (officeData.logo instanceof File) {
        const formData = new FormData();
        formData.append('office[logo]', officeData.logo);

        // Add other fields to FormData
        Object.keys(officeData).forEach((key) => {
          if (key !== 'logo') {
            const value = officeData[key as keyof UpdateOfficeRequest];
            if (value !== undefined && value !== null) {
              if (typeof value === 'object') {
                formData.append(`office[${key}]`, JSON.stringify(value));
              } else {
                formData.append(`office[${key}]`, value);
              }
            }
          }
        });

        const response = await this.httpClient.patch(`/offices/${id}`, formData, {
          headers: {} // Override default Content-Type
        });

        return {
          success: response.success,
          message: response.message,
          data: this.transformJsonApiOffice(response.data)
        };
      }

      // Regular JSON request - wrap in office key as expected by Rails API
      const response: JsonApiOfficeResponse = await this.httpClient.patch(`/offices/${id}`, {
        office: officeData
      });

      // Transform JSON:API data to our Office type
      const office = this.transformJsonApiOffice(response.data);

      return {
        success: response.success,
        message: response.message,
        data: office
      };
    } catch (error: unknown) {
      // console.error('Office update error:', error);

      // Handle API validation errors
      if (error?.status === 422 && error?.data?.errors) {
        return {
          success: false,
          message: error?.data?.message || 'Erro de validação',
          data: {} as Office,
          errors: error.data.errors
        };
      }

      return {
        success: false,
        message:
          error instanceof Error
            ? error.message
            : error?.data?.message || 'Erro ao atualizar escritório',
        data: {} as Office
      };
    }
  }

  /**
   * Delete an office (soft delete by default)
   */
  async deleteOffice(id: number, permanently = false): Promise<DeleteOfficeResponse> {
    try {
      const url = permanently ? `/offices/${id}?destroy_fully=true` : `/offices/${id}`;
      const response = await this.httpClient.delete(url);

      return {
        success: response.success,
        message: response.message,
        data: response.data
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao remover escritório'
      };
    }
  }

  /**
   * Restore a soft-deleted office
   */
  async restoreOffice(id: number): Promise<RestoreOfficeResponse> {
    try {
      const response: JsonApiOfficeResponse = await this.httpClient.post(
        `/offices/${id}/restore`,
        {}
      );

      const office = this.transformJsonApiOffice(response.data);

      return {
        success: response.success,
        message: response.message,
        data: office
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao restaurar escritório',
        data: {} as Office,
        errors: error?.data?.errors
      };
    }
  }

  /**
   * Get offices with lawyers
   */
  async getOfficesWithLawyers(): Promise<OfficesWithLawyersResponse> {
    try {
      const response: JsonApiOfficesWithLawyersResponse =
        await this.httpClient.get('/offices/with_lawyers');

      // Transform JSON:API data
      const offices = Array.isArray(response.data)
        ? response.data.map((jsonApiData) => this.transformJsonApiOfficeWithLawyers(jsonApiData))
        : [];

      return {
        success: response.success,
        message: response.message,
        data: offices
      };
    } catch (error: unknown) {
      // console.error('getOfficesWithLawyers error:', error);
      return {
        success: false,
        message:
          error instanceof Error ? error.message : 'Erro ao carregar escritórios com advogados',
        data: []
      };
    }
  }

  /**
   * Upload office logo using the dedicated endpoint.
   * POST /api/v1/offices/:id/upload_logo
   */
  async uploadOfficeLogo(officeId: number, logoFile: File): Promise<AttachmentOperationResponse> {
    try {
      const formData = new FormData();
      formData.append('logo', logoFile);

      const response = await this.httpClient.post(`/offices/${officeId}/upload_logo`, formData, {
        headers: {} // Browser sets Content-Type for FormData
      });

      return response as AttachmentOperationResponse;
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao fazer upload do logo.',
        errors: error?.data?.errors
      };
    }
  }

  /**
   * Upload office social contracts using the dedicated endpoint.
   * POST /api/v1/offices/:id/upload_contracts
   */
  async uploadOfficeContracts(
    officeId: number,
    contractFiles: File[]
  ): Promise<AttachmentOperationResponse> {
    try {
      const formData = new FormData();
      contractFiles.forEach((file) => {
        formData.append('contracts[]', file);
      });

      const response = await this.httpClient.post(
        `/offices/${officeId}/upload_contracts`,
        formData,
        {
          headers: {} // Browser sets Content-Type for FormData
        }
      );

      return response as AttachmentOperationResponse;
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao fazer upload dos contratos.',
        errors: error?.data?.errors
      };
    }
  }

  /**
   * Upload office logo
   * @deprecated Use uploadOfficeLogo for the new endpoint
   */
  async uploadLogo(officeId: number, logoFile: File): Promise<UpdateOfficeResponse> {
    try {
      const formData = new FormData();
      formData.append('office[logo]', logoFile);

      const response = await this.httpClient.patch(`/offices/${officeId}`, formData, {
        headers: {} // Let browser set Content-Type with boundary
      });

      return {
        success: response.success,
        message: response.message || 'Logo atualizado com sucesso',
        data: this.transformJsonApiOffice(response.data)
      };
    } catch (error: unknown) {
      // console.error('Logo upload error:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao fazer upload do logo',
        data: {} as Office
      };
    }
  }

  /**
   * Upload social contracts (contrato social)
   * @deprecated Use uploadOfficeContracts for the new endpoint
   */
  async uploadSocialContracts(
    officeId: number,
    contractFiles: File[]
  ): Promise<UpdateOfficeResponse> {
    try {
      const formData = new FormData();
      contractFiles.forEach((file) => {
        formData.append('office[social_contracts][]', file);
      });

      const response = await this.httpClient.patch(`/offices/${officeId}`, formData, {
        headers: {} // Let browser set Content-Type with boundary
      });

      return {
        success: response.success,
        message: response.message || 'Contratos sociais atualizados com sucesso',
        data: this.transformJsonApiOffice(response.data)
      };
    } catch (error: unknown) {
      // console.error('Social contracts upload error:', error);
      return {
        success: false,
        message:
          error instanceof Error ? error.message : 'Erro ao fazer upload dos contratos sociais',
        data: {} as Office
      };
    }
  }

  /**
   * Upload logo with metadata using dedicated endpoint
   */
  async uploadLogoWithMetadata(
    officeId: number,
    request: UploadLogoRequest
  ): Promise<AttachmentOperationResponse> {
    try {
      const formData = new FormData();
      formData.append('logo', request.logo);

      if (request.document_date) {
        formData.append('document_date', request.document_date);
      }
      if (request.description) {
        formData.append('description', request.description);
      }
      if (request.custom_metadata) {
        formData.append('custom_metadata', JSON.stringify(request.custom_metadata));
      }

      const response = await this.httpClient.post(`/offices/${officeId}/upload_logo`, formData, {
        headers: {} // Let browser set Content-Type with boundary
      });

      return response as AttachmentOperationResponse;
    } catch (error: unknown) {
      // console.error('Logo upload with metadata error:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao fazer upload do logo',
        errors: error?.data?.errors
      };
    }
  }

  /**
   * Upload contracts with metadata using dedicated endpoint
   */
  async uploadContractsWithMetadata(
    officeId: number,
    request: UploadContractsRequest
  ): Promise<AttachmentOperationResponse> {
    try {
      const formData = new FormData();

      // Add contract files
      request.contracts.forEach((file) => {
        formData.append('contracts[]', file);
      });

      // Add global metadata
      if (request.document_date) {
        formData.append('document_date', request.document_date);
      }
      if (request.description) {
        formData.append('description', request.description);
      }
      if (request.custom_metadata) {
        formData.append('custom_metadata', JSON.stringify(request.custom_metadata));
      }

      // Add per-file metadata if provided
      if (request.contract_metadata) {
        Object.entries(request.contract_metadata).forEach(([filename, metadata]) => {
          if (metadata.document_date) {
            formData.append(`document_date_${filename}`, metadata.document_date);
          }
          if (metadata.description) {
            formData.append(`description_${filename}`, metadata.description);
          }
          if (metadata.custom_metadata) {
            formData.append(
              `custom_metadata_${filename}`,
              JSON.stringify(metadata.custom_metadata)
            );
          }
        });
      }

      const response = await this.httpClient.post(
        `/offices/${officeId}/upload_contracts`,
        formData,
        {
          headers: {} // Let browser set Content-Type with boundary
        }
      );

      return response as AttachmentOperationResponse;
    } catch (error: unknown) {
      // console.error('Contracts upload with metadata error:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao fazer upload dos contratos',
        errors: error?.data?.errors
      };
    }
  }

  /**
   * Remove a specific attachment
   */
  async removeAttachment(
    officeId: number,
    attachmentId: number
  ): Promise<AttachmentOperationResponse> {
    try {
      const response = await this.httpClient.delete(
        `/offices/${officeId}/attachments/${attachmentId}`
      );

      return response as AttachmentOperationResponse;
    } catch (error: unknown) {
      // console.error('Remove attachment error:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao remover anexo',
        errors: error?.data?.errors
      };
    }
  }

  /**
   * Update attachment metadata
   */
  async updateAttachmentMetadata(
    officeId: number,
    request: UpdateAttachmentMetadataRequest
  ): Promise<AttachmentOperationResponse> {
    try {
      const response = await this.httpClient.patch(
        `/offices/${officeId}/attachments/metadata`,
        request
      );

      return response as AttachmentOperationResponse;
    } catch (error: unknown) {
      // console.error('Update attachment metadata error:', error);
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao atualizar metadados do anexo',
        errors: error?.data?.errors
      };
    }
  }

  /**
   * Validate file type for contracts (PDF and DOCX only)
   */
  validateContractFile(file: File): boolean {
    const validTypes = [
      'application/pdf',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ];
    return validTypes.includes(file.type);
  }

  /**
   * Validate file type for logo (images only)
   */
  validateLogoFile(file: File): boolean {
    const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    return validTypes.includes(file.type);
  }
}