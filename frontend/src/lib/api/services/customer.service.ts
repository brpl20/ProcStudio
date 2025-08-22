/**
 * Customer Service
 * Handles all customer related API operations
 */

import type { HttpClient } from '../utils/http-client';
import type {
  Customer,
  CreateCustomerRequest,
  UpdateCustomerRequest,
  CustomersListResponse,
  CustomerResponse,
  CreateCustomerResponse,
  UpdateCustomerResponse,
  DeleteCustomerResponse,
  ProfileCustomer,
  CreateProfileCustomerRequest,
  UpdateProfileCustomerRequest,
  ProfileCustomersListResponse,
  ProfileCustomerResponse,
  CreateProfileCustomerResponse,
  UpdateProfileCustomerResponse,
  DeleteProfileCustomerResponse,
  CustomerLoginRequest,
  CustomerLoginResponse
} from '../types/customer.types';

export class CustomerService {
  private httpClient: HttpClient;

  constructor(httpClient: HttpClient) {
    this.httpClient = httpClient;
  }

  /**
   * Get all customers
   */
  async getCustomers(filters?: { deleted?: boolean }): Promise<CustomersListResponse> {
    try {
      const params = new URLSearchParams();
      if (filters?.deleted) {
        params.append('deleted', filters.deleted.toString());
      }

      const queryString = params.toString();
      const url = queryString ? `/customers?${queryString}` : '/customers';

      const response = await this.httpClient.get(url);
      return {
        success: true,
        data: response.data || response,
        meta: response.meta,
        message: 'Customers retrieved successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        data: [],
        message: error?.message || 'Failed to retrieve customers'
      };
    }
  }

  /**
   * Get a specific customer by ID
   */
  async getCustomer(id: number): Promise<CustomerResponse> {
    try {
      const response = await this.httpClient.get(`/customers/${id}`);
      return {
        success: true,
        data: response.data || response,
        message: 'Customer retrieved successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        data: {} as Customer,
        message: error?.message || 'Failed to retrieve customer'
      };
    }
  }

  /**
   * Create a new customer
   */
  async createCustomer(customerData: CreateCustomerRequest): Promise<CreateCustomerResponse> {
    try {
      const response = await this.httpClient.post('/customers', { customer: customerData });
      return {
        success: true,
        data: response.data || response,
        message: 'Customer created successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        data: {} as Customer,
        message: error?.message || 'Failed to create customer'
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
      const response = await this.httpClient.patch(`/customers/${id}`, { customer: customerData });
      return {
        success: true,
        data: response.data || response,
        message: 'Customer updated successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        data: {} as Customer,
        message: error?.message || 'Failed to update customer'
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
    } catch (error: any) {
      return {
        success: false,
        message: error?.message || 'Failed to delete customer'
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
    } catch (error: any) {
      return {
        success: false,
        message: error?.message || 'Failed to send confirmation email'
      };
    }
  }

  // ProfileCustomer methods

  /**
   * Get all profile customers
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
    } catch (error: any) {
      return {
        success: false,
        data: [],
        message: error?.message || 'Failed to retrieve profile customers'
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
    } catch (error: any) {
      return {
        success: false,
        data: {} as ProfileCustomer,
        message: error?.message || 'Failed to retrieve profile customer'
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
    } catch (error: any) {
      return {
        success: false,
        data: {} as ProfileCustomer,
        message: error?.message || 'Failed to create profile customer'
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
    } catch (error: any) {
      return {
        success: false,
        data: {} as ProfileCustomer,
        message: error?.message || 'Failed to update profile customer'
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
    } catch (error: any) {
      return {
        success: false,
        message: error?.message || 'Failed to delete profile customer'
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
    } catch (error: any) {
      return {
        success: false,
        data: {} as ProfileCustomer,
        message: error?.message || 'Failed to restore profile customer'
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
    } catch (error: any) {
      console.error('Customer login failed:', error);
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
    } catch (error: any) {
      console.error('Customer logout failed:', error);
      localStorage.removeItem('customerToken');
      localStorage.removeItem('customerName');
      return false;
    }
  }
}
