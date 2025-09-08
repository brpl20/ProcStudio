/**
 * Work Service
 * Handles all work related API operations
 */

import type { HttpClient } from '../utils/http-client';
import type {
  Work,
  CreateWorkRequest,
  UpdateWorkRequest,
  WorksListResponse,
  WorkResponse,
  CreateWorkResponse,
  UpdateWorkResponse,
  DeleteWorkResponse,
  ConvertDocumentsResponse
} from '../types/work.types';

export class WorkService {
  private httpClient: HttpClient;

  constructor(httpClient: HttpClient) {
    this.httpClient = httpClient;
  }

  /**
   * Get all works
   */
  async getWorks(filters?: {
    customer_id?: number;
    deleted?: boolean;
    limit?: number;
  }): Promise<WorksListResponse> {
    try {
      const params = new URLSearchParams();
      if (filters?.customer_id) {
        params.append('customer_id', filters.customer_id.toString());
      }
      if (filters?.deleted) {
        params.append('deleted', filters.deleted.toString());
      }
      if (filters?.limit) {
        params.append('limit', filters.limit.toString());
      }

      const queryString = params.toString();
      const url = queryString ? `/works?${queryString}` : '/works';

      const response = await this.httpClient.get(url);
      return {
        success: true,
        data: response.data || response,
        meta: response.meta,
        message: 'Works retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: [],
        message: error instanceof Error ? error.message : 'Failed to retrieve works'
      };
    }
  }

  /**
   * Get a specific work by ID
   */
  async getWork(id: number): Promise<WorkResponse> {
    try {
      const response = await this.httpClient.get(`/works/${id}`);
      return {
        success: true,
        data: response.data || response,
        message: 'Work retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Work,
        message: error instanceof Error ? error.message : 'Failed to retrieve work'
      };
    }
  }

  /**
   * Create a new work
   */
  async createWork(workData: CreateWorkRequest): Promise<CreateWorkResponse> {
    try {
      const response = await this.httpClient.post('/works', { work: workData });
      return {
        success: true,
        data: response.data || response,
        message: 'Work created successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Work,
        message: error instanceof Error ? error.message : 'Failed to create work'
      };
    }
  }

  /**
   * Update an existing work
   */
  async updateWork(
    id: number,
    workData: UpdateWorkRequest,
    regenerateDocuments = false
  ): Promise<UpdateWorkResponse> {
    try {
      const payload = {
        work: workData,
        regenerate_documents: regenerateDocuments
      };
      const response = await this.httpClient.patch(`/works/${id}`, payload);
      return {
        success: true,
        data: response.data || response,
        message: 'Work updated successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Work,
        message: error instanceof Error ? error.message : 'Failed to update work'
      };
    }
  }

  /**
   * Delete a work (soft or permanent)
   */
  async deleteWork(id: number, permanently = false): Promise<DeleteWorkResponse> {
    try {
      const url = permanently ? `/works/${id}?destroy_fully=true` : `/works/${id}`;
      await this.httpClient.delete(url);
      return {
        success: true,
        message: 'Work deleted successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Failed to delete work'
      };
    }
  }

  /**
   * Restore a soft-deleted work
   */
  async restoreWork(id: number): Promise<WorkResponse> {
    try {
      const response = await this.httpClient.post(`/works/${id}/restore`, {});
      return {
        success: true,
        data: response.data || response,
        message: 'Work restored successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Work,
        message: error instanceof Error ? error.message : 'Failed to restore work'
      };
    }
  }

  /**
   * Convert documents to PDF
   */
  async convertDocumentsToPdf(
    workId: number,
    documentIds: number[]
  ): Promise<ConvertDocumentsResponse> {
    try {
      const response = await this.httpClient.post(`/works/${workId}/convert_documents_to_pdf`, {
        approved_documents: documentIds
      });
      return {
        success: true,
        message: response?.message || 'Documents converted successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Failed to convert documents'
      };
    }
  }
}
