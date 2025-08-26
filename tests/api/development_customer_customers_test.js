/**
 * Generated API Tests for Development/Customer/Customers
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development/Customer/Customers', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development/Customer/Customers tests...`);

    // Setup authentication - WAIT for token
    if (config.api.auth && config.api.auth.testCredentials) {
      try {
        const authUrl = `${baseURL}${config.api.auth.tokenEndpoint}`;
        console.log(`Authenticating at: ${authUrl}`);

        const response = await axios.post(authUrl, config.api.auth.testCredentials, {
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          timeout: 10000
        });

        authToken = response.data.token || response.data.access_token || response.data.auth_token || response.data.data?.token || response.data.jwt;

        if (!authToken) {
          throw new Error('No token received from authentication response');
        }

        console.log(`✅ Authentication successful for Development/Customer/Customers`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development/Customer/Customers:`, error.message);
        if (error.response) {
          console.error('Auth response status:', error.response.status);
          console.error('Auth response data:', error.response.data);
        }
        throw error; // Fail the tests if authentication fails
      }
    } else {
      console.warn('No authentication configuration found');
    }
  });

  it('Development/Customer/Customers - Consultar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders(), {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbl9pZCI6MSwiZXhwIjoxNjkxNzA5NDY5fQ.WV-uHlDdeK2S1tRKR4ddLpKZJnPlsyObmdtKUrJUOMA"
} };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/customer/customers/1`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/Customer/Customers - Consultar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/Customer/Customers - Consultar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/Customer/Customers - Consultar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/Customer/Customers - Atualizar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders(), {
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhZG1pbl9pZCI6MSwiZXhwIjoxNjkxNzA5NDY5fQ.WV-uHlDdeK2S1tRKR4ddLpKZJnPlsyObmdtKUrJUOMA"
} };
    const requestData = {
    "customer": {
        "email": "customer@gmail.com",
        "password": "123123",
        "password_confirmation": "123123"
    }
};

    try {
      const response = await axios({
        method: 'put',
        url: `${baseURL}/customer/customers/11`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/Customer/Customers - Atualizar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/Customer/Customers - Atualizar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/Customer/Customers - Atualizar um registro:`, error.message);
        throw error;
      }
    }
  });

  // Helper functions
  function getAuthHeaders() {
    const headers = {};
    if (authToken) {
      headers['Authorization'] = `Bearer ${authToken}`;
    }
    return headers;
  }

  function validateResponse(response, expectedStatus = 200) {
    expect(response.status).to.equal(expectedStatus);
    expect(response.data).to.exist;
  }

  function validateJsonApiResponse(response) {
    expect(response.data).to.have.property('data');
    if (Array.isArray(response.data.data)) {
      response.data.data.forEach(item => {
        expect(item).to.have.property('id');
        expect(item).to.have.property('type');
        expect(item).to.have.property('attributes');
      });
    }
  }
});
