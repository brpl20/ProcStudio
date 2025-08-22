/**
 * Job/Task Service
 * Handles all job/task related API operations
 */

import type { HttpClient } from '../utils/http-client';
import type {
  Job,
  CreateJobRequest,
  UpdateJobRequest,
  JobsListResponse,
  JobResponse,
  CreateJobResponse,
  UpdateJobResponse,
  DeleteJobResponse
} from '../types/job.types';

export class JobService {
  private httpClient: HttpClient;

  constructor(httpClient: HttpClient) {
    this.httpClient = httpClient;
  }

  /**
   * Get all jobs/tasks
   */
  async getJobs(): Promise<JobsListResponse> {
    try {
      const response = await this.httpClient.get('/jobs');
      return {
        success: true,
        data: response.data || response,
        message: 'Jobs retrieved successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        data: [],
        message: error?.message || 'Failed to retrieve jobs'
      };
    }
  }

  /**
   * Get a specific job by ID
   */
  async getJob(id: number): Promise<JobResponse> {
    try {
      const response = await this.httpClient.get(`/jobs/${id}`);
      return {
        success: true,
        data: response.data || response,
        message: 'Job retrieved successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        data: {} as Job,
        message: error?.message || 'Failed to retrieve job'
      };
    }
  }

  /**
   * Create a new job/task
   */
  async createJob(jobData: CreateJobRequest): Promise<CreateJobResponse> {
    try {
      const response = await this.httpClient.post('/jobs', { job: jobData });
      return {
        success: true,
        data: response.data || response,
        message: 'Job created successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        data: {} as Job,
        message: error?.message || 'Failed to create job'
      };
    }
  }

  /**
   * Update an existing job/task
   */
  async updateJob(id: number, jobData: UpdateJobRequest): Promise<UpdateJobResponse> {
    try {
      const response = await this.httpClient.put(`/jobs/${id}`, { job: jobData });
      return {
        success: true,
        data: response.data || response,
        message: 'Job updated successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        data: {} as Job,
        message: error?.message || 'Failed to update job'
      };
    }
  }

  /**
   * Delete a job/task
   */
  async deleteJob(id: number): Promise<DeleteJobResponse> {
    try {
      await this.httpClient.delete(`/jobs/${id}`);
      return {
        success: true,
        message: 'Job deleted successfully'
      };
    } catch (error: any) {
      return {
        success: false,
        message: error?.message || 'Failed to delete job'
      };
    }
  }
}
