/**
 * API Test Helper Utilities
 * Common functions and utilities for API testing
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

class ApiTestHelper {
  constructor() {
    this.config = this.loadConfig();
    this.baseURL = process.env.BASE_URL || this.config.api.baseUrl;
    this.authToken = null;
  }

  loadConfig() {
    const configPath = path.join(__dirname, '../test_config.json');
    return JSON.parse(fs.readFileSync(configPath, 'utf8'));
  }

  /**
   * Authenticate and get token
   */
  async authenticate() {
    if (this.authToken) {
      return this.authToken;
    }

    try {
      const response = await axios.post(
        `${this.baseURL}${this.config.api.auth.tokenEndpoint}`,
        this.config.api.auth.testCredentials,
        {
          headers: { 'Content-Type': 'application/json' }
        }
      );

      this.authToken = response.data.token || response.data.access_token || response.data.auth_token;

      if (!this.authToken) {
        throw new Error('No token found in authentication response');
      }

      console.log('✅ Authentication successful');
      return this.authToken;
    } catch (error) {
      console.error('❌ Authentication failed:', error.message);
      throw error;
    }
  }

  /**
   * Get authentication headers
   */
  getAuthHeaders() {
    const headers = { ...this.config.api.headers };

    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`;
    }

    return headers;
  }

  /**
   * Make authenticated API request
   */
  async request(method, endpoint, data = null, customHeaders = {}) {
    const headers = { ...this.getAuthHeaders(), ...customHeaders };

    const config = {
      method,
      url: `${this.baseURL}${endpoint}`,
      headers,
      timeout: this.config.api.timeout
    };

    if (data) {
      config.data = data;
    }

    try {
      const response = await axios(config);
      return response;
    } catch (error) {
      if (error.response) {
        // API responded with error status
        console.error(`API Error (${error.response.status}):`, error.response.data);
      } else if (error.request) {
        // Request was made but no response received
        console.error('Network Error:', error.message);
      } else {
        // Something else happened
        console.error('Request Error:', error.message);
      }
      throw error;
    }
  }

  /**
   * Validate basic response structure
   */
  validateResponse(response, expectedStatus = 200) {
    expect(response).to.exist;
    expect(response.status).to.equal(expectedStatus);
    expect(response.data).to.exist;

    return response;
  }

  /**
   * Validate JSON:API response format
   */
  validateJsonApiResponse(response, options = {}) {
    this.validateResponse(response, options.status || 200);

    const data = response.data;

    // Check for JSON:API structure
    expect(data).to.have.property('data');

    if (Array.isArray(data.data)) {
      // Collection response
      data.data.forEach((item, index) => {
        expect(item, `Item at index ${index}`).to.have.property('id');
        expect(item, `Item at index ${index}`).to.have.property('type');
        expect(item, `Item at index ${index}`).to.have.property('attributes');
      });

      if (options.minCount) {
        expect(data.data.length).to.be.at.least(options.minCount);
      }

      if (options.maxCount) {
        expect(data.data.length).to.be.at.most(options.maxCount);
      }
    } else if (data.data) {
      // Single resource response
      expect(data.data).to.have.property('id');
      expect(data.data).to.have.property('type');
      expect(data.data).to.have.property('attributes');
    }

    // Check for meta information if expected
    if (options.expectMeta) {
      expect(data).to.have.property('meta');
    }

    return response;
  }

  /**
   * Validate error response
   */
  validateErrorResponse(error, expectedStatus = 400) {
    expect(error.response).to.exist;
    expect(error.response.status).to.equal(expectedStatus);

    const data = error.response.data;

    // JSON:API error format
    if (data.errors) {
      expect(data.errors).to.be.an('array');
      data.errors.forEach(errorObj => {
        expect(errorObj).to.have.property('status');
        expect(errorObj).to.have.property('title');
      });
    }

    return error.response;
  }

  /**
   * Generate test data
   */
  generateTestData() {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000);

    return {
      email: `test_${timestamp}_${random}@procstudio.test`,
      name: `Test User ${timestamp}`,
      password: 'TestPassword123!',
      timestamp,
      random
    };
  }

  /**
   * Wait for a specified time
   */
  async wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Retry a request with exponential backoff
   */
  async retryRequest(requestFn, maxRetries = 3, baseDelay = 1000) {
    let lastError;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await requestFn();
      } catch (error) {
        lastError = error;

        if (attempt === maxRetries) {
          throw error;
        }

        const delay = baseDelay * Math.pow(2, attempt - 1);
        console.log(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
        await this.wait(delay);
      }
    }

    throw lastError;
  }

  /**
   * Check if Rails server is healthy
   */
  async checkServerHealth() {
    try {
      const response = await axios.get(`${this.baseURL}/health`, {
        timeout: 5000
      });

      return response.status === 200;
    } catch (error) {
      return false;
    }
  }

  /**
   * Setup test database state
   */
  async setupTestData() {
    // This would typically seed test data or reset database state
    console.log('🔄 Setting up test data...');
    // Implementation depends on your Rails test setup
  }

  /**
   * Cleanup test data
   */
  async cleanupTestData() {
    // This would typically clean up test data
    console.log('🧹 Cleaning up test data...');
    // Implementation depends on your Rails test setup
  }
}

// Create singleton instance
const apiHelper = new ApiTestHelper();

module.exports = {
  ApiTestHelper,
  apiHelper,

  // Export commonly used functions
  authenticate: () => apiHelper.authenticate(),
  request: (method, endpoint, data, headers) => apiHelper.request(method, endpoint, data, headers),
  validateResponse: (response, status) => apiHelper.validateResponse(response, status),
  validateJsonApiResponse: (response, options) => apiHelper.validateJsonApiResponse(response, options),
  validateErrorResponse: (error, status) => apiHelper.validateErrorResponse(error, status),
  generateTestData: () => apiHelper.generateTestData(),
  checkServerHealth: () => apiHelper.checkServerHealth()
};
