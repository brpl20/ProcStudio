/**
 * Generated API Tests for Customer/Profile Customers
 * Auto-generated from Postman collection
 */

const axios = require('axios');
const { expect } = require('chai');
const AuthHelper = require('../auth_helper');
const { apiTesting } = require('../config');

describe('Customer/Profile Customers', function() {
  this.timeout(30000);

  let authHelper = null;
  const config = apiTesting;
  const baseURL = config.api.baseUrl;

  before(async function() {
    console.log(`🔐 Authenticating for Customer/Profile Customers tests...`);
    
    // Initialize auth helper and authenticate
    authHelper = new AuthHelper(config);
    await authHelper.authenticate();
  });

  it('Customer/Profile Customers - Consultar um registro', async function() {
    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/customer/profile_customers/1`;

    try {
      const response = await axios({
        method: 'get',
        url: url,
        headers: headers
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Customer/Profile Customers - Consultar um registro`);
      console.log(`   Route: ${url}`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Customer/Profile Customers - Consultar um registro`);
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Customer/Profile Customers - Consultar um registro`);
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  it('Customer/Profile Customers - Atualizar um registro', async function() {
    const headers = { ...config.api.headers, ...authHelper.getAuthHeaders() };
    const url = `${baseURL}/customer/profile_customers/15`;
    const requestData = {
      "profile_customer": {
          "name": "Thiago",
          "last_name": "Casta"
      }
    };

    try {
      const response = await axios({
        method: 'put',
        url: url,
        headers: headers,
        data: requestData
      });

      // Basic response validation
      validateResponse(response);

      // JSON:API format validation (if applicable)
      if (response.headers['content-type']?.includes('application/vnd.api+json')) {
        validateJsonApiResponse(response);
      }

      console.log(`✅ ${response.status} - Customer/Profile Customers - Atualizar um registro`);
      console.log(`   Route: ${url}`);

    } catch (error) {
      if (error.response) {
        console.error(`❌ ${error.response.status} - Customer/Profile Customers - Atualizar um registro`);
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
        throw new Error(`Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`);
      } else {
        console.error(`❌ Network error - Customer/Profile Customers - Atualizar um registro`);
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
        throw error;
      }
    }
  });

  // Helper functions
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