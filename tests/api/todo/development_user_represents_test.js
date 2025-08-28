/**
 * Generated API Tests for Development/User/Represents
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development/User/Represents', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development/User/Represents tests...`);

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

        console.log(`✅ Authentication successful for Development/User/Represents`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development/User/Represents:`, error.message);
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

  it('Development/User/Represents - Listar Registros', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/represents`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Represents - Listar Registros`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Represents - Listar Registros:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Represents - Listar Registros:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Represents - Listar todos representantes de um customer', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/profile_customers/8/represents`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Represents - Listar todos representantes de um customer`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Represents - Listar todos representantes de um customer:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Represents - Listar todos representantes de um customer:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Represents - Listar todos representados de um customer', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/represents/by_representor/9`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Represents - Listar todos representados de um customer`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Represents - Listar todos representados de um customer:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Represents - Listar todos representados de um customer:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Represents - Criar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = "```json\n{\n  \"represent\": {\n    \"profile_customer_id\": 1,  // ID of the unable/relatively incapable person\n    \"representor_id\": 2,        // ID of the representative\n    \"relationship_type\": \"representation\",\n    \"active\": true,\n    \"start_date\": \"2024-01-01\",\n    \"notes\": \"Mãe do menor\"\n  }\n}";

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/represents`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Represents - Criar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Represents - Criar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Represents - Criar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Represents - Atualizar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = "// Cuidar para colocar o ID da representação e não das pessoas\n{\n  \"represent\": {\n    \"profile_customer_id\": 8,  // ID of the unable/relatively incapable person\n    \"representor_id\": 9,        // ID of the representative\n    \"relationship_type\": \"representation\",\n    \"active\": true,\n    \"start_date\": \"2025-08-25\",\n    \"notes\": \"Mãe do menor\"\n  }\n}";

    try {
      const response = await axios({
        method: 'patch',
        url: `${baseURL}/represents/1`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Represents - Atualizar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Represents - Atualizar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Represents - Atualizar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Represents - Deletar um Registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = "// Cuidar para colocar o ID da representação e não das pessoas\n{\n  \"represent\": {\n    \"profile_customer_id\": 8,  // ID of the unable/relatively incapable person\n    \"representor_id\": 9,        // ID of the representative\n    \"relationship_type\": \"representation\",\n    \"active\": true,\n    \"start_date\": \"2025-08-25\",\n    \"notes\": \"Mãe do menor\"\n  }\n}";

    try {
      const response = await axios({
        method: 'delete',
        url: `${baseURL}/represents/1`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Represents - Deletar um Registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Represents - Deletar um Registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Represents - Deletar um Registro:`, error.message);
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
