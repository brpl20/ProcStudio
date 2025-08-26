/**
 * Generated API Tests for Development/User/Jobs
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development/User/Jobs', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development/User/Jobs tests...`);

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

        console.log(`✅ Authentication successful for Development/User/Jobs`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development/User/Jobs:`, error.message);
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

  it('Development/User/Jobs - Listar Registros', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/jobs`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Jobs - Listar Registros`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Jobs - Listar Registros:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Jobs - Listar Registros:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Jobs - Consultar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/jobs/25`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Jobs - Consultar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Jobs - Consultar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Jobs - Consultar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Jobs - Criar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "job": {
        "description1": "Revisar contrato de prestação de serviços2",
        "deadline": "2025-01-30",
        "status": "pending",
        "priority": "high",
        "comment": "Cliente solicitou urgência na revisão",
        "assignee_ids": [],
        "supervisor_ids": [
            2
        ],
        "collaborator_ids": [
            3
        ],
        "profile_customer_id": [],
        "work_id": null
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/jobs`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Jobs - Criar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Jobs - Criar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Jobs - Criar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Jobs - Atualizar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "job": {
        "status": "finished"
    }
};

    try {
      const response = await axios({
        method: 'put',
        url: `${baseURL}/jobs/1`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Jobs - Atualizar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Jobs - Atualizar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Jobs - Atualizar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Jobs - Remover um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'delete',
        url: `${baseURL}/jobs/4`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Jobs - Remover um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Jobs - Remover um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Jobs - Remover um registro:`, error.message);
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
