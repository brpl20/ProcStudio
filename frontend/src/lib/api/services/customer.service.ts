/**
 * Customer Service
 * Handles all customer related API operations
 */

import type { HttpClient } from '../utils/http-client';
import type {
  // Customer Puro
  Customer,
  CreateCustomerRequest,
  UpdateCustomerRequest,
  CustomersListResponse,
  CustomerResponse,
  CreateCustomerResponse,
  UpdateCustomerResponse,
  DeleteCustomerResponse,
  // Profile Customer
  ProfileCustomer,
  CreateProfileCustomerRequest,
  UpdateProfileCustomerRequest,
  ProfileCustomersListResponse,
  ProfileCustomerResponse,
  CreateProfileCustomerResponse,
  UpdateProfileCustomerResponse,
  DeleteProfileCustomerResponse,
  // JSON:API types
  JsonApiCustomerData,
  JsonApiCustomerResponse,
  JsonApiCustomersListResponse,
  // Customer Portal
  CustomerLoginRequest,
  CustomerLoginResponse
} from '../types/customer.types';

export class CustomerService {
  private httpClient: HttpClient;

  constructor(httpClient: HttpClient) {
    this.httpClient = httpClient;
  }

  /**
   * Transform JSON:API customer data to our Customer type
   */
  private transformJsonApiCustomer(
    jsonApiData: JsonApiCustomerData,
    includedData?: JsonApiCustomerData[]
  ): Customer {
    // Find the associated profile_customer in included data
    let profileCustomer = undefined;
    if (includedData && jsonApiData.relationships?.profile_customer?.data) {
      const profileCustomerId = jsonApiData.relationships.profile_customer.data.id;
      profileCustomer = includedData.find(
        (item) => item.type === 'profile_customer' && item.id === profileCustomerId
      );
    }

    return {
      id: parseInt(jsonApiData.id),
      email: jsonApiData.attributes.access_email, // A API só retorna access_email
      access_email: jsonApiData.attributes.access_email,
      status: jsonApiData.attributes.status,
      confirmed_at: jsonApiData.attributes.confirmed_at,
      confirmed: jsonApiData.attributes.confirmed,
      deleted: jsonApiData.attributes.deleted,
      created_by_id: jsonApiData.attributes.created_by_id,
      profile_customer_id: jsonApiData.attributes.profile_customer_id,
      created_at: jsonApiData.attributes.created_at,
      // Include profile_customer data if available
      profile_customer: profileCustomer
        ? this.transformProfileCustomer(profileCustomer)
        : undefined,
      // A API não retorna updated_at e deleted_at no momento
      updated_at: undefined,
      deleted_at: undefined
    };
  }

  /**
   * Transform included profile_customer data
   */
  private transformProfileCustomer(includedProfileCustomer: JsonApiCustomerData): ProfileCustomer {
    return {
      id: includedProfileCustomer.id,
      type: includedProfileCustomer.type,
      attributes: {
        ...includedProfileCustomer.attributes,
        customer_type: includedProfileCustomer.attributes.customer_type,
        name: includedProfileCustomer.attributes.name,
        last_name: includedProfileCustomer.attributes.last_name,
        cpf: includedProfileCustomer.attributes.cpf,
        cnpj: includedProfileCustomer.attributes.cnpj,
        access_email: includedProfileCustomer.attributes.access_email,
        default_phone: includedProfileCustomer.attributes.default_phone,
        default_email: includedProfileCustomer.attributes.default_email,
        city: includedProfileCustomer.attributes.city,
        deleted: includedProfileCustomer.attributes.deleted
      },
      relationships: {
        addresses: includedProfileCustomer.attributes.addresses || [],
        bank_accounts: includedProfileCustomer.attributes.bank_accounts || [],
        emails: includedProfileCustomer.attributes.emails || [],
        phones: includedProfileCustomer.attributes.phones || []
      }
    };
  }

