/**
 * Test Service
 * Handles test
 * test.service.ts
 */
import { HttpClient } from '../utils/http-client';
import { API_ENDPOINTS } from '../config';
import type { APITestResponse } from '../types';

export class TestService {
  constructor(private http: HttpClient) {}

  /**
   * Test
   */
  async test(): Promise<APITestResponse> {
    return this.http.get(API_ENDPOINTS.TEST);
  }
}
