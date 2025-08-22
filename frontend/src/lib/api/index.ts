/**
 * Main API Module
 * Provides a unified interface to all API services
 *
 * This replaces the old monolithic api.ts file with a modular structure
 * following SOLID principles and DRY practices.
 */

import { HttpClient } from './utils/http-client';
import {
  AuthService,
  UserService,
  TeamService,
  LawAreaService,
  PowerService,
  JobService,
  WorkService,
  CustomerService
} from './services';

// Re-export types for convenience
export * from './types';

// Re-export configuration
export { API_CONFIG, API_ENDPOINTS } from './config.ts';

/**
 * Main API class that aggregates all services
 * Single Responsibility: Each service handles its own domain
 * Open/Closed: Easy to add new services without modifying existing ones
 * Dependency Inversion: Services depend on abstractions (HttpClient)
 */
export class API {
  private httpClient: HttpClient;

  // Service instances
  public auth: AuthService;
  public users: UserService;
  public teams: TeamService;
  public lawAreas: LawAreaService;
  public powers: PowerService;
  public jobs: JobService;
  public works: WorkService;
  public customers: CustomerService;

  constructor() {
    // Initialize HTTP client
    this.httpClient = new HttpClient();

    // Initialize services with shared HTTP client
    this.auth = new AuthService(this.httpClient);
    this.users = new UserService(this.httpClient);
    this.teams = new TeamService(this.httpClient);
    this.lawAreas = new LawAreaService(this.httpClient);
    this.powers = new PowerService(this.httpClient);
    this.jobs = new JobService(this.httpClient);
    this.works = new WorkService(this.httpClient);
    this.customers = new CustomerService(this.httpClient);

    // Initialize auth from stored token
    this.auth.initializeAuth();
  }

  /**
   * Set authorization token for all services
   */
  setAuthToken(token: string): void {
    this.httpClient.setAuthToken(token);
    if (token) {
      localStorage.setItem('authToken', token);
    } else {
      localStorage.removeItem('authToken');
    }
  }

  /**
   * Get current auth token
   */
  getAuthToken(): string | null {
    return this.httpClient.getAuthToken();
  }

  /**
   * Test API connection
   */
  async testConnection(): Promise<any> {
    return this.httpClient.get('/test');
  }

  /**
   * Reset all services (useful for logout)
   */
  reset(): void {
    this.setAuthToken('');
  }
}

// Create and export a singleton instance
const api = new API();
export default api;

// Named export for backward compatibility
export { api };