  /**
   * Get all customers - simple load all
   */
  async getCustomers(filters?: { deleted?: boolean }): Promise<CustomersListResponse> {
    try {
      const params = new URLSearchParams();
      if (filters?.deleted) {
        params.append('deleted', filters.deleted.toString());
      }

      const queryString = params.toString();
      const url = queryString ? `/customers?${queryString}` : '/customers';

      const response: JsonApiCustomersListResponse = await this.httpClient.get(url);

      // Transform JSON:API data to our Customer type
      const customers = Array.isArray(response.data)
        ? response.data.map((jsonApiData) =>
          this.transformJsonApiCustomer(jsonApiData, response.included)
        )
        : [];

      return {
        success: true,
        data: customers,
        meta: {
          total_count: customers.length
        },
        message: response.message || 'Clientes carregados com sucesso'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: [],
        message: error instanceof Error ? error.message : 'Erro ao carregar clientes'
      };
    }
  }

  /**
   * Get a specific customer by ID
   */
  async getCustomer(id: number): Promise<CustomerResponse> {
    try {
      // Add cache-busting header to avoid 304 issues
      const response: JsonApiCustomerResponse = await this.httpClient.get(`/customers/${id}`, {
        headers: {
          'Cache-Control': 'no-cache',
          Pragma: 'no-cache'
        }
      });

      // Handle empty response (e.g., from 304 Not Modified)
      if (!response || (!response.data && !response.included)) {
        return {
          success: false,
          data: {} as Customer,
          message: 'No customer data received (possibly cached). Please refresh and try again.'
        };
      }

      // Transform JSON:API data to our Customer type
      const customer = this.transformJsonApiCustomer(response.data, response.included);

      return {
        success: true,
        data: customer,
        message: response.message || 'Cliente carregado com sucesso'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Customer,
        message: error instanceof Error ? error.message : 'Erro ao carregar cliente'
      };
    }
  }

  /**
   * Create a new customer
   */
  async createCustomer(customerData: CreateCustomerRequest): Promise<CreateCustomerResponse> {
    try {
      const response: JsonApiCustomerResponse = await this.httpClient.post('/customers', {
        customer: customerData
      });

      // Transform JSON:API data to our Customer type
      const customer = this.transformJsonApiCustomer(response.data);

      return {
        success: true,
        data: customer,
        message: response.message || 'Cliente criado com sucesso'
      };
    } catch (error: unknown) {
      // Handle API validation errors (422)
      if (error?.status === 422 && error?.data?.errors) {
        const apiErrors = error.data.errors;
        const fieldErrors: Record<string, string> = {};

        // Parse field-specific errors if they exist
        if (Array.isArray(apiErrors)) {
          apiErrors.forEach((err: { detail: string }) => {
            if (err.field) {
              fieldErrors[err.field] = err.message;
            }
          });
        }

        return {
          success: false,
          data: {} as Customer,
          message:
            error instanceof Error ? error.message : error?.data?.message || 'Erro de validação',
          errors: fieldErrors
        };
      }

      // Handle other errors
      return {
        success: false,
        data: {} as Customer,
        message:
          error instanceof Error ? error.message : error?.data?.message || 'Erro ao criar cliente'
      };
    }
  }

  /**
   * Update an existing customer
   */
  async updateCustomer(
    id: number,
    customerData: UpdateCustomerRequest
  ): Promise<UpdateCustomerResponse> {
    try {
      const response: JsonApiCustomerResponse = await this.httpClient.patch(`/customers/${id}`, {
        customer: customerData
      });

      // Transform JSON:API data to our Customer type
      const customer = this.transformJsonApiCustomer(response.data);

      return {
        success: true,
        data: customer,
        message: response.message || 'Cliente atualizado com sucesso'
      };
    } catch (error: unknown) {
      // Handle API validation errors (422)
      if (error?.status === 422 && error?.data?.errors) {
        const apiErrors = error.data.errors;
        const fieldErrors: Record<string, string> = {};

        // Parse field-specific errors if they exist
        if (Array.isArray(apiErrors)) {
          apiErrors.forEach((err: { detail: string }) => {
            if (err.field) {
              fieldErrors[err.field] = err.message;
            }
          });
        }

        return {
          success: false,
          data: {} as Customer,
          message:
            error instanceof Error ? error.message : error?.data?.message || 'Erro de validação',
          errors: fieldErrors
        };
      }

      // Handle other errors
      return {
        success: false,
        data: {} as Customer,
        message:
          error instanceof Error
            ? error.message
            : error?.data?.message || 'Erro ao atualizar cliente'
      };
    }
  }

