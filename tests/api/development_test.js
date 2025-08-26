/**
 * Generated API Tests for Development
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

describe('Development', function() {
  this.timeout(30000);

  let authToken = null;
  let config = null;
  let baseURL = null;

  before(async function() {
    // Load test configuration
    config = JSON.parse(fs.readFileSync(path.join(__dirname, '../test_config.json'), 'utf8'));
    baseURL = config.api.baseUrl || 'http://localhost:3000';

    console.log(`🔐 Authenticating for Development tests...`);

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

        console.log(`✅ Authentication successful for Development`);
      } catch (error) {
        console.error(`❌ Authentication failed for Development:`, error.message);
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

  it('Development - Criar um User', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = "{\r\n    \"user\": {\r\n        \"email\": \"a@gmail.com\",\r\n        \"password\": \"123456\",\r\n        \"password_confirmation\": \"123456\",\r\n        \"oab\": \"PR_54159\" // Opcional\r\n    }\r\n}";

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/public/user_registration`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development - Criar um User`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development - Criar um User:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development - Criar um User:`, error.message);
        throw error;
      }
    }
  });

  it('Development - Authenticate User', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "auth": {
        "email": "u1@gmail.com",
        "password": "123456"
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/login`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development - Authenticate User`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development - Authenticate User:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development - Authenticate User:`, error.message);
        throw error;
      }
    }
  });

  it('Development - Authenticate Customer', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "auth": {
        "email": "omer.fritsch@heaney.test",
        "password": "123456"
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/customer/login`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development - Authenticate Customer`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development - Authenticate Customer:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development - Authenticate Customer:`, error.message);
        throw error;
      }
    }
  });

  it('Development - Reset Customer Password', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "user": {
        "email": "omer.fritsch@heaney.test"
    }
};

    try {
      const response = await axios({
        method: 'post',
        url: `${baseURL}/customer/password`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development - Reset Customer Password`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development - Reset Customer Password:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development - Reset Customer Password:`, error.message);
        throw error;
      }
    }
  });

  it('Development - Reset Customer Password Confirmation', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    const requestData = {
    "user": {
        "reset_password_token": "abcd",
        "password": "123123",
        "password_confirmation": "123123"
    }
};

    try {
      const response = await axios({
        method: 'put',
        url: `${baseURL}/customer/password`,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development - Reset Customer Password Confirmation`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development - Reset Customer Password Confirmation:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development - Reset Customer Password Confirmation:`, error.message);
        throw error;
      }
    }
  });

  it('Development - New Request', async function() {
    const headers = { ...config.api.headers, ...getAuthHeaders() };
    

    try {
      const response = await axios({
        method: 'get',
        url: `${baseURL}`,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Development - New Request`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Development - New Request:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Development - New Request:`, error.message);
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
