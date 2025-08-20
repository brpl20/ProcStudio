/**
 * Authentication Service
 * Handles user registration, login, and profile completion
 */

import { HttpClient } from '../utils/http-client';
import { API_ENDPOINTS } from '../config';
import type {
  RegisterRequest,
  RegisterResponse,
  LoginRequest,
  LoginResponse,
  ProfileCompletionData,
  ProfileCompletionResponse,
} from '../types';

export class AuthService {
  constructor(private http: HttpClient) {}

  /**
   * Register a new user
   */
  async register(email: string, password: string, oab: string): Promise<RegisterResponse> {
    const request: RegisterRequest = {
      user: {
        email,
        password,
        password_confirmation: password,
        oab,
      },
    };

    return this.http.post<RegisterResponse>(API_ENDPOINTS.REGISTER, request);
  }

  /**
   * Login user
   */
  async login(email: string, password: string): Promise<LoginResponse> {
    const request: LoginRequest = { email, password };
    
    const response = await this.http.post<LoginResponse>(API_ENDPOINTS.LOGIN, request);
    
    // Store token if login successful
    if (response.success && response.data?.token) {
      this.http.setAuthToken(response.data.token);
      localStorage.setItem('authToken', response.data.token);
    }
    
    return response;
  }

  /**
   * Logout user
   */
  async logout(): Promise<void> {
    try {
      await this.http.delete(API_ENDPOINTS.LOGOUT);
    } finally {
      this.http.setAuthToken('');
      localStorage.removeItem('authToken');
    }
  }

  /**
   * Complete user profile after registration
   */
  async completeProfile(profileData: ProfileCompletionData): Promise<ProfileCompletionResponse> {
    return this.http.post<ProfileCompletionResponse>(
      API_ENDPOINTS.PROFILE_COMPLETION,
      { user_profile: profileData }
    );
  }

  /**
   * Check if user is authenticated
   */
  isAuthenticated(): boolean {
    return !!this.getStoredToken();
  }

  /**
   * Get stored auth token
   */
  getStoredToken(): string | null {
    return localStorage.getItem('authToken');
  }

  /**
   * Initialize auth from stored token
   */
  initializeAuth(): void {
    const token = this.getStoredToken();
    if (token) {
      this.http.setAuthToken(token);
    }
  }
}