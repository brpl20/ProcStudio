/**
 * Draft Service
 * Handles all draft-related API operations
 */

import type { HttpClient } from '../utils/http-client';
import type {
  Draft,
  CreateDraftRequest,
  UpdateDraftRequest,
  FulfillDraftRequest,
  DraftsListResponse,
  DraftResponse,
  CreateDraftResponse,
  UpdateDraftResponse,
  DeleteDraftResponse,
  FulfillDraftResponse,
  RecoverDraftResponse
} from '../types/draft.types';

export class DraftService {
  private httpClient: HttpClient;

  constructor(httpClient: HttpClient) {
    this.httpClient = httpClient;
  }

  /**
   * Get all drafts for the current user
   * @param draftType - Optional filter by draft type (e.g., 'Job')
   */
  async getDrafts(draftType?: string): Promise<DraftsListResponse> {
    try {
      const params = draftType ? { draft_type: draftType } : {};
      const response = await this.httpClient.get('/drafts', params);

      return {
        success: response.success,
        data: response.data || [],
        message: response.message || 'Drafts retrieved successfully',
        meta: response.meta
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: [],
        message: error instanceof Error ? error.message : 'Failed to retrieve drafts'
      };
    }
  }

  /**
   * Get a specific draft by ID
   */
  async getDraft(id: number): Promise<DraftResponse> {
    try {
      const response = await this.httpClient.get(`/drafts/${id}`);

      return {
        success: response.success,
        data: response.data,
        message: response.message || 'Draft retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Draft,
        message: error instanceof Error ? error.message : 'Failed to retrieve draft'
      };
    }
  }

  /**
   * Create or update a draft
   */
  async saveDraft(draftData: CreateDraftRequest): Promise<CreateDraftResponse> {
    try {
      const response = await this.httpClient.post('/drafts', draftData);

      return {
        success: true,
        data: response.data || response,
        message: 'Draft saved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Draft,
        message: error instanceof Error ? error.message : 'Failed to save draft'
      };
    }
  }

  /**
   * Update an existing draft
   */
  async updateDraft(id: number, draftData: UpdateDraftRequest): Promise<UpdateDraftResponse> {
    try {
      const response = await this.httpClient.put(`/drafts/${id}`, draftData);

      return {
        success: true,
        data: response.data || response,
        message: 'Draft updated successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Draft,
        message: error instanceof Error ? error.message : 'Failed to update draft'
      };
    }
  }

  /**
   * Delete a draft
   */
  async deleteDraft(id: number): Promise<DeleteDraftResponse> {
    try {
      await this.httpClient.delete(`/drafts/${id}`);

      return {
        success: true,
        message: 'Draft deleted successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Failed to delete draft'
      };
    }
  }

  /**
   * Mark a draft as fulfilled
   */
  async fulfillDraft(id: number, data?: FulfillDraftRequest): Promise<FulfillDraftResponse> {
    try {
      const response = await this.httpClient.patch(`/drafts/${id}/fulfill`, data || {});

      return {
        success: true,
        data: response.data,
        message: 'Draft marked as fulfilled'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Draft,
        message: error instanceof Error ? error.message : 'Failed to fulfill draft'
      };
    }
  }

  /**
   * Recover a draft
   */
  async recoverDraft(id: number): Promise<RecoverDraftResponse> {
    try {
      const response = await this.httpClient.patch(`/drafts/${id}/recover`, {});

      return {
        success: true,
        data: response.data,
        message: 'Draft recovered successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Draft,
        message: error instanceof Error ? error.message : 'Failed to recover draft'
      };
    }
  }

  /**
   * Get drafts for Job creation (form_type: 'job_creation')
   */
  async getJobCreationDrafts(): Promise<DraftsListResponse> {
    try {
      const response = await this.getDrafts('Job');

      // Filter only job_creation drafts
      const jobCreationDrafts = response.data.filter(
        draft => draft.form_type === 'job_creation' && draft.status === 'draft'
      );

      return {
        ...response,
        data: jobCreationDrafts
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: [],
        message: error instanceof Error ? error.message : 'Failed to retrieve job drafts'
      };
    }
  }
}
