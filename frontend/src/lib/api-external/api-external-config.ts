export const apiConfig = {
  cep: {
    baseUrl: import.meta.env.VITE_CEP_API_URL || 'http://168.231.91.47:3003/api/cep',
    apiKey: import.meta.env.VITE_CEP_API_KEY || '',
    timeout: 8000,
    retryAttempts: 2,
    debounceMs: 200
  }
};
