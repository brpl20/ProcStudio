/**
 * CEP API Service with debouncing
 */
import type { CEPValidationResult } from '../types/cep.types';
import { apiConfig } from '../api-external-config';

class CEPService {
  private debounceTimer: number | null = null;
  private cache = new Map<string, CEPValidationResult>();

  /**
   * Validate CEP with debouncing
   */
  validateWithDebounce(
    cep: string,
    callback: (result: CEPValidationResult) => void
  ): void {
    // Clear existing timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    // Set new timer
    this.debounceTimer = setTimeout(async () => {
      const result = await this.validate(cep);
      callback(result);
    }, apiConfig.cep.debounceMs) as unknown as number;
  }

  /**
   * Validate CEP immediately (with caching)
   */
  async validate(cep: string): Promise<CEPValidationResult> {
    const cleanedCEP = cep.replace(/[^\d]/g, '');
    
    // Check cache first
    if (this.cache.has(cleanedCEP)) {
      return this.cache.get(cleanedCEP)!;
    }

    if (cleanedCEP.length !== 8) {
      return {
        isValid: false,
        message: 'CEP deve ter 8 dígitos'
      };
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), apiConfig.cep.timeout);

      const response = await fetch(`${apiConfig.cep.baseUrl}/validate/${cleanedCEP}`, {
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorResult = {
          isValid: false,
          message: `Erro na API: ${response.status}`
        };
        return errorResult;
      }

      const result: CEPValidationResult = await response.json();
      
      // Cache successful results
      if (result.isValid) {
        this.cache.set(cleanedCEP, result);
      }

      return result;

    } catch (error) {
      if (error instanceof Error && error.name === 'AbortError') {
        return {
          isValid: false,
          message: 'Tempo limite excedido'
        };
      }

      console.error('CEP API error:', error);
      return {
        isValid: false,
        message: 'Erro de conexão'
      };
    }
  }

  /**
   * Clear debounce timer
   */
  clearDebounce(): void {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
      this.debounceTimer = null;
    }
  }

  /**
   * Clear cache
   */
  clearCache(): void {
    this.cache.clear();
  }
}

// Export singleton instance
export const cepService = new CEPService();