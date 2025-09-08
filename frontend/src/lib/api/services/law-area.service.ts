/**
 * Law Area Service
 * Handles law area management with hierarchical structure
 */

import { HttpClient } from '../utils/http-client';
import { API_ENDPOINTS } from '../config';
import type {
  LawAreasListResponse,
  LawAreaResponse,
  CreateLawAreaRequest,
  UpdateLawAreaRequest,
  LawAreaData
} from '../types';

export class LawAreaService {
  constructor(private http: HttpClient) {}

  /**
   * Get all law areas
   */
  async getLawAreas(): Promise<LawAreasListResponse> {
    return this.http.get<LawAreasListResponse>(API_ENDPOINTS.LAW_AREAS);
  }

  /**
   * Get a specific law area by ID
   */
  async getLawArea(lawAreaId: string | number): Promise<LawAreaResponse> {
    return this.http.get<LawAreaResponse>(`${API_ENDPOINTS.LAW_AREAS}/${lawAreaId}`);
  }

  /**
   * Create a new law area
   */
  async createLawArea(lawAreaData: CreateLawAreaRequest): Promise<LawAreaResponse> {
    return this.http.post<LawAreaResponse>(API_ENDPOINTS.LAW_AREAS, lawAreaData);
  }

  /**
   * Update a law area
   */
  async updateLawArea(
    lawAreaId: string | number,
    lawAreaData: UpdateLawAreaRequest
  ): Promise<LawAreaResponse> {
    return this.http.put<LawAreaResponse>(`${API_ENDPOINTS.LAW_AREAS}/${lawAreaId}`, lawAreaData);
  }

  /**
   * Delete a law area
   */
  async deleteLawArea(lawAreaId: string | number): Promise<void> {
    return this.http.delete<void>(`${API_ENDPOINTS.LAW_AREAS}/${lawAreaId}`);
  }

  /**
   * Get only main areas (no parent)
   */
  async getMainAreas(): Promise<LawAreaData[]> {
    const response = await this.getLawAreas();
    return response.data.filter((area) => area.attributes.is_main_area);
  }

  /**
   * Get sub areas of a specific parent area
   */
  async getSubAreas(parentAreaId: string | number): Promise<LawAreaData[]> {
    const response = await this.getLawArea(parentAreaId);
    if (response.included) {
      return response.included.filter(
        (item: LawAreaData) => item.type === 'law_area' && item.attributes.is_sub_area
      ) as LawAreaData[];
    }
    return [];
  }

  /**
   * Get only system areas (not custom)
   */
  async getSystemAreas(): Promise<LawAreaData[]> {
    const response = await this.getLawAreas();
    return response.data.filter((area) => area.attributes.is_system_area);
  }

  /**
   * Get only custom areas (team-specific)
   */
  async getCustomAreas(): Promise<LawAreaData[]> {
    const response = await this.getLawAreas();
    return response.data.filter((area) => area.attributes.is_custom_area);
  }

  /**
   * Create a sub area under a parent
   */
  async createSubArea(
    parentAreaId: number,
    subAreaData: Omit<CreateLawAreaRequest['law_area'], 'parent_area_id'>
  ): Promise<LawAreaResponse> {
    const request: CreateLawAreaRequest = {
      law_area: {
        ...subAreaData,
        parent_area_id: parentAreaId
      }
    };
    return this.createLawArea(request);
  }
}
