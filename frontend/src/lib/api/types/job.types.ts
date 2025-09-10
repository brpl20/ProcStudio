/**
 * Job/Task API Types
 * Types for job/task related API operations
 */

export interface JobUser {
  id: number;
  name: string;
  last_name?: string;
  avatar_url?: string | null;
}

export interface JobCommentAuthor {
  id: number;
  name: string; // Full name as returned by backend
  avatar_url?: string | null;
}

export interface JobComment {
  id: number;
  content: string;
  created_at: string;
  author: JobCommentAuthor;
}

export interface Job {
  id: number; // Backend returns number directly, not string
  description?: string | null;
  deadline?: string;
  status: JobStatus;
  priority: JobPriority;
  created_by_id: number;
  customer_id?: number | null;
  responsible_id?: number;
  work_number?: string | null;
  assignee_ids: number[];
  assignees_summary?: JobUser[];
  supervisor_ids: number[];
  collaborator_ids: number[];
  deleted: boolean;
  comments_count?: number;
  latest_comment?: JobComment | null;
}

export type JobStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled' | 'delayed';
export type JobPriority = 'low' | 'medium' | 'high' | 'urgent';

export interface CreateJobRequest {
  title: string;
  description?: string;
  status?: JobStatus;
  priority?: JobPriority;
  assigned_to?: number;
  deadline?: string;
}

export interface UpdateJobRequest {
  title?: string;
  description?: string;
  status?: JobStatus;
  priority?: JobPriority;
  assigned_to?: number;
  deadline?: string;
}

export interface JobsListResponse {
  success: boolean;
  data: Job[];
  message?: string;
}

export interface JobResponse {
  success: boolean;
  data: Job;
  message?: string;
}

export interface CreateJobResponse {
  success: boolean;
  data: Job;
  message?: string;
}

export interface UpdateJobResponse {
  success: boolean;
  data: Job;
  message?: string;
}

export interface DeleteJobResponse {
  success: boolean;
  message?: string;
}

// JSON:API Types for Jobs
export interface JsonApiJobData {
  id: string;
  type: 'job';
  attributes: {
    description?: string | null;
    deadline?: string;
    status: JobStatus;
    priority: JobPriority;
    created_by_id: number;
    customer_id?: number | null;
    responsible_id?: number;
    work_number?: string | null;
    assignee_ids: number[];
    assignees_summary?: JobUser[];
    supervisor_ids: number[];
    collaborator_ids: number[];
    deleted: boolean;
    comments_count?: number;
    latest_comment?: JobComment | null;
  };
}

export interface JsonApiJobResponse {
  success: boolean;
  message: string;
  data: JsonApiJobData[];
  meta?: {
    total_count: number;
  };
}

export interface JsonApiSingleJobResponse {
  success: boolean;
  message: string;
  data: JsonApiJobData;
}
