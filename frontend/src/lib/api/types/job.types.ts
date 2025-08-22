/**
 * Job/Task API Types
 * Types for job/task related API operations
 */

export interface Job {
  id: number;
  title: string;
  description?: string;
  status: JobStatus;
  priority: JobPriority;
  assigned_to?: number;
  created_by: number;
  deadline?: string;
  created_at: string;
  updated_at: string;
}

export type JobStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled';
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
