/**
 * HTTP Client Utility
 * Base HTTP client with common functionality for all API services
 */

import { API_CONFIG } from '../config';
import { ApiLogger } from './logger';

export interface RequestOptions {
  headers?: Record<string, string>;
  body?: any;
  timeout?: number;
}

export class HttpClient {
  private baseUrl: string;
  private defaultHeaders: Record<string, string>;

  constructor(baseUrl: string = API_CONFIG.BASE_URL) {
    this.baseUrl = baseUrl;
    this.defaultHeaders = {
      'Content-Type': 'application/json',
    };
  }

  /**
   * Set the authorization token for authenticated requests
   */
  setAuthToken(token: string): void {
    if (token) {
      this.defaultHeaders['Authorization'] = `Bearer ${token}`;
    } else {
      delete this.defaultHeaders['Authorization'];
    }
  }

  /**
   * Get the current auth token
   */
  getAuthToken(): string | null {
    const auth = this.defaultHeaders['Authorization'];
    return auth ? auth.replace('Bearer ', '') : null;
  }

  /**
   * Generic request method
   */
  async request<T>(
    method: string,
    endpoint: string,
    options: RequestOptions = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    const { headers = {}, body, timeout = API_CONFIG.TIMEOUT } = options;

    const requestOptions: RequestInit = {
      method,
      headers: {
        ...this.defaultHeaders,
        ...headers,
      },
    };

    if (body && method !== 'GET') {
      requestOptions.body = JSON.stringify(body);
    }

    ApiLogger.logRequest(method, url, body);

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      const response = await fetch(url, {
        ...requestOptions,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      const data = await this.handleResponse<T>(response, method);
      return data;
    } catch (error) {
      if (error.name === 'AbortError') {
        throw new Error('Request timeout');
      }
      ApiLogger.logError(`${method} ${endpoint}`, error);
      throw error;
    }
  }

  /**
   * Handle API response
   */
  private async handleResponse<T>(response: Response, method: string): Promise<T> {
    let data: any;
    
    try {
      const text = await response.text();
      data = text ? JSON.parse(text) : {};
    } catch (error) {
      data = { message: 'Invalid response format' };
    }

    ApiLogger.logResponse(method, response, data);

    if (!response.ok) {
      throw {
        status: response.status,
        statusText: response.statusText,
        data,
        message: data.message || data.error || 'Request failed',
      };
    }

    return data;
  }

  // Convenience methods
  async get<T>(endpoint: string, options?: RequestOptions): Promise<T> {
    return this.request<T>('GET', endpoint, options);
  }

  async post<T>(endpoint: string, body?: any, options?: RequestOptions): Promise<T> {
    return this.request<T>('POST', endpoint, { ...options, body });
  }

  async put<T>(endpoint: string, body?: any, options?: RequestOptions): Promise<T> {
    return this.request<T>('PUT', endpoint, { ...options, body });
  }

  async patch<T>(endpoint: string, body?: any, options?: RequestOptions): Promise<T> {
    return this.request<T>('PATCH', endpoint, { ...options, body });
  }

  async delete<T>(endpoint: string, options?: RequestOptions): Promise<T> {
    return this.request<T>('DELETE', endpoint, options);
  }
}