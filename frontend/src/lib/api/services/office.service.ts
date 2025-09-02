/**
 * Office Service
 * Handles all office related API operations
 */

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
  JsonApiOfficesWithLawyersResponse
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
      formatted_total_quotes_value: jsonApiData.attributes.formatted_total_quotes_value
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
    } catch (error: any) {
      return {
        success: false,
        message: error?.message || 'Erro ao carregar escritórios',
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
    } catch (error: any) {
      console.error('getOffice error:', error);
      return {
        success: false,
        message: error?.message || 'Erro ao carregar escritório',
        data: {} as Office
      };
    }
  }

  /**
   * Create a new office
   */
  async createOffice(officeData: CreateOfficeRequest): Promise<CreateOfficeResponse> {
    try {
      // Handle file upload for logo if needed
      const payload: any = {
        office: officeData
      };

      // If logo is a File object, we need to use FormData
      if (officeData.logo instanceof File) {
        const formData = new FormData();
        formData.append('office[logo]', officeData.logo);

        // Add other fields to FormData
        Object.keys(officeData).forEach((key) => {
          if (key !== 'logo') {
            const value = (officeData as any)[key];
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

      // Regular JSON request without file upload
      const response: JsonApiOfficeResponse = await this.httpClient.post('/offices', payload);

      // Transform JSON:API data to our Office type
      const office = this.transformJsonApiOffice(response.data);

      return {
        success: response.success,
        message: response.message,
        data: office
      };
    } catch (error: any) {
      console.error('Office creation error:', error);

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
        message: error?.message || error?.data?.message || 'Erro ao criar escritório',
        data: {} as Office
      };
    }
  }

  /**
   * Update an existing office
   */
  async updateOffice(id: number, officeData: UpdateOfficeRequest): Promise<UpdateOfficeResponse> {
    try {
      // Handle file upload for logo if needed
      if (officeData.logo instanceof File) {
        const formData = new FormData();
        formData.append('office[logo]', officeData.logo);

        // Add other fields to FormData
        Object.keys(officeData).forEach((key) => {
          if (key !== 'logo') {
            const value = (officeData as any)[key];
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

      // Regular JSON request without file upload
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
    } catch (error: any) {
      console.error('Office update error:', error);

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
        message: error?.message || error?.data?.message || 'Erro ao atualizar escritório',
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
    } catch (error: any) {
      return {
        success: false,
        message: error?.message || 'Erro ao remover escritório'
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
    } catch (error: any) {
      return {
        success: false,
        message: error?.message || 'Erro ao restaurar escritório',
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
      const response: JsonApiOfficesWithLawyersResponse = await this.httpClient.get(
        '/offices/with_lawyers'
      );

      // Transform JSON:API data
      const offices = Array.isArray(response.data)
        ? response.data.map((jsonApiData) => this.transformJsonApiOfficeWithLawyers(jsonApiData))
        : [];

      return {
        success: response.success,
        message: response.message,
        data: offices
      };
    } catch (error: any) {
      console.error('getOfficesWithLawyers error:', error);
      return {
        success: false,
        message: error?.message || 'Erro ao carregar escritórios com advogados',
        data: []
      };
    }
  }

  /**
   * Upload office logo
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
    } catch (error: any) {
      console.error('Logo upload error:', error);
      return {
        success: false,
        message: error?.message || 'Erro ao fazer upload do logo',
        data: {} as Office
      };
    }
  }

  /**
   * Upload social contracts (contrato social)
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
    } catch (error: any) {
      console.error('Social contracts upload error:', error);
      return {
        success: false,
        message: error?.message || 'Erro ao fazer upload dos contratos sociais',
        data: {} as Office
      };
    }
  }
}