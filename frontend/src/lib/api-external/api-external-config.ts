// src/lib/api-external/api-external-config.ts
export const apiConfig = {
  cep: {
    baseUrl: import.meta.env.VITE_CEP_API_URL || 'http://168.231.91.47:3003/api/cep',
    timeout: 3000, // 3 seconds for API calls
    retryAttempts: 2,
    debounceMs: 200 // 200ms debounce for user input
  }
};
