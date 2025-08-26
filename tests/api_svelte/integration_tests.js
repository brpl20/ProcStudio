/**
 * API-Svelte Integration Tests
 *
 * This module tests the integration between the Svelte frontend and Rails API backend.
 * It simulates frontend requests and validates the complete request-response cycle.
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

class SvelteApiIntegration {
  constructor() {
    this.config = this.loadConfig();
    this.apiBaseUrl = process.env.BASE_URL || this.config.api.baseUrl;
    this.frontendBaseUrl = process.env.FRONTEND_URL || this.config.frontend.baseUrl;
    this.authToken = null;
    this.testResults = [];
  }

  loadConfig() {
    const configPath = path.join(__dirname, '../test_config.json');
    return JSON.parse(fs.readFileSync(configPath, 'utf8'));
  }

  /**
   * Setup authentication for API requests
   */
  async setupAuthentication() {
    try {
      const response = await axios.post(
        `${this.apiBaseUrl}${this.config.api.auth.tokenEndpoint}`,
        this.config.api.auth.testCredentials,
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: this.config.api.timeout
        }
      );

      this.authToken = response.data.token || response.data.access_token || response.data.auth_token;

      if (!this.authToken) {
        throw new Error('No authentication token received');
      }

      console.log('✅ Authentication setup successful');
      return true;
    } catch (error) {
      console.error('❌ Authentication setup failed:', error.message);
      throw error;
    }
  }

  /**
   * Check if both API and Frontend servers are running
   */
  async checkServerHealth() {
    console.log('🔍 Checking server health...');

    // Check API server
    try {
      await axios.get(`${this.apiBaseUrl}/health`, { timeout: 5000 });
      console.log('✅ Rails API server is healthy');
    } catch (error) {
      throw new Error(`Rails API server not accessible: ${error.message}`);
    }

    // Check Frontend server
    try {
      await axios.get(this.frontendBaseUrl, { timeout: 5000 });
      console.log('✅ Svelte frontend server is healthy');
    } catch (error) {
      throw new Error(`Svelte frontend server not accessible: ${error.message}`);
    }

    return true;
  }

  /**
   * Simulate frontend API request with proper headers and authentication
   */
  async simulateFrontendRequest(method, endpoint, data = null, customHeaders = {}) {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Origin': this.frontendBaseUrl,
      'Referer': this.frontendBaseUrl,
      'User-Agent': 'Mozilla/5.0 (Svelte Integration Test)',
      ...customHeaders
    };

    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`;
    }

    const config = {
      method: method.toUpperCase(),
      url: `${this.apiBaseUrl}${endpoint}`,
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
        // Server responded with error status
        return error.response;
      }
      throw error;
    }
  }

  /**
   * Test CORS configuration between frontend and API
   */
  async testCorsConfiguration() {
    console.log('🌐 Testing CORS configuration...');

    try {
      const response = await this.simulateFrontendRequest('OPTIONS', '/users');

      // Check CORS headers
      const corsHeaders = {
        'Access-Control-Allow-Origin': response.headers['access-control-allow-origin'],
        'Access-Control-Allow-Methods': response.headers['access-control-allow-methods'],
        'Access-Control-Allow-Headers': response.headers['access-control-allow-headers']
      };

      console.log('CORS Headers:', corsHeaders);

      // Validate CORS configuration
      expect(corsHeaders['Access-Control-Allow-Origin']).to.exist;
      expect(corsHeaders['Access-Control-Allow-Methods']).to.include('GET');
      expect(corsHeaders['Access-Control-Allow-Headers']).to.include('Authorization');

      this.testResults.push({
        test: 'CORS Configuration',
        status: 'PASSED',
        details: corsHeaders
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'CORS Configuration',
        status: 'FAILED',
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Test authentication flow from frontend perspective
   */
  async testAuthenticationFlow() {
    console.log('🔐 Testing authentication flow...');

    try {
      // Test login
      const loginResponse = await this.simulateFrontendRequest(
        'POST',
        this.config.api.auth.tokenEndpoint,
        this.config.api.auth.testCredentials
      );

      expect(loginResponse.status).to.equal(200);
      expect(loginResponse.data).to.have.property('token');

      // Test authenticated request
      const token = loginResponse.data.token;
      const authResponse = await this.simulateFrontendRequest(
        'GET',
        '/users',
        null,
        { 'Authorization': `Bearer ${token}` }
      );

      expect(authResponse.status).to.equal(200);
      expect(authResponse.data).to.have.property('data');

      // Test invalid token
      const invalidAuthResponse = await this.simulateFrontendRequest(
        'GET',
        '/users',
        null,
        { 'Authorization': 'Bearer invalid_token' }
      );

      expect(invalidAuthResponse.status).to.equal(401);

      this.testResults.push({
        test: 'Authentication Flow',
        status: 'PASSED',
        details: {
          login: 'SUCCESS',
          authenticatedRequest: 'SUCCESS',
          invalidToken: 'PROPERLY_REJECTED'
        }
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'Authentication Flow',
        status: 'FAILED',
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Test JSON:API format compatibility
   */
  async testJsonApiFormat() {
    console.log('📋 Testing JSON:API format compatibility...');

    try {
      await this.setupAuthentication();

      // Test list endpoint
      const listResponse = await this.simulateFrontendRequest('GET', '/users');

      expect(listResponse.status).to.equal(200);
      expect(listResponse.data).to.have.property('data');
      expect(listResponse.headers['content-type']).to.include('application/json');

      // Validate JSON:API structure
      if (Array.isArray(listResponse.data.data)) {
        listResponse.data.data.forEach(item => {
          expect(item).to.have.property('id');
          expect(item).to.have.property('type');
          expect(item).to.have.property('attributes');
        });
      }

      this.testResults.push({
        test: 'JSON:API Format',
        status: 'PASSED',
        details: {
          structure: 'VALID',
          contentType: listResponse.headers['content-type']
        }
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'JSON:API Format',
        status: 'FAILED',
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Test error handling from frontend perspective
   */
  async testErrorHandling() {
    console.log('⚠️  Testing error handling...');

    try {
      await this.setupAuthentication();

      // Test 404 error
      const notFoundResponse = await this.simulateFrontendRequest('GET', '/nonexistent');
      expect(notFoundResponse.status).to.equal(404);

      // Test validation error
      const validationResponse = await this.simulateFrontendRequest(
        'POST',
        '/users',
        { email: 'invalid-email' }
      );
      expect([400, 422]).to.include(validationResponse.status);

      // Test unauthorized access
      const unauthorizedResponse = await this.simulateFrontendRequest(
        'GET',
        '/admin/settings',
        null,
        {} // No auth header
      );
      expect(unauthorizedResponse.status).to.equal(401);

      this.testResults.push({
        test: 'Error Handling',
        status: 'PASSED',
        details: {
          notFound: '404',
          validation: validationResponse.status,
          unauthorized: '401'
        }
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'Error Handling',
        status: 'FAILED',
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Test real-time features (if applicable)
   */
  async testRealtimeFeatures() {
    console.log('⚡ Testing real-time features...');

    try {
      // This would test WebSocket connections, Server-Sent Events, etc.
      // For now, we'll check if real-time endpoints exist

      await this.setupAuthentication();

      const realtimeEndpoints = [
        '/cable',  // ActionCable
        '/notifications/stream',
        '/events/stream'
      ];

      const results = {};

      for (const endpoint of realtimeEndpoints) {
        try {
          const response = await this.simulateFrontendRequest('GET', endpoint);
          results[endpoint] = {
            status: response.status,
            available: response.status !== 404
          };
        } catch (error) {
          results[endpoint] = {
            status: 'ERROR',
            available: false,
            error: error.message
          };
        }
      }

      this.testResults.push({
        test: 'Real-time Features',
        status: 'INFO',
        details: results
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'Real-time Features',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Test file upload functionality
   */
  async testFileUpload() {
    console.log('📁 Testing file upload functionality...');

    try {
      await this.setupAuthentication();

      // Create a test file buffer
      const testFileContent = Buffer.from('Test file content for integration testing');
      const formData = new FormData();
      formData.append('file', new Blob([testFileContent], { type: 'text/plain' }), 'test.txt');

      const uploadResponse = await this.simulateFrontendRequest(
        'POST',
        '/uploads',
        formData,
        { 'Content-Type': 'multipart/form-data' }
      );

      // Check if upload endpoint exists and handles requests properly
      const isSupported = uploadResponse.status !== 404;

      this.testResults.push({
        test: 'File Upload',
        status: isSupported ? 'SUPPORTED' : 'NOT_IMPLEMENTED',
        details: {
          endpoint: '/uploads',
          status: uploadResponse.status,
          supported: isSupported
        }
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'File Upload',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Test pagination from frontend perspective
   */
  async testPagination() {
    console.log('📄 Testing pagination...');

    try {
      await this.setupAuthentication();

      // Test default pagination
      const page1Response = await this.simulateFrontendRequest('GET', '/users?page=1&per_page=5');
      expect(page1Response.status).to.equal(200);

      // Check pagination metadata
      if (page1Response.data.meta) {
        expect(page1Response.data.meta).to.have.property('total_count');
      }

      // Test page 2
      const page2Response = await this.simulateFrontendRequest('GET', '/users?page=2&per_page=5');
      expect(page2Response.status).to.equal(200);

      this.testResults.push({
        test: 'Pagination',
        status: 'PASSED',
        details: {
          page1Count: page1Response.data.data?.length || 0,
          page2Count: page2Response.data.data?.length || 0,
          hasMeta: !!page1Response.data.meta
        }
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'Pagination',
        status: 'FAILED',
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Test search and filtering
   */
  async testSearchAndFiltering() {
    console.log('🔍 Testing search and filtering...');

    try {
      await this.setupAuthentication();

      // Test search functionality
      const searchResponse = await this.simulateFrontendRequest(
        'GET',
        '/users?search=test'
      );
      expect(searchResponse.status).to.equal(200);

      // Test filtering
      const filterResponse = await this.simulateFrontendRequest(
        'GET',
        '/users?filter[status]=active'
      );
      expect(filterResponse.status).to.equal(200);

      this.testResults.push({
        test: 'Search and Filtering',
        status: 'PASSED',
        details: {
          searchResults: searchResponse.data.data?.length || 0,
          filterResults: filterResponse.data.data?.length || 0
        }
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'Search and Filtering',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Test performance characteristics
   */
  async testPerformance() {
    console.log('⚡ Testing API performance...');

    try {
      await this.setupAuthentication();

      const startTime = Date.now();
      const response = await this.simulateFrontendRequest('GET', '/users');
      const responseTime = Date.now() - startTime;

      expect(response.status).to.equal(200);
      expect(responseTime).to.be.lessThan(this.config.api.timeout);

      const performanceGrade = responseTime < 1000 ? 'EXCELLENT' :
                             responseTime < 2000 ? 'GOOD' :
                             responseTime < 5000 ? 'ACCEPTABLE' : 'SLOW';

      this.testResults.push({
        test: 'Performance',
        status: 'MEASURED',
        details: {
          responseTime: `${responseTime}ms`,
          grade: performanceGrade,
          threshold: `${this.config.api.timeout}ms`
        }
      });

      return true;
    } catch (error) {
      this.testResults.push({
        test: 'Performance',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Run all integration tests
   */
  async runAllTests() {
    console.log('🚀 Starting API-Svelte Integration Tests');
    console.log('════════════════════════════════════════');

    try {
      // Check server health first
      await this.checkServerHealth();

      // Run all test suites
      const tests = [
        () => this.testCorsConfiguration(),
        () => this.testAuthenticationFlow(),
        () => this.testJsonApiFormat(),
        () => this.testErrorHandling(),
        () => this.testPagination(),
        () => this.testSearchAndFiltering(),
        () => this.testPerformance(),
        () => this.testRealtimeFeatures(),
        () => this.testFileUpload()
      ];

      for (const test of tests) {
        try {
          await test();
        } catch (error) {
          console.error(`Test failed: ${error.message}`);
          // Continue with other tests
        }
      }

      this.displayResults();
      return this.getOverallResult();

    } catch (error) {
      console.error('❌ Integration test suite failed:', error.message);
      return false;
    }
  }

  /**
   * Display test results summary
   */
  displayResults() {
    console.log('\n📊 Integration Test Results');
    console.log('═══════════════════════════');

    let passed = 0;
    let failed = 0;
    let info = 0;

    this.testResults.forEach(result => {
      const icon = result.status === 'PASSED' ? '✅' :
                   result.status === 'FAILED' ? '❌' :
                   result.status === 'INFO' || result.status === 'MEASURED' || result.status === 'SUPPORTED' ? 'ℹ️' :
                   '⚠️';

      console.log(`${icon} ${result.test}: ${result.status}`);

      if (result.details) {
        console.log(`   Details: ${JSON.stringify(result.details, null, 2)}`);
      }

      if (result.error) {
        console.log(`   Error: ${result.error}`);
      }

      if (result.status === 'PASSED') passed++;
      else if (result.status === 'FAILED') failed++;
      else info++;
    });

    console.log(`\nSummary: ${passed} passed, ${failed} failed, ${info} informational`);
  }

  /**
   * Get overall test result
   */
  getOverallResult() {
    const failed = this.testResults.filter(r => r.status === 'FAILED').length;
    const critical = this.testResults.filter(r =>
      r.status === 'FAILED' &&
      ['Authentication Flow', 'JSON:API Format', 'CORS Configuration'].includes(r.test)
    ).length;

    if (critical > 0) {
      console.log('❌ Critical integration tests failed - frontend may not work properly');
      return false;
    } else if (failed > 0) {
      console.log('⚠️  Some integration tests failed - check functionality');
      return true; // Non-critical failures
    } else {
      console.log('✅ All integration tests passed - frontend-backend integration is healthy');
      return true;
    }
  }
}

module.exports = SvelteApiIntegration;

// CLI support
if (require.main === module) {
  const integration = new SvelteApiIntegration();
  integration.runAllTests().then(success => {
    process.exit(success ? 0 : 1);
  }).catch(error => {
    console.error('Integration test suite crashed:', error);
    process.exit(1);
  });
}
