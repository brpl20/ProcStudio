/**
 * Draft API Types
 * Types for draft-related API operations
 */

export interface Draft {
  id: number;
  form_type: string;
  draftable_type: string;
  draftable_id: number | null;
  data: Record<string, any>;
  status: DraftStatus;
  expires_at: string;
  created_at: string;
  updated_at: string;
  user_id?: number;
  team_id?: number;
  customer_id?: number;
  session_id?: string;
}

export type DraftStatus = 'draft' | 'recovered' | 'expired' | 'fullfiled';

export interface CreateDraftRequest {
  form_type: string;
  draftable_type?: string;
  draftable_id?: number | null;
  data: Record<string, any>;
  session_id?: string;
}

export interface UpdateDraftRequest {
  data: Record<string, any>;
}

export interface FulfillDraftRequest {
  record_type?: string;
  record_id?: number;
}

export interface DraftsListResponse {
  success: boolean;
  data: Draft[];
  message?: string;
  meta?: {
    total_count: number;
  };
}

export interface DraftResponse {
  success: boolean;
  data: Draft;
  message?: string;
}

export interface CreateDraftResponse {
  success: boolean;
  data: Draft;
  message?: string;
}

export interface UpdateDraftResponse {
  success: boolean;
  data: Draft;
  message?: string;
}

export interface DeleteDraftResponse {
  success: boolean;
  message?: string;
}

export interface FulfillDraftResponse {
  success: boolean;
  data: Draft;
  message?: string;
}

export interface RecoverDraftResponse {
  success: boolean;
  data: Draft;
  message?: string;
}
