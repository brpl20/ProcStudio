/**
 * Work API Types
 * Types for work related API operations
 */

export interface Work {
  id: number;
  procedure: WorkProcedure;
  status: WorkStatus;
  law_area_id: number;
  number: number;
  folder: string;
  note?: string;
  extra_pending_document?: string;

  // Financial fields
  compensations_five_years: boolean;
  compensations_service: boolean;
  lawsuit: boolean;
  gain_projection?: string;

  // Team assignments
  physical_lawyer?: number;
  responsible_lawyer?: number;
  partner_lawyer?: number;
  intern?: number;
  bachelor?: number;

  // Timestamps
  created_at: string;
  updated_at: string;
  deleted_at?: string | null;
}

export type WorkProcedure = 'administrative' | 'judicial' | 'extrajudicial';
export type WorkStatus = 'in_progress' | 'paused' | 'completed' | 'archived';

export interface CreateWorkRequest {
  procedure: WorkProcedure;
  law_area_id: number;
  number: number;
  folder: string;
  note?: string;
  status?: WorkStatus;
  extra_pending_document?: string;

  // Financial fields
  compensations_five_years?: boolean;
  compensations_service?: boolean;
  lawsuit?: boolean;
  gain_projection?: string;

  // Team assignments
  physical_lawyer?: number;
  responsible_lawyer?: number;
  partner_lawyer?: number;
  intern?: number;
  bachelor?: number;

  // Relationship IDs
  power_ids?: number[];
  profile_customer_ids?: number[];
  user_profile_ids?: number[];
  office_ids?: number[];
}

export interface UpdateWorkRequest {
  procedure?: WorkProcedure;
  law_area_id?: number;
  number?: number;
  folder?: string;
  note?: string;
  status?: WorkStatus;
  extra_pending_document?: string;

  // Financial fields
  compensations_five_years?: boolean;
  compensations_service?: boolean;
  lawsuit?: boolean;
  gain_projection?: string;

  // Team assignments
  physical_lawyer?: number;
  responsible_lawyer?: number;
  partner_lawyer?: number;
  intern?: number;
  bachelor?: number;

  // Relationship IDs
  power_ids?: number[];
  profile_customer_ids?: number[];
  user_profile_ids?: number[];
  office_ids?: number[];
}

export interface WorksListResponse {
  success: boolean;
  data: Work[];
  meta?: {
    total_count: number;
  };
  message?: string;
}

export interface WorkResponse {
  success: boolean;
  data: Work;
  message?: string;
}

export interface CreateWorkResponse {
  success: boolean;
  data: Work;
  message?: string;
}

export interface UpdateWorkResponse {
  success: boolean;
  data: Work;
  message?: string;
}

export interface DeleteWorkResponse {
  success: boolean;
  message?: string;
}

export interface ConvertDocumentsRequest {
  approved_documents: number[];
}

export interface ConvertDocumentsResponse {
  success: boolean;
  message?: string;
}
