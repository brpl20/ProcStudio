/**
 * Generated API Tests for Development/User/Works
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development/User/Works', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development/User/Works tests...`);

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

        console.log(`✅ Authentication successful for Development/User/Works`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development/User/Works:`, error.message);
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

  it('Development/User/Works - Listar registros', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/works`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Works - Listar registros`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Works - Listar registros:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Works - Listar registros:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Works - Consultar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/works/1`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Works - Consultar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Works - Consultar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Works - Consultar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Works - Criar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "work": {
        "procedure": "administrative",
        "law_area_id": 1,
        "number": 12345,
        "folder": "FOLDER-2024-001",
        "note": "Important case notes",
        "status": "in_progress",
        "initial_atendee": 1,
        "physical_lawyer": 1,
        "responsible_lawyer": 1,
        "partner_lawyer": 1,
        "intern": 1,
        "bachelor": 1,
        "rate_parceled_exfield": "10x R$ 500",
        "other_description": "Additional case details",
        "compensations_five_years": false,
        "compensations_service": false,
        "lawsuit": true,
        "gain_projection": "R$ 50.000",
        "procedures": [
            "consultation",
            "documentation"
        ],
        "extra_pending_document": "Birth certificate",
        "profile_customer_ids": [
            1,
            2
        ],
        "user_profile_ids": [
            1,
            2
        ],
        "office_ids": [
            1
        ],
        "power_ids": [
            1,
            2
        ],
        "documents_attributes": [
            {
                "document_type": "procuration",
                "profile_customer_id": 1
            }
        ],
        "pending_documents_attributes": [
            {
                "description": "CPF Copy",
                "profile_customer_id": 1
            }
        ],
        "recommendations_attributes": [
            {
                "percentage": 10.5,
                "commission": 500,
                "profile_customer_id": 1
            }
        ],
        "honorary_attributes": {
            "fixed_honorary_value": 5000,
            "parcelling_value": 500,
            "honorary_type": "fixed",
            "percent_honorary_value": 30,
            "parcelling": 10,
            "work_prev": "Previous work reference"
        }
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/works`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Works - Criar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Works - Criar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Works - Criar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Works - Atualizar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "work": {
        "procedure": "administrative",
        "subject": "administrative_subject",
        "office_ids": [
            5
        ],
        "number": 15478,
        "folder": "/foo",
        "initial_atendee": "xica@gmail.com"
    }
};

    try {
      const response = await axios({
        method: 'put',
        url: `${baseURL}/works/2`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Works - Atualizar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Works - Atualizar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Works - Atualizar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Works - Remover um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'delete',
        url: `${baseURL}/works/2`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Works - Remover um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Works - Remover um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Works - Remover um registro:`, error.message);
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
