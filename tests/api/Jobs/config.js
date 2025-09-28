/**
 * Configuration and imports for Job Tests
 */

const axios = require("axios");
const { expect } = require("chai");
const AuthHelper = require("../auth_helper");
const { apiTesting } = require("../../config");
const { faker } = require("@faker-js/faker");

// Configuration object
const config = apiTesting;
const baseURL = config.api.baseUrl;

// Test state management
const testState = {
  authHelper: null,
  randomJobId: null,
  createdJobId: null,
  jobsList: [],
  cleanupIds: [],
  isFullTestRun: false  // Flag to control output verbosity
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

  validateJob: (job) => {
    expect(job).to.have.property("description");
    expect(job).to.have.property("deadline");
    expect(job).to.have.property("status");
    expect(job).to.have.property("priority");
  }
};

// Error handlers
const errorHandlers = {
  handleApiError: (error, operation, url) => {
    if (error.response) {
      if (testState.isFullTestRun) {
        testUtils.logError(error.response.status, operation, error);
      } else {
        console.error(`❌ ${error.response.status} - ${operation}`);
        console.error(`   Route: ${url}`);
        console.error(`   Response:`, error.response.data);
      }
      throw new Error(
        `Request failed with status ${error.response.status}: ${JSON.stringify(error.response.data)}`
      );
    } else {
      if (testState.isFullTestRun) {
        testUtils.logError('Network', operation, error);
      } else {
        console.error(`❌ Network error - ${operation}`);
        console.error(`   Route: ${url}`);
        console.error(`   Error:`, error.message);
      }
      throw error;
    }
  }
};

// Test utilities
const testUtils = {
  logSuccess: (status, operation, url, additionalInfo = {}) => {
    if (testState.isFullTestRun) {
      // Simplified output for full test runs
      console.log(`✅ ${status} - ${operation} - OK`);
    } else {
      // Detailed output for individual tests
      console.log(`✅ ${status} - ${operation}`);
      console.log(`   Route: ${url}`);
      Object.entries(additionalInfo).forEach(([key, value]) => {
        console.log(`   ${key}: ${value}`);
      });
    }
  },

  logError: (status, operation, error) => {
    if (testState.isFullTestRun) {
      // Simplified error output for full test runs
      const testCommand = getTestCommand(operation);
      console.log(`❌ ${status} - ${operation} - ERROR -> Run autonomous test at: ${testCommand}`);
    } else {
      // Keep existing detailed error logging for individual tests
      console.log(`❌ ${status} - ${operation} - ERROR`);
      if (error) {
        console.log(`   Error: ${error.message || error}`);
      }
    }
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

// Helper function to determine test command based on operation
function getTestCommand(operation) {
  const op = operation.toLowerCase();
  if (op.includes('create') || op.includes('post')) {
    return 'npm run test:job:create';
  } else if (op.includes('read') || op.includes('get') || op.includes('index')) {
    return 'npm run test:job:read';
  } else if (op.includes('update') || op.includes('put') || op.includes('patch')) {
    return 'npm run test:job:update';
  } else if (op.includes('delete') && op.includes('soft')) {
    return 'npm run test:job:delete-soft';
  } else if (op.includes('delete') && op.includes('hard')) {
    return 'npm run test:job:delete-hard';
  } else if (op.includes('restore')) {
    return 'npm run test:job:restore';
  } else if (op.includes('cascade')) {
    return 'npm run test:job:cascade';
  } else if (op.includes('authorization')) {
    return 'npm run test:job:authorization';
  } else if (op.includes('isolation')) {
    return 'npm run test:job:isolation';
  }
  return 'npm run test:job';
}

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
  faker
};
