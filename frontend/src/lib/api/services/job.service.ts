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
  DeleteJobResponse,
  JsonApiJobData,
  JsonApiJobResponse,
  JsonApiSingleJobResponse
} from '../types/job.types';

export class JobService {
  private httpClient: HttpClient;

  constructor(httpClient: HttpClient) {
    this.httpClient = httpClient;
  }

  /**
   * Transform JSON:API job data to our Job type
   */
  private transformJsonApiJob(jsonApiData: JsonApiJobData): Job {
    return {
      id: parseInt(jsonApiData.id),
      description: jsonApiData.attributes.description,
      deadline: jsonApiData.attributes.deadline,
      status: jsonApiData.attributes.status,
      priority: jsonApiData.attributes.priority,
      comment: jsonApiData.attributes.comment,
      created_by_id: jsonApiData.attributes.created_by_id,
      customer_id: jsonApiData.attributes.customer_id,
      responsible_id: jsonApiData.attributes.responsible_id,
      work_number: jsonApiData.attributes.work_number,
      assignee_ids: jsonApiData.attributes.assignee_ids,
      supervisor_ids: jsonApiData.attributes.supervisor_ids,
      collaborator_ids: jsonApiData.attributes.collaborator_ids,
      deleted: jsonApiData.attributes.deleted
    };
  }

  /**
   * Get all jobs/tasks
   */
  async getJobs(): Promise<JobsListResponse> {
    try {
      const response: JsonApiJobResponse = await this.httpClient.get('/jobs');

      // Transform JSON:API data to our Job type
      const jobs = response.data.map((jobData) => this.transformJsonApiJob(jobData));

      return {
        success: response.success,
        data: jobs,
        message: response.message || 'Jobs retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: [],
        message: error instanceof Error ? error.message : 'Failed to retrieve jobs'
      };
    }
  }

  /**
   * Get a specific job by ID
   */
  async getJob(id: number): Promise<JobResponse> {
    try {
      const response: JsonApiSingleJobResponse = await this.httpClient.get(`/jobs/${id}`);

      // Transform JSON:API data to our Job type
      const job = this.transformJsonApiJob(response.data);

      return {
        success: response.success,
        data: job,
        message: response.message || 'Job retrieved successfully'
      };
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Job,
        message: error instanceof Error ? error.message : 'Failed to retrieve job'
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
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Job,
        message: error instanceof Error ? error.message : 'Failed to create job'
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
    } catch (error: unknown) {
      return {
        success: false,
        data: {} as Job,
        message: error instanceof Error ? error.message : 'Failed to update job'
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
    } catch (error: unknown) {
      return {
        success: false,
        message: error instanceof Error ? error.message : 'Failed to delete job'
      };
    }
  }
}
