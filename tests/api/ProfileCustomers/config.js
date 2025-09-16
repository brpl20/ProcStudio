/**
 * Configuration and imports for Profile Customer Tests
 */

const axios = require("axios");
const { expect } = require("chai");
const AuthHelper = require("../auth_helper");
const { apiTesting } = require("../../config");
const CPFGenerator = require("../../helpers/cpf_generator");
const { faker } = require("@faker-js/faker");

// Configuration object (following the working customers pattern)
const config = apiTesting;
const baseURL = config.api.baseUrl;

// Test state management
const testState = {
  authHelper: null,
  randomProfileCustomerId: null,
  createdProfileCustomerId: null,
  profileCustomersList: [],
  cleanupIds: []
};

// Common validation functions
const validators = {
  validateResponse: (response, expectedStatus = 200) => {
    expect(response.status).to.equal(expectedStatus);
    expect(response.data).to.exist;
  },

  validateJsonApiResponse: (response) => {
    expect(response.data).to.have.property("data");
    if (Array.isArray(response.data.data)) {
      response.data.data.forEach((item) => {
        expect(item).to.have.property("id");
        expect(item).to.have.property("type");
        expect(item).to.have.property("attributes");
      });
    }
  },

  validateProfileCustomer: (profileCustomer) => {
    expect(profileCustomer).to.have.property("name");
    expect(profileCustomer).to.have.property("customer_type");
    expect(profileCustomer).to.have.property("status");
  }
};

// Error handlers
const errorHandlers = {
  handleApiError: (error, operation, url) => {
    if (error.response) {
      console.error(`❌ ${error.response.status} - ${operation}`);
      console.error(`   Route: ${url}`);
      console.error(`   Response:`, error.response.data);
      throw new Error(
        `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`
      );
    } else {
      console.error(`❌ Network error - ${operation}`);
      console.error(`   Route: ${url}`);
      console.error(`   Error:`, error.message);
      throw error;
    }
  }
};

// Test utilities
const testUtils = {
  logSuccess: (status, operation, url, additionalInfo = {}) => {
    console.log(`✅ ${status} - ${operation}`);
    console.log(`   Route: ${url}`);
    Object.entries(additionalInfo).forEach(([key, value]) => {
      console.log(`   ${key}: ${value}`);
    });
  },

  skipTest: (context, reason) => {
    console.log(`   ⚠️ Skipping test - ${reason}`);
    context.skip();
  },

  addToCleanup: (id) => {
    if (id && !testState.cleanupIds.includes(id)) {
      testState.cleanupIds.push(id);
    }
  }
};

module.exports = {
  config,
  baseURL,
  testState,
  validators,
  errorHandlers,
  testUtils,
  // Re-export commonly used libraries
  axios,
  expect,
  AuthHelper,
  CPFGenerator,
  faker
};