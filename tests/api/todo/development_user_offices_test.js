/**
 * Generated API Tests for Development/User/Offices
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development/User/Offices', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development/User/Offices tests...`);

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

        console.log(`✅ Authentication successful for Development/User/Offices`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development/User/Offices:`, error.message);
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

  it('Development/User/Offices - Listar registros', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/offices`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Offices - Listar registros`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Offices - Listar registros:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Offices - Listar registros:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Offices - Listar registros With Lawyers', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/offices/with_lawyers`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Offices - Listar registros With Lawyers`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Offices - Listar registros With Lawyers:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Offices - Listar registros With Lawyers:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Offices - Consultar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}/offices/1`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Offices - Consultar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Offices - Consultar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Offices - Consultar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Offices - Criar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "office": {
        "name": "Raia Sul",
        "cnpj": "00420245000178",
        "oab": "000014513/MS",
        "society": "sole_proprietorship",
        "foundation": "2010-10-10",
        "site": "sul-raia.tst.com",
        "cep": "08215-510",
        "street": "Rua Rio imburana",
        "number": 102,
        "neighborhood": "Itaquera",
        "city": "São Paulo",
        "state": "SP",
        "office_type_id": 1,
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
                "phone_number": "11 98181-6767"
            }
        ],
        "emails_attributes": [
            {
                "email": "sul-raia@gmail.com"
            }
        ]
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/offices`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Offices - Criar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Offices - Criar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Offices - Criar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Offices - Atualizar um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "office": {
        "name": "Raia Sul",
        "cnpj": "00420245000178",
        "oab": "000014513/MS",
        "society": "sole_proprietorship",
        "foundation": "2010-10-10",
        "site": "sul-raia.tst.com",
        "cep": "08215-510",
        "street": "Rua Rio imburana",
        "number": 102,
        "neighborhood": "Itaquera",
        "city": "São Paulo",
        "state": "SP",
        "office_type_id": 1,
        "bank_accounts_attributes": [
            {
                "id": 11,
                "bank_name": "Pic Pay",
                "type_account": "Pagamentos",
                "agency": "000-1",
                "account": "909090909512",
                "operation": "0",
                "pix": "1234567890"
            }
        ],
        "phones_attributes": [
            {
                "id": 23,
                "phone_number": "11 98181-6767"
            }
        ],
        "emails_attributes": [
            {
                "id": 23,
                "email": "sul-raia@gmail.com"
            }
        ]
    }
};

    try {
      const response = await axios({
        method: 'put',
        url: `${baseURL}/offices/5`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Offices - Atualizar um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Offices - Atualizar um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Offices - Atualizar um registro:`, error.message);
        throw error;
      }
    }
  });

  it('Development/User/Offices - Remover um registro', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "office": {
        "name": "Raia Sul",
        "cnpj": "00420245000178",
        "oab": "000014513/MS",
        "society": "sole_proprietorship",
        "foundation": "2010-10-10",
        "site": "sul-raia.tst.com",
        "cep": "08215-510",
        "street": "Rua Rio imburana",
        "number": 102,
        "neighborhood": "Itaquera",
        "city": "São Paulo",
        "state": "SP",
        "office_type_id": 1,
        "bank_accounts_attributes": [
            {
                "id": 11,
                "bank_name": "Pic Pay",
                "type_account": "Pagamentos",
                "agency": "000-1",
                "account": "909090909512",
                "operation": "0",
                "pix": "1234567890"
            }
        ],
        "phones_attributes": [
            {
                "id": 23,
                "phone_number": "11 98181-6767"
            }
        ],
        "emails_attributes": [
            {
                "id": 23,
                "email": "sul-raia@gmail.com"
            }
        ]
    }
};

    try {
      const response = await axios({
        method: 'delete',
        url: `${baseURL}/offices/5`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development/User/Offices - Remover um registro`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development/User/Offices - Remover um registro:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development/User/Offices - Remover um registro:`, error.message);
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
