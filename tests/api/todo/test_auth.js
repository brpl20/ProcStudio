#!/usr/bin/env node

/**
 * Authentication Test Script
 *
 * This script tests the authentication flow for API tests to ensure
 * JWT tokens are properly obtained and cached before running the full test suite.
 */

const axios = require('axios');
const fs = require('fs');
const path = require('path');

class AuthenticationTest {
  constructor() {
    this.config = this.loadConfig();
    this.baseURL = this.config.api.baseUrl || 'http://localhost:3000';
  }

  loadConfig() {
    const configPath = path.join(__dirname, '../test_config.json');
    return JSON.parse(fs.readFileSync(configPath, 'utf8'));
  }

  async testAuthentication() {
    console.log('🔐 Testing API Authentication...');
    console.log('═══════════════════════════════════');
    console.log(`Base URL: ${this.baseURL}`);
    console.log(`Auth Endpoint: ${this.config.api.auth.tokenEndpoint}`);
    console.log(`Test User: ${this.config.api.auth.testCredentials.email}`);

    try {
      // Test authentication
      const authUrl = `${this.baseURL}${this.config.api.auth.tokenEndpoint}`;
      console.log(`\n📡 Authenticating at: ${authUrl}`);

      const response = await axios.post(authUrl, this.config.api.auth.testCredentials, {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        timeout: 10000
      });

      const token = response.data.token || response.data.access_token || response.data.auth_token;

      if (!token) {
        throw new Error('No token received from authentication response');
      }

      console.log('✅ Authentication successful!');
      console.log(`Token received: ${token.substring(0, 20)}...`);
      console.log(`Response status: ${response.status}`);

      // Test token validation with an authenticated request
      await this.testAuthenticatedRequest(token);

      return true;
    } catch (error) {
      console.error('❌ Authentication failed:', error.message);

      if (error.response) {
        console.error(`Status: ${error.response.status}`);
        console.error(`Response:`, error.response.data);
      }

      if (error.code === 'ECONNREFUSED') {
        console.error('\n💡 Make sure your Rails server is running:');
        console.error('   bundle exec rails server');
      }

      return false;
    }
  }

  async testAuthenticatedRequest(token) {
    console.log('\n🌐 Testing authenticated request...');

    try {
      const response = await axios.get(`${this.baseURL}/users`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        timeout: 10000
      });

      console.log(`✅ Authenticated request successful! Status: ${response.status}`);

      if (response.data && response.data.data) {
        console.log(`📊 Received ${Array.isArray(response.data.data) ? response.data.data.length : 1} record(s)`);
      }

      return true;
    } catch (error) {
      console.error('❌ Authenticated request failed:', error.message);

      if (error.response) {
        console.error(`Status: ${error.response.status}`);
        if (error.response.status === 401) {
          console.error('🔒 Token might be invalid or expired');
        }
      }

      return false;
    }
  }

  async checkServerHealth() {
    console.log('🏥 Checking server health...');

    try {
      const response = await axios.get(`${this.baseURL}/health`, {
        timeout: 5000
      });

      console.log(`✅ Server is healthy! Status: ${response.status}`);
      return true;
    } catch (error) {
      // Try basic connection
      try {
        const response = await axios.get(this.baseURL, {
          timeout: 5000
        });
        console.log(`✅ Server is running! Status: ${response.status}`);
        return true;
      } catch (basicError) {
        console.error('❌ Server not responding');
        console.error('💡 Please start your Rails server:');
        console.error('   bundle exec rails server');
        return false;
      }
    }
  }

  displayConfigInfo() {
    console.log('\n⚙️  Configuration Information:');
    console.log('═══════════════════════════════');
    console.log(`API Base URL: ${this.config.api.baseUrl}`);
    console.log(`Auth Endpoint: ${this.config.api.auth.tokenEndpoint}`);
    console.log(`Test Email: ${this.config.api.auth.testCredentials.email}`);
    console.log(`Timeout: ${this.config.api.timeout}ms`);
    console.log(`Auth Type: ${this.config.api.auth.type}`);
  }

  async runFullTest() {
    console.log('🧪 API Authentication Test Suite');
    console.log('═══════════════════════════════════');

    this.displayConfigInfo();

    // Check server health first
    const serverHealthy = await this.checkServerHealth();
    if (!serverHealthy) {
      console.log('\n❌ Server health check failed - stopping tests');
      process.exit(1);
    }

    // Test authentication
    const authSuccess = await this.testAuthentication();

    console.log('\n📊 Test Results:');
    console.log('═══════════════');

    if (authSuccess) {
      console.log('✅ Authentication: PASSED');
      console.log('🎉 All authentication tests passed!');
      console.log('🚀 You can now run: npm run test:api');
      process.exit(0);
    } else {
      console.log('❌ Authentication: FAILED');
      console.log('🔧 Please check your configuration and server setup');
      process.exit(1);
    }
  }
}

// CLI execution
if (require.main === module) {
  const authTest = new AuthenticationTest();
  authTest.runFullTest().catch(error => {
    console.error('💥 Test suite crashed:', error.message);
    process.exit(1);
  });
}

module.exports = AuthenticationTest;
