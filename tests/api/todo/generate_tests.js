#!/usr/bin/env node

/**
 * API Test Generator
 *
 * This script generates API tests from the Postman collection.json file
 * and sets up the test environment for direct Rails API testing.
 */

const fs = require('fs');
const path = require('path');
const PostmanParser = require('../shared/postman_parser');

class ApiTestGenerator {
  constructor() {
    this.rootDir = path.resolve(__dirname, '../..');
    this.collectionPath = path.join(this.rootDir, 'collection.json');
    this.outputDir = __dirname;
    this.parser = new PostmanParser(this.collectionPath);
  }

  /**
   * Check if collection file exists
   */
  checkCollectionFile() {
    if (!fs.existsSync(this.collectionPath)) {
      console.error('❌ collection.json not found at:', this.collectionPath);
      console.log('Please ensure the collection.json file exists in the project root.');
      return false;
    }
    return true;
  }

  /**
   * Generate all API tests
   */
  async generateTests() {
    console.log('🔄 Generating API Tests from Postman Collection...');
    console.log('═══════════════════════════════════════════════════');

    if (!this.checkCollectionFile()) {
      process.exit(1);
    }

    // Load and parse collection
    console.log('📖 Loading collection...');
    if (!this.parser.loadCollection()) {
      console.error('❌ Failed to load collection');
      process.exit(1);
    }

    // Display collection summary
    const summary = this.parser.getSummary();
    console.log('📊 Collection Summary:');
    console.log(`   Name: ${summary.name}`);
    console.log(`   Total Requests: ${summary.totalRequests}`);
    console.log(`   Total Folders: ${summary.totalFolders}`);
    console.log(`   Variables: ${summary.variables.join(', ')}`);

    // Generate test suites
    console.log('\n🏗️  Generating test suites...');
    const testSuites = this.parser.generateTestSuites();
    console.log(`Generated ${testSuites.length} test suites:`);
    testSuites.forEach(suite => {
      console.log(`   - ${suite.name} (${suite.requests.length} requests)`);
    });

    // Generate test files
    console.log('\n📝 Generating test files...');
    this.parser.generateTestFiles(this.outputDir);

    // Generate additional helper files
    this.generateHelperFiles();

    console.log('\n✅ API test generation completed!');
    console.log('📁 Generated files in:', this.outputDir);
    console.log('\n🚀 To run the tests:');
    console.log('   cd tests');
    console.log('   npm install');
    console.log('   npm run test:api');
  }

  /**
   * Generate helper files for API testing
   */
  generateHelperFiles() {
    // Generate test helper utilities
    const testHelperContent = this.generateTestHelper();
    const testHelperPath = path.join(this.outputDir, 'test_helper.js');
    fs.writeFileSync(testHelperPath, testHelperContent, 'utf8');
    console.log('Generated helper file: test_helper.js');

    // Generate environment configuration
    const envConfigContent = this.generateEnvConfig();
    const envConfigPath = path.join(this.outputDir, 'environment.js');
    fs.writeFileSync(envConfigPath, envConfigContent, 'utf8');
    console.log('Generated environment file: environment.js');

    // Generate Mocha configuration
    const mochaConfigContent = this.generateMochaConfig();
    const mochaConfigPath = path.join(this.outputDir, '.mocharc.json');
    fs.writeFileSync(mochaConfigPath, mochaConfigContent, 'utf8');
    console.log('Generated Mocha config: .mocharc.json');
  }

