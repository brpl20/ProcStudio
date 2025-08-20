/**
 * Power Service
 * Handles power management with hierarchical inheritance
 */

import { HttpClient } from '../utils/http-client';
import { API_ENDPOINTS } from '../config';
import type {
  PowersListResponse,
  PowerResponse,
  CreatePowerRequest,
  UpdatePowerRequest,
  PowerData,
  PowerCategory,
} from '../types';

export class PowerService {
  constructor(private http: HttpClient) {}

  /**
   * Get all powers
   */
  async getPowers(): Promise<PowersListResponse> {
    return this.http.get<PowersListResponse>(API_ENDPOINTS.POWERS);
  }

  /**
   * Get a specific power by ID
   */
  async getPower(powerId: string | number): Promise<PowerResponse> {
    return this.http.get<PowerResponse>(`${API_ENDPOINTS.POWERS}/${powerId}`);
  }

  /**
   * Create a new power
   */
  async createPower(powerData: CreatePowerRequest): Promise<PowerResponse> {
    return this.http.post<PowerResponse>(API_ENDPOINTS.POWERS, powerData);
  }

  /**
   * Update a power
   */
  async updatePower(
    powerId: string | number,
    powerData: UpdatePowerRequest
  ): Promise<PowerResponse> {
    return this.http.put<PowerResponse>(
      `${API_ENDPOINTS.POWERS}/${powerId}`,
      powerData
    );
  }

  /**
   * Delete a power
   */
  async deletePower(powerId: string | number): Promise<void> {
    return this.http.delete<void>(`${API_ENDPOINTS.POWERS}/${powerId}`);
  }

  /**
   * Get base powers only
   */
  async getBasePowers(): Promise<PowerData[]> {
    const response = await this.getPowers();
    return response.data.filter(power => power.attributes.is_base);
  }

  /**
   * Get powers by category
   */
  async getPowersByCategory(category: PowerCategory): Promise<PowerData[]> {
    const response = await this.getPowers();
    return response.data.filter(power => power.attributes.category === category);
  }

  /**
   * Get powers for a specific law area
   */
  async getPowersByLawArea(lawAreaId: number): Promise<PowerData[]> {
    const response = await this.getPowers();
    return response.data.filter(power => power.attributes.law_area_id === lawAreaId);
  }

  /**
   * Get custom powers (team-specific)
   */
  async getCustomPowers(): Promise<PowerData[]> {
    const response = await this.getPowers();
    return response.data.filter(power => power.attributes.is_custom);
  }

  /**
   * Get system powers (not custom)
   */
  async getSystemPowers(): Promise<PowerData[]> {
    const response = await this.getPowers();
    return response.data.filter(power => !power.attributes.is_custom);
  }

  /**
   * Create a base power
   */
  async createBasePower(
    description: string,
    category: PowerCategory
  ): Promise<PowerResponse> {
    const request: CreatePowerRequest = {
      power: {
        description,
        category,
        is_base: true,
      },
    };
    return this.createPower(request);
  }

  /**
   * Create a power for a specific law area
   */
  async createAreaPower(
    description: string,
    category: PowerCategory,
    lawAreaId: number
  ): Promise<PowerResponse> {
    const request: CreatePowerRequest = {
      power: {
        description,
        category,
        law_area_id: lawAreaId,
        is_base: false,
      },
    };
    return this.createPower(request);
  }

  /**
   * Search powers by description
   */
  async searchPowers(searchTerm: string): Promise<PowerData[]> {
    const response = await this.getPowers();
    const lowerSearch = searchTerm.toLowerCase();
    return response.data.filter(power =>
      power.attributes.description.toLowerCase().includes(lowerSearch) ||
      power.attributes.full_description.toLowerCase().includes(lowerSearch)
    );
  }
}