  /**
   * Delete a customer
   */
  async deleteCustomer(id: number): Promise<DeleteCustomerResponse> {
    try {
      await this.httpClient.delete(`/customers/${id}`);
      return {
        success: true,
        message: 'Customer deleted successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Failed to delete customer'
      };
    }
  }

  /**
   * Resend confirmation email
   */
  async resendConfirmation(customerId: number): Promise<{ success: boolean; message: string }> {
    try {
      await this.httpClient.post(`/customers/${customerId}/resend_confirmation`, {});
      return {
        success: true,
        message: 'Confirmation email sent successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Failed to send confirmation email'
      };
    }
  }

  // ProfileCustomer methods

  /**
   * Get all profile customers
   * @param typeOfParams - Filter parameter: 'active', 'only_deleted', 'with_deleted', or empty string
   */
  async getAllProfileCustomer(typeOfParams: string = ''): Promise<ProfileCustomersListResponse> {
    try {
      const url =
        typeOfParams !== '' ? `/profile_customers?deleted=${typeOfParams}` : '/profile_customers';

      const response = await this.httpClient.get(url);

      // Handle empty response (e.g., from 304 Not Modified)
      if (!response || (!response.data && !Array.isArray(response))) {
        return {
          success: true,
          data: [],
          meta: { total_count: 0 },
          message: 'No profile customers found'
        };
      }

      const data = response.data || response;
      const profileCustomers = Array.isArray(data) ? data : [];

      return {
        success: true,
        data: profileCustomers,
        meta: response.meta,
        message: response.message || 'Profile customers retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: [],
        message: error instanceof Error ? error.message : 'Failed to retrieve profile customers'
      };
    }
  }

  /**
   * Get all profile customers (legacy method)
   */
  async getProfileCustomers(filters?: {
    deleted?: boolean;
  }): Promise<ProfileCustomersListResponse> {
    try {
      const params = new URLSearchParams();
      if (filters?.deleted) {
        params.append('deleted', filters.deleted.toString());
      }

      const queryString = params.toString();
      const url = queryString ? `/profile_customers?${queryString}` : '/profile_customers';

      const response = await this.httpClient.get(url);
      return {
        success: true,
        data: response.data || response,
        meta: response.meta,
        message: 'Profile customers retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: [],
        message: error instanceof Error ? error.message : 'Failed to retrieve profile customers'
      };
    }
  }

  /**
   * Get all customers (following target repository pattern)
   */
  async getAllCustomers(): Promise<CustomersListResponse> {
    try {
      const response: JsonApiCustomersListResponse = await this.httpClient.get('/customers');

      // Handle empty response (e.g., from 304 Not Modified)
      if (!response || !response.data) {
        return {
          success: true,
          data: [],
          meta: { total_count: 0 },
          message: 'No customers found'
        };
      }

      // Transform JSON:API data to our Customer type
      const customers = Array.isArray(response.data)
        ? response.data.map((jsonApiData) =>
          this.transformJsonApiCustomer(jsonApiData, response.included)
        )
        : [];

      return {
        success: true,
        data: customers,
        meta: response.meta,
        message: response.message || 'Customers retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: [],
        message: error instanceof Error ? error.message : 'Failed to retrieve customers'
      };
    }
  }

  /**
   * Get a specific profile customer by ID
   */
  async getProfileCustomer(id: number, includeDeleted = false): Promise<ProfileCustomerResponse> {
    try {
      const url = includeDeleted
        ? `/profile_customers/${id}?include_deleted=true`
        : `/profile_customers/${id}`;
      const response = await this.httpClient.get(url);
      return {
        success: true,
        data: response.data || response,
        message: 'Profile customer retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as ProfileCustomer,
        message: error instanceof Error ? error.message : 'Failed to retrieve profile customer'
      };
    }
  }