  /**
   * Generate test helper utilities
   */
  generateTestHelper() {
    return `/**
 * API Test Helper Utilities
 * Common functions and utilities for API testing
 */

const axios = require('axios');
const { expect } = require('chai');
const fs = require('fs');
const path = require('path');

class ApiTestHelper {
  constructor() {
    this.config = this.loadConfig();
    this.baseURL = process.env.BASE_URL || this.config.api.baseUrl;
    this.authToken = null;
  }

  loadConfig() {
    const configPath = path.join(__dirname, '../test_config.json');
    return JSON.parse(fs.readFileSync(configPath, 'utf8'));
  }

  /**
   * Authenticate and get token
   */
  async authenticate() {
    if (this.authToken) {
      return this.authToken;
    }

    try {
      const response = await axios.post(
        \`\${this.baseURL}\${this.config.api.auth.tokenEndpoint}\`,
        this.config.api.auth.testCredentials,
        {
          headers: { 'Content-Type': 'application/json' }
        }
      );

      this.authToken = response.data.token || response.data.access_token || response.data.auth_token;

      if (!this.authToken) {
        throw new Error('No token found in authentication response');
      }

      console.log('✅ Authentication successful');
      return this.authToken;
    } catch (error) {
      console.error('❌ Authentication failed:', error.message);
      throw error;
    }
  }

  /**
   * Get authentication headers
   */
  getAuthHeaders() {
    const headers = { ...this.config.api.headers };

    if (this.authToken) {
      headers['Authorization'] = \`Bearer \${this.authToken}\`;
    }

    return headers;
  }

  /**
   * Make authenticated API request
   */
  async request(method, endpoint, data = null, customHeaders = {}) {
    const headers = { ...this.getAuthHeaders(), ...customHeaders };

    const config = {
      method,
      url: \`\${this.baseURL}\${endpoint}\`,
      headers,
      timeout: this.config.api.timeout
    };

    if (data) {
      config.data = data;
    }

    try {
      const response = await axios(config);
      return response;
    } catch (error) {
      if (error.response) {
        // API responded with error status
        console.error(\`API Error (\${error.response.status}):\`, error.response.data);
      } else if (error.request) {
        // Request was made but no response received
        console.error('Network Error:', error.message);
      } else {
        // Something else happened
        console.error('Request Error:', error.message);
      }
      throw error;
    }
  }

  /**
   * Validate basic response structure
   */
  validateResponse(response, expectedStatus = 200) {
    expect(response).to.exist;
    expect(response.status).to.equal(expectedStatus);
    expect(response.data).to.exist;

    return response;
  }

  /**
   * Validate JSON:API response format
   */
  validateJsonApiResponse(response, options = {}) {
    this.validateResponse(response, options.status || 200);

    const data = response.data;

    // Check for JSON:API structure
    expect(data).to.have.property('data');

    if (Array.isArray(data.data)) {
      // Collection response
      data.data.forEach((item, index) => {
        expect(item, \`Item at index \${index}\`).to.have.property('id');
        expect(item, \`Item at index \${index}\`).to.have.property('type');
        expect(item, \`Item at index \${index}\`).to.have.property('attributes');
      });

      if (options.minCount) {
        expect(data.data.length).to.be.at.least(options.minCount);
      }

      if (options.maxCount) {
        expect(data.data.length).to.be.at.most(options.maxCount);
      }
    } else if (data.data) {
      // Single resource response
      expect(data.data).to.have.property('id');
      expect(data.data).to.have.property('type');
      expect(data.data).to.have.property('attributes');
    }

    // Check for meta information if expected
    if (options.expectMeta) {
      expect(data).to.have.property('meta');
    }

    return response;
  }

  /**
   * Validate error response
   */
  validateErrorResponse(error, expectedStatus = 400) {
    expect(error.response).to.exist;
    expect(error.response.status).to.equal(expectedStatus);

    const data = error.response.data;

    // JSON:API error format
    if (data.errors) {
      expect(data.errors).to.be.an('array');
      data.errors.forEach(errorObj => {
        expect(errorObj).to.have.property('status');
        expect(errorObj).to.have.property('title');
      });
    }

    return error.response;
  }

  /**
   * Generate test data
   */
  generateTestData() {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000);

    return {
      email: \`test_\${timestamp}_\${random}@procstudio.test\`,
      name: \`Test User \${timestamp}\`,
      password: 'TestPassword123!',
      timestamp,
      random
    };
  }

  /**
   * Wait for a specified time
   */
  async wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Retry a request with exponential backoff
   */
  async retryRequest(requestFn, maxRetries = 3, baseDelay = 1000) {
    let lastError;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await requestFn();
      } catch (error) {
        lastError = error;

        if (attempt === maxRetries) {
          throw error;
        }

        const delay = baseDelay * Math.pow(2, attempt - 1);
        console.log(\`Attempt \${attempt} failed, retrying in \${delay}ms...\`);
        await this.wait(delay);
      }
    }

    throw lastError;
  }

  /**
   * Check if Rails server is healthy
   */
  async checkServerHealth() {
    try {
      const response = await axios.get(\`\${this.baseURL}/health\`, {
        timeout: 5000
      });

      return response.status === 200;
    } catch (error) {
      return false;
    }
  }

  /**
   * Setup test database state
   */
  async setupTestData() {
    // This would typically seed test data or reset database state
    console.log('🔄 Setting up test data...');
    // Implementation depends on your Rails test setup
  }

  /**
   * Cleanup test data
   */
  async cleanupTestData() {
    // This would typically clean up test data
    console.log('🧹 Cleaning up test data...');
    // Implementation depends on your Rails test setup
  }
}

// Create singleton instance
const apiHelper = new ApiTestHelper();

module.exports = {
  ApiTestHelper,
  apiHelper,

  // Export commonly used functions
  authenticate: () => apiHelper.authenticate(),
  request: (method, endpoint, data, headers) => apiHelper.request(method, endpoint, data, headers),
  validateResponse: (response, status) => apiHelper.validateResponse(response, status),
  validateJsonApiResponse: (response, options) => apiHelper.validateJsonApiResponse(response, options),
  validateErrorResponse: (error, status) => apiHelper.validateErrorResponse(error, status),
  generateTestData: () => apiHelper.generateTestData(),
  checkServerHealth: () => apiHelper.checkServerHealth()
};
`;
  }

  /**
   * Generate environment configuration
   */
  generateEnvConfig() {
    return `/**
 * Environment Configuration for API Tests
 */

const path = require('path');
const fs = require('fs');

class EnvironmentConfig {
  constructor() {
    this.loadEnvironment();
  }

  loadEnvironment() {
    // Load from environment variables or use defaults
    this.env = process.env.NODE_ENV || 'test';
    this.baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    this.frontendUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
    this.databaseUrl = process.env.DATABASE_URL || 'postgres://localhost/procstudio_test';

    // Load test config
    const configPath = path.join(__dirname, '../test_config.json');
    this.config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  }

  /**
   * Get environment-specific configuration
   */
  getConfig(environment = null) {
    const env = environment || this.env;

    const baseConfig = {
      environment: env,
      api: {
        baseUrl: this.baseUrl,
        timeout: this.config.api.timeout,
        retries: this.config.api.retries
      },
      frontend: {
        baseUrl: this.frontendUrl,
        timeout: this.config.frontend.timeout
      },
      database: {
        url: this.databaseUrl,
        resetBetweenTests: this.config.database.resetBetweenTests
      }
    };

    // Merge environment-specific overrides
    if (this.config.environments && this.config.environments[env]) {
      const envConfig = this.config.environments[env];

      if (envConfig.railsPort) {
        baseConfig.api.baseUrl = \`http://localhost:\${envConfig.railsPort}\`;
      }

      if (envConfig.frontendPort) {
        baseConfig.frontend.baseUrl = \`http://localhost:\${envConfig.frontendPort}\`;
      }

      if (envConfig.database) {
        baseConfig.database.url = envConfig.database;
      }

      // Merge other environment-specific settings
      Object.assign(baseConfig, envConfig);
    }

    return baseConfig;
  }

  /**
   * Check if we're in CI environment
   */
  isCI() {
    return process.env.CI === 'true' || process.env.GITHUB_ACTIONS === 'true';
  }

  /**
   * Get test credentials for environment
   */
  getTestCredentials() {
    return {
      admin: {
        email: process.env.TEST_ADMIN_EMAIL || this.config.api.auth.testCredentials.email,
        password: process.env.TEST_ADMIN_PASSWORD || this.config.api.auth.testCredentials.password
      },
      user: {
        email: process.env.TEST_USER_EMAIL || 'testuser@procstudio.test',
        password: process.env.TEST_USER_PASSWORD || 'testpass123'
      }
    };
  }

  /**
   * Set up environment variables for tests
   */
  setupTestEnvironment() {
    const config = this.getConfig();

    process.env.BASE_URL = config.api.baseUrl;
    process.env.FRONTEND_URL = config.frontend.baseUrl;
    process.env.DATABASE_URL = config.database.url;
    process.env.RAILS_ENV = 'test';

    console.log('🔧 Test environment configured:');
    console.log(\`   API URL: \${config.api.baseUrl}\`);
    console.log(\`   Frontend URL: \${config.frontend.baseUrl}\`);
    console.log(\`   Environment: \${config.environment}\`);
  }
}

const envConfig = new EnvironmentConfig();

module.exports = {
  EnvironmentConfig,
  envConfig,
  getConfig: (env) => envConfig.getConfig(env),
  setupTestEnvironment: () => envConfig.setupTestEnvironment(),
  isCI: () => envConfig.isCI(),
  getTestCredentials: () => envConfig.getTestCredentials()
};
`;
  }

  /**
   * Generate Mocha configuration
   */
  generateMochaConfig() {
    return JSON.stringify({
      "require": ["./environment.js"],
      "timeout": 30000,
      "recursive": true,
      "reporter": "spec",
      "bail": false,
      "exit": true,
      "slow": 5000,
      "grep": "",
      "extension": ["js"],
      "package": "../package.json",
      "reporter-option": [
        "maxDiffSize=0"
      ]
    }, null, 2);
  }

  /**
   * Display usage information
   */
  displayUsage() {
    console.log(`
🧪 API Test Generator Usage
═══════════════════════════

This script generates API tests from your Postman collection.json file.

Commands:
  node generate_tests.js          Generate all API tests
  node generate_tests.js --help   Show this help message

Prerequisites:
  1. collection.json file must exist in the project root
  2. Rails server should be running on port 3000 (or configured port)
  3. Test database should be set up

After generation:
  cd tests
  npm install
  npm run test:api

Generated files:
  - *_test.js files (one per collection folder)
  - run_all.js (test runner)
  - test_helper.js (utility functions)
  - environment.js (environment configuration)
  - .mocharc.json (Mocha configuration)
`);
  }
}

// CLI handling
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.includes('--help') || args.includes('-h')) {
    const generator = new ApiTestGenerator();
    generator.displayUsage();
    process.exit(0);
  }

  const generator = new ApiTestGenerator();
  generator.generateTests().catch(error => {
    console.error('❌ Test generation failed:', error.message);
    process.exit(1);
  });
}

module.exports = ApiTestGenerator;
