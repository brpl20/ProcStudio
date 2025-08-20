/**
 * API Logger Utility
 * Provides consistent logging for API requests and responses
 */

import { API_CONFIG } from '../config';

export class ApiLogger {
  private static isDebugMode = API_CONFIG.DEBUG_MODE;

  static logRequest(method: string, url: string, body?: any): void {
    if (!this.isDebugMode) {
      return;
    }

    console.log(`📤 ${method} Request:`, url);
    if (body) {
      console.log('Body:', body);
    }
  }

  static logResponse(method: string, response: Response, data: any): void {
    if (!this.isDebugMode) {
      return;
    }

    const emoji = response.ok ? '✅' : '❌';
    console.log(`${emoji} ${method} Response:`, response.status, response.statusText);
    console.log('Data:', data);
  }

  static logError(context: string, error: any): void {
    console.error(`❌ Error in ${context}:`, error);
  }
}
