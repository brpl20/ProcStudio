/**
 * Authentication Helper for API Tests
 * Provides reusable authentication methods for test suites
 */

const axios = require('axios');

class AuthHelper {
  constructor(config) {
    this.config = config;
    this.baseURL = config.api.baseUrl || 'http://localhost:3000';
    this.authToken = null;
  }

  static getSecondUserCredentials() {
    return {
      email: "u2@gmail.com",
      password: "123456"
    };
  }

  static createSecondUserAuthHelper(baseConfig) {
    const secondUserConfig = {
      ...baseConfig,
      api: {
        ...baseConfig.api,
        auth: {
          ...baseConfig.api.auth,
          testCredentials: AuthHelper.getSecondUserCredentials()
        }
      }
    };
    return new AuthHelper(secondUserConfig);
  }

  async authenticate() {
    if (!this.config.api.auth || !this.config.api.auth.testCredentials) {
      console.warn('No authentication configuration found');
      return null;
    }

    try {
      const authUrl = `${this.baseURL}${this.config.api.auth.tokenEndpoint}`;
      console.log(`🔐 Authenticating at: ${authUrl}`);

      const response = await axios.post(authUrl, this.config.api.auth.testCredentials, {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        timeout: 10000
      });

      this.authToken = response.data.token || 
                      response.data.access_token || 
                      response.data.auth_token || 
                      response.data.data?.token || 
                      response.data.jwt;

      if (!this.authToken) {
        throw new Error('No token received from authentication response');
      }

      console.log(`✅ Authentication successful!`);
      return this.authToken;
    } catch (error) {
      console.error(`❌ Authentication failed:`, error.message);
      if (error.response) {
        console.error('Auth response status:', error.response.status);
        console.error('Auth response data:', error.response.data);
      }
      throw error;
    }
  }

  getAuthHeaders() {
    const headers = {};
    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`;
    }
    return headers;
  }

  getToken() {
    return this.authToken;
  }

  setToken(token) {
    this.authToken = token;
  }

  async testAuthenticatedRequest(endpoint = '/users') {
    if (!this.authToken) {
      throw new Error('No authentication token available. Call authenticate() first.');
    }

    try {
      const response = await axios.get(`${this.baseURL}${endpoint}`, {
        headers: {
          'Authorization': `Bearer ${this.authToken}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        timeout: 10000
      });

      console.log(`✅ Authenticated request successful! Status: ${response.status}`);
      return response;
    } catch (error) {
      console.error(`❌ Authenticated request failed:`, error.message);
      if (error.response && error.response.status === 401) {
        console.error('🔒 Token might be invalid or expired');
      }
      throw error;
    }
  }
}

module.exports = AuthHelper;