/**
 * Generated API Tests for Development/User/Law Areas
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development/User/Law Areas', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development/User/Law Areas tests...`);

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

        console.log(`✅ Authentication successful for Development/User/Law Areas`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development/User/Law Areas:`, error.message);
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

  it('Development/User/Law Areas - Listar Registros', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/law_areas`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Law Areas - Listar Registros`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Law Areas - Listar Registros:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Law Areas - Listar Registros:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Law Areas - Consultar um Registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/law_areas/1`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Law Areas - Consultar um Registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Law Areas - Consultar um Registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Law Areas - Consultar um Registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Law Areas - Criar um Registro (Área)', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "law_area": {
        "name": "Civil",
        "code": "civil",
        "description": "Direito Civil em geral",
        "active": true,
        "sort_order": 1
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/law_areas`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Law Areas - Criar um Registro (Área)`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Law Areas - Criar um Registro (Área):`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Law Areas - Criar um Registro (Área):`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Law Areas - Criar um Registro (SubáArea)', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "law_area": {
        "name": "Família",
        "code": "family2",
        "description": "Direito de Família - divórcio, pensão, guarda",
        "parent_area_id": 4,
        "active": true,
        "sort_order": 1
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/law_areas`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Law Areas - Criar um Registro (SubáArea)`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Law Areas - Criar um Registro (SubáArea):`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Law Areas - Criar um Registro (SubáArea):`, error.message);
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
