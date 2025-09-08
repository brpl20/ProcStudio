//test.types.ts
export interface APITestResponse {
  success: boolean;
  message: string;
  data: {
    timestamp: string;
    environment: string;
    version: string;
    status: string;
  };
}
