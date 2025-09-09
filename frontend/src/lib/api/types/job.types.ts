/**
 * Job/Task API Types
 * Types for job/task related API operations
 */

export interface Job {
  id: number;
  description?: string;
  deadline?: string;
  status: JobStatus;
  priority: JobPriority;
  comment?: string;
  created_by_id: number;
  customer_id?: number;
  responsible_id?: number;
  work_number?: string;
  assignee_ids: number[];
  supervisor_ids: number[];
  collaborator_ids: number[];
  deleted: boolean;
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
    description?: string;
    deadline?: string;
    status: JobStatus;
    priority: JobPriority;
    comment?: string;
    created_by_id: number;
    customer_id?: number;
    responsible_id?: number;
    work_number?: string;
    assignee_ids: number[];
    supervisor_ids: number[];
    collaborator_ids: number[];
    deleted: boolean;
  };
}

export interface JsonApiJobResponse {
  success: boolean;
  message: string;
  data: JsonApiJobData[];
}

export interface JsonApiSingleJobResponse {
  success: boolean;
  message: string;
  data: JsonApiJobData;
}
