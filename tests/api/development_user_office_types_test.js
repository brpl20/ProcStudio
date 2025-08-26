/**
 * Generated API Tests for Development/User/Office Types
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development/User/Office Types', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development/User/Office Types tests...`);

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

        console.log(`✅ Authentication successful for Development/User/Office Types`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development/User/Office Types:`, error.message);
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

  it('Development/User/Office Types - Listar registros', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/office_types`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Office Types - Listar registros`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Office Types - Listar registros:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Office Types - Listar registros:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Office Types - Consultar registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/office_types/1`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Office Types - Consultar registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Office Types - Consultar registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Office Types - Consultar registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Office Types - Criar registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "office_type": {
        "description": "Assistência Social"
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/office_types/`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Office Types - Criar registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Office Types - Criar registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Office Types - Criar registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Office Types - Atualizar registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "office_type": {
        "description": "Assistência"
    }
};

    try {
      const response = await axios({
        method: 'put',
        url: `${baseURL}/office_types/3`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Office Types - Atualizar registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Office Types - Atualizar registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Office Types - Atualizar registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Office Types - Remover registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'delete',
        url: `${baseURL}/office_types/3`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Office Types - Remover registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Office Types - Remover registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Office Types - Remover registro:`, error.message);
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
