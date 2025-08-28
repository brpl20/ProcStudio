/**
 * Generated API Tests for Development/User/Profile Users
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development/User/Profile Users', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development/User/Profile Users tests...`);

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

        console.log(`✅ Authentication successful for Development/User/Profile Users`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development/User/Profile Users:`, error.message);
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

  it('Development/User/Profile Users - Listar registros', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/user_profiles`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Profile Users - Listar registros`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Profile Users - Listar registros:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Profile Users - Listar registros:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Profile Users - Consultar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/user_profiles/1`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Profile Users - Consultar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Profile Users - Consultar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Profile Users - Consultar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Profile Users - Criar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "user_profile": {
        "role": "lawyer",
        "status": "active",
        "user_id": 1,
        "office_id": null,
        "name": "Lane",
        "last_name": "Doe",
        "gender": "other",
        "oab": "151515 OAB/MS",
        "rg": "50.871.886-7",
        "cpf": "688.481.730-55",
        "nationality": "foreigner",
        "civil_status": "single",
        "birth": "3/30/1980",
        "mother_name": "Lara Doe",
        "addresses_attributes": [
            {
                "description": "Apt 4, prédio localizado próximo a Padaria",
                "zip_code": "9158210-1",
                "street": "Rua Jambaláia",
                "number": 531,
                "neighborhood": "Zona norte",
                "city": "Caiuá",
                "state": "SP"
            }
        ],
        "bank_accounts_attributes": [
            {
                "bank_name": "Pic Pay",
                "type_account": "Pagamentos",
                "agency": "000-1",
                "account": "909090909192",
                "operation": "0",
                "pix": "1234567890"
            }
        ],
        "phones_attributes": [
            {
                "phone_number": "67 96767-6767"
            }
        ],
        "emails_attributes": [
            {
                "email": "newmail@gmail.com"
            }
        ]
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/user_profiles`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Profile Users - Criar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Profile Users - Criar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Profile Users - Criar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Profile Users - Atualizar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "user_profile": {
        "name": "Updated Name",
        "last_name": "Updated Last Name",
        "role": "lawyer",
        "gender": "other",
        "oab": "151515 OAB/MS",
        "rg": "50.871.886-7",
        "cpf": "688.481.730-55",
        "nationality": "foreigner",
        "civil_status": "single",
        "birth": "3/30/1980",
        "mother_name": "Lara Doe",
        "addresses_attributes": [
            {
                "id": 1,
                "description": "Updated apartment description",
                "zip_code": "9158210-1",
                "street": "Rua Jambaláia",
                "number": 531,
                "neighborhood": "Zona norte",
                "city": "Caiuá",
                "state": "SP"
            }
        ],
        "bank_accounts_attributes": [
            {
                "id": 1,
                "bank_name": "Updated Bank",
                "type_account": "Pagamentos",
                "agency": "000-1",
                "account": "909090909192",
                "operation": "0",
                "pix": "1234567890"
            }
        ],
        "phones_attributes": [
            {
                "id": 1,
                "phone_number": "67 96767-6767"
            }
        ],
        "emails_attributes": [
            {
                "id": 1,
                "email": "updated@gmail.com"
            }
        ]
    }
};

    try {
      const response = await axios({
        method: 'put',
        url: `${baseURL}/user_profiles/1`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Profile Users - Atualizar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Profile Users - Atualizar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Profile Users - Atualizar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Profile Users - Remover um registro (soft)', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'delete',
        url: `${baseURL}/user_profiles/3`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Profile Users - Remover um registro (soft)`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Profile Users - Remover um registro (soft):`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Profile Users - Remover um registro (soft):`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Profile Users - Remover um registro (hard)', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'delete',
        url: `${baseURL}/user_profiles/6?destroy_fully=true`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Profile Users - Remover um registro (hard)`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Profile Users - Remover um registro (hard):`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Profile Users - Remover um registro (hard):`, error.message);
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