  /**
   * Create a new profile customer
   */
  async createProfileCustomer(
    profileData: CreateProfileCustomerRequest,
    issueDocuments = false
  ): Promise<CreateProfileCustomerResponse> {
    try {
      // profileData already contains the nested structure, send it directly
      const payload = {
        profile_customer: profileData,
        issue_documents: issueDocuments
      };
      const response = await this.httpClient.post('/profile_customers', payload);
      return {
        success: true,
        data: response.data || response,
        message: 'Profile customer created successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as ProfileCustomer,
        message: error instanceof Error ? error.message : 'Failed to create profile customer'
      };
    }
  }

  /**
   * Update an existing profile customer
   */
  async updateProfileCustomer(
    id: number,
    profileData: UpdateProfileCustomerRequest,
    regenerateDocuments = false
  ): Promise<UpdateProfileCustomerResponse> {
    try {
      const payload = {
        profile_customer: profileData,
        regenerate_documents: regenerateDocuments
      };
      const response = await this.httpClient.patch(`/profile_customers/${id}`, payload);
      return {
        success: true,
        data: response.data || response,
        message: 'Profile customer updated successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as ProfileCustomer,
        message: error instanceof Error ? error.message : 'Failed to update profile customer'
      };
    }
  }

  /**
   * Inactive/Soft delete a profile customer (following target repository pattern)
   */
  async inactiveCustomer(id: number): Promise<DeleteProfileCustomerResponse> {
    try {
      await this.httpClient.delete(`/profile_customers/${id}`);
      return {
        success: true,
        message: 'Profile customer inactivated successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Failed to inactivate profile customer'
      };
    }
  }

  /**
   * Delete a profile customer (soft or permanent)
   */
  async deleteProfileCustomer(
    id: number,
    permanently = false
  ): Promise<DeleteProfileCustomerResponse> {
    try {
      const url = permanently
        ? `/profile_customers/${id}?destroy_fully=true`
        : `/profile_customers/${id}`;
      await this.httpClient.delete(url);
      return {
        success: true,
        message: 'Profile customer deleted successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Failed to delete profile customer'
      };
    }
  }

  /**
   * Restore a soft-deleted profile customer
   */
  async restoreProfileCustomer(id: number): Promise<ProfileCustomerResponse> {
    try {
      const response = await this.httpClient.post(`/profile_customers/${id}/restore`, {});
      return {
        success: true,
        data: response.data || response,
        message: 'Profile customer restored successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as ProfileCustomer,
        message: error instanceof Error ? error.message : 'Failed to restore profile customer'
      };
    }
  }

  // Customer Portal methods

  /**
   * Customer login
   */
  async customerLogin(credentials: CustomerLoginRequest): Promise<CustomerLoginResponse | null> {
    try {
      const response = await this.httpClient.post('/customer/login', {
        auth: credentials
      });

      // Store token and full_name
      if (response.token && response.full_name) {
        localStorage.setItem('customerToken', response.token);
        localStorage.setItem('customerName', response.full_name);
        return response;
      }

      return null;
    } catch {
      return null;
    }
  }

  /**
   * Customer logout
   */
  async customerLogout(): Promise<boolean> {
    try {
      const token = localStorage.getItem('customerToken');
      if (token) {
        await this.httpClient.delete('/customer/logout');
      }

      localStorage.removeItem('customerToken');
      localStorage.removeItem('customerName');
      return true;
    } catch {
      localStorage.removeItem('customerToken');
      localStorage.removeItem('customerName');
      return false;
    }
  }

  /**
   * Create a Represent relationship between two ProfileCustomers
   */
  async createRepresent(representData: {
    profile_customer_id: number; // The person being represented
    representor_id: number; // The person who represents
    relationship_type: string;
    active?: boolean;
  }): Promise<{ success: boolean; data?: Record<string, unknown>; message: string }> {
    try {
      const response = await this.httpClient.post('/represents', {
        represent: {
          ...representData,
          active: representData.active !== undefined ? representData.active : true
        }
      });
      return {
        success: true,
        data: response.data || response,
        message: 'Relacionamento criado com sucesso'
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Erro ao criar relacionamento'
      };
    }
  }
}
