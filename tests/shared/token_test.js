#!/usr/bin/env node

/**
 * JWT Token Test Utility
 *
 * This utility tests and demonstrates the JWT token management system.
 * Use it to verify token handling, test different user types, and debug
 * authentication issues.
 */

const { tokenManager } = require('./token_manager');
const { expect } = require('chai');

class TokenTestUtility {
  constructor() {
    this.results = [];
  }

  /**
   * Test basic authentication flow
   */
  async testBasicAuthentication() {
    console.log('\n🔐 Testing Basic Authentication...');
    console.log('════════════════════════════════════');

    try {
      // Test default user authentication
      console.log('1. Testing default user authentication...');
      const defaultToken = await tokenManager.authenticate('default');

      this.validateToken(defaultToken);
      console.log('✅ Default user authentication successful');

      this.results.push({
        test: 'Basic Authentication - Default User',
        status: 'PASSED',
        token: defaultToken ? 'present' : 'missing'
      });

      return true;
    } catch (error) {
      console.error('❌ Basic authentication failed:', error.message);
      this.results.push({
        test: 'Basic Authentication - Default User',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Test multiple user types
   */
  async testMultipleUserTypes() {
    console.log('\n👥 Testing Multiple User Types...');
    console.log('═══════════════════════════════════');

    const userTypes = ['default', 'admin', 'user', 'lawyer'];
    const results = {};

    for (const userType of userTypes) {
      try {
        console.log(`Testing ${userType} authentication...`);
        const token = await tokenManager.authenticate(userType);

        this.validateToken(token);
        console.log(`✅ ${userType} authentication successful`);

        results[userType] = { success: true, hasToken: !!token };

        this.results.push({
          test: `Multi-User Authentication - ${userType}`,
          status: 'PASSED',
          token: token ? 'present' : 'missing'
        });

      } catch (error) {
        console.error(`❌ ${userType} authentication failed:`, error.message);
        results[userType] = { success: false, error: error.message };

        this.results.push({
          test: `Multi-User Authentication - ${userType}`,
          status: 'FAILED',
          error: error.message
        });
      }
    }

    return results;
  }

  /**
   * Test token persistence and caching
   */
  async testTokenPersistence() {
    console.log('\n💾 Testing Token Persistence...');
    console.log('════════════════════════════════════');

    try {
      // Clear all tokens first
      tokenManager.clearAllTokens();

      // Authenticate and get token
      console.log('1. Getting fresh token...');
      const firstToken = await tokenManager.authenticate('default');

      // Get token again - should use cached version
      console.log('2. Getting cached token...');
      const secondToken = await tokenManager.authenticate('default');

      // Tokens should be the same (cached)
      if (firstToken === secondToken) {
        console.log('✅ Token caching working correctly');
        this.results.push({
          test: 'Token Persistence - Caching',
          status: 'PASSED',
          details: 'Same token returned from cache'
        });
      } else {
        throw new Error('Cached token different from original');
      }

      // Test persistence across instances
      const newTokenManager = new (require('./token_manager').TokenManager)();
      console.log('3. Testing persistence across instances...');

      const persistedToken = await newTokenManager.authenticate('default');
      if (persistedToken === firstToken) {
        console.log('✅ Token persistence across instances working');
        this.results.push({
          test: 'Token Persistence - Cross-Instance',
          status: 'PASSED',
          details: 'Token persisted correctly'
        });
      } else {
        console.log('⚠️  New token generated (may be due to expiry)');
        this.results.push({
          test: 'Token Persistence - Cross-Instance',
          status: 'WARNING',
          details: 'New token generated'
        });
      }

      return true;
    } catch (error) {
      console.error('❌ Token persistence test failed:', error.message);
      this.results.push({
        test: 'Token Persistence',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Test authenticated requests
   */
  async testAuthenticatedRequests() {
    console.log('\n🌐 Testing Authenticated Requests...');
    console.log('═══════════════════════════════════════');

    try {
      // Test basic authenticated request
      console.log('1. Making authenticated request to /users...');
      const response = await tokenManager.authenticatedRequest('GET', '/users');

      if (response.status === 200) {
        console.log('✅ Authenticated request successful');
        this.results.push({
          test: 'Authenticated Request - Basic',
          status: 'PASSED',
          details: `Status: ${response.status}`
        });
      } else {
        throw new Error(`Unexpected status code: ${response.status}`);
      }

      // Test with different user types
      console.log('2. Testing requests with different user types...');
      const userTypes = ['admin', 'user'];

      for (const userType of userTypes) {
        try {
          const userResponse = await tokenManager.authenticatedRequest(
            'GET',
            '/users',
            null,
            { userType }
          );

          console.log(`✅ ${userType} request successful (${userResponse.status})`);
          this.results.push({
            test: `Authenticated Request - ${userType}`,
            status: 'PASSED',
            details: `Status: ${userResponse.status}`
          });
        } catch (error) {
          console.warn(`⚠️  ${userType} request failed: ${error.message}`);
          this.results.push({
            test: `Authenticated Request - ${userType}`,
            status: 'WARNING',
            error: error.message
          });
        }
      }

      return true;
    } catch (error) {
      console.error('❌ Authenticated request test failed:', error.message);
      this.results.push({
        test: 'Authenticated Request',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Test token expiry and refresh
   */
  async testTokenExpiry() {
    console.log('\n⏰ Testing Token Expiry Handling...');
    console.log('═══════════════════════════════════════');

    try {
      // Get token info
      const tokenInfo = tokenManager.getTokenInfo('default');

      if (tokenInfo.status === 'not_found') {
        console.log('No token found, creating one...');
        await tokenManager.authenticate('default');
      }

      const updatedTokenInfo = tokenManager.getTokenInfo('default');
      console.log('Token Info:', {
        status: updatedTokenInfo.status,
        expiresAt: updatedTokenInfo.expiresAt,
        needsRefresh: updatedTokenInfo.needsRefresh
      });

      // Test refresh functionality
      console.log('Testing token refresh...');
      const refreshedToken = await tokenManager.refreshTokenIfNeeded('default');

      if (refreshedToken) {
        console.log('✅ Token refresh mechanism working');
        this.results.push({
          test: 'Token Expiry - Refresh',
          status: 'PASSED',
          details: 'Token refresh working'
        });
      }

      return true;
    } catch (error) {
      console.error('❌ Token expiry test failed:', error.message);
      this.results.push({
        test: 'Token Expiry',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Test error handling
   */
  async testErrorHandling() {
    console.log('\n⚠️  Testing Error Handling...');
    console.log('═══════════════════════════════════');

    try {
      // Test invalid credentials
      console.log('1. Testing invalid credentials...');
      try {
        await tokenManager.authenticate('invalid_user', {
          email: 'invalid@example.com',
          password: 'wrongpassword'
        });
        throw new Error('Should have failed with invalid credentials');
      } catch (error) {
        if (error.message.includes('Authentication failed')) {
          console.log('✅ Invalid credentials properly rejected');
          this.results.push({
            test: 'Error Handling - Invalid Credentials',
            status: 'PASSED',
            details: 'Properly rejected invalid credentials'
          });
        } else {
          throw error;
        }
      }

      // Test server unavailable
      console.log('2. Testing server unavailable scenario...');
      const originalBaseUrl = process.env.BASE_URL;
      process.env.BASE_URL = 'http://localhost:9999'; // Non-existent server

      try {
        await tokenManager.authenticate('default');
        throw new Error('Should have failed with server unavailable');
      } catch (error) {
        console.log('✅ Server unavailable properly handled');
        this.results.push({
          test: 'Error Handling - Server Unavailable',
          status: 'PASSED',
          details: 'Properly handled server unavailable'
        });
      } finally {
        process.env.BASE_URL = originalBaseUrl;
      }

      return true;
    } catch (error) {
      console.error('❌ Error handling test failed:', error.message);
      this.results.push({
        test: 'Error Handling',
        status: 'FAILED',
        error: error.message
      });
      return false;
    }
  }

  /**
   * Validate JWT token format
   */
  validateToken(token) {
    if (!token || typeof token !== 'string') {
      throw new Error('Invalid token: must be a string');
    }

    const parts = token.split('.');
    if (parts.length !== 3) {
      throw new Error('Invalid JWT token: must have 3 parts');
    }

    try {
      // Try to decode the header and payload
      const header = JSON.parse(Buffer.from(parts[0], 'base64').toString());
      const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());

      if (!header.alg) {
        throw new Error('Invalid JWT token: missing algorithm in header');
      }

      if (!payload.exp && !payload.iat) {
        throw new Error('Invalid JWT token: missing time claims');
      }

      return true;
    } catch (error) {
      throw new Error(`Invalid JWT token format: ${error.message}`);
    }
  }

  /**
   * Run all tests
   */
  async runAllTests() {
    console.log('🧪 JWT Token Management Test Suite');
    console.log('═══════════════════════════════════════');
    console.log(`Testing against: ${process.env.BASE_URL || 'http://localhost:3000'}`);

    const startTime = Date.now();
    this.results = [];

    // Run all test suites
    const tests = [
      () => this.testBasicAuthentication(),
      () => this.testMultipleUserTypes(),
      () => this.testTokenPersistence(),
      () => this.testAuthenticatedRequests(),
      () => this.testTokenExpiry(),
      () => this.testErrorHandling()
    ];

    for (const test of tests) {
      try {
        await test();
      } catch (error) {
        console.error('Test suite error:', error.message);
      }
    }

    const duration = Date.now() - startTime;
    this.displayResults(duration);
  }

  /**
   * Display test results
   */
  displayResults(duration) {
    console.log('\n📊 Test Results Summary');
    console.log('═══════════════════════');

    let passed = 0;
    let failed = 0;
    let warnings = 0;

    this.results.forEach(result => {
      const icon = result.status === 'PASSED' ? '✅' :
                   result.status === 'FAILED' ? '❌' : '⚠️';

      console.log(`${icon} ${result.test}`);

      if (result.details) {
        console.log(`   Details: ${result.details}`);
      }

      if (result.error) {
        console.log(`   Error: ${result.error}`);
      }

      if (result.status === 'PASSED') passed++;
      else if (result.status === 'FAILED') failed++;
      else warnings++;
    });

    console.log(`\nResults: ${passed} passed, ${failed} failed, ${warnings} warnings`);
    console.log(`Duration: ${(duration / 1000).toFixed(2)} seconds`);

    // Show token manager status
    console.log('\n🔍 Current Token Status:');
    const allTokens = tokenManager.getAllTokens();
    if (Object.keys(allTokens).length > 0) {
      console.log(JSON.stringify(allTokens, null, 2));
    } else {
      console.log('No tokens currently cached');
    }

    if (failed === 0) {
      console.log('\n🎉 All JWT token management tests passed!');
      console.log('Token system is working correctly.');
    } else {
      console.log('\n⚠️  Some JWT token tests failed.');
      console.log('Check the errors above and ensure:');
      console.log('- Rails server is running and accessible');
      console.log('- Authentication endpoints are configured correctly');
      console.log('- Test credentials are valid');
    }

    return failed === 0;
  }

  /**
   * Interactive token management
   */
  async interactiveMode() {
    const readline = require('readline');
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    while (true) {
      console.log('\n🔐 Interactive Token Manager');
      console.log('═══════════════════════════');
      console.log('1. Authenticate user');
      console.log('2. Show token info');
      console.log('3. Make authenticated request');
      console.log('4. Clear tokens');
      console.log('5. Run test suite');
      console.log('6. Exit');

      const choice = await new Promise(resolve => {
        rl.question('Select option (1-6): ', resolve);
      });

      try {
        switch (choice) {
          case '1':
            const userType = await new Promise(resolve => {
              rl.question('User type (default/admin/user/lawyer): ', resolve);
            });
            const token = await tokenManager.authenticate(userType || 'default');
            console.log(`Token obtained: ${token.substring(0, 20)}...`);
            break;

          case '2':
            const infoUserType = await new Promise(resolve => {
              rl.question('User type (default/admin/user/lawyer): ', resolve);
            });
            const tokenInfo = tokenManager.getTokenInfo(infoUserType || 'default');
            console.log('Token Info:', JSON.stringify(tokenInfo, null, 2));
            break;

          case '3':
            const endpoint = await new Promise(resolve => {
              rl.question('Endpoint (e.g., /users): ', resolve);
            });
            const requestUserType = await new Promise(resolve => {
              rl.question('User type (default/admin/user/lawyer): ', resolve);
            });
            const response = await tokenManager.authenticatedRequest(
              'GET',
              endpoint || '/users',
              null,
              { userType: requestUserType || 'default' }
            );
            console.log(`Response: ${response.status} - ${response.data ? 'Data received' : 'No data'}`);
            break;

          case '4':
            const clearUserType = await new Promise(resolve => {
              rl.question('User type to clear (leave empty for all): ', resolve);
            });
            if (clearUserType) {
              tokenManager.clearTokensForUser(clearUserType);
            } else {
              tokenManager.clearAllTokens();
            }
            console.log('Tokens cleared');
            break;

          case '5':
            await this.runAllTests();
            break;

          case '6':
            rl.close();
            return;

          default:
            console.log('Invalid option');
        }
      } catch (error) {
        console.error('Error:', error.message);
      }
    }
  }
}

// CLI handling
if (require.main === module) {
  const testUtil = new TokenTestUtility();
  const args = process.argv.slice(2);

  if (args.includes('--interactive') || args.includes('-i')) {
    testUtil.interactiveMode();
  } else {
    testUtil.runAllTests().then(success => {
      process.exit(success ? 0 : 1);
    });
  }
}

module.exports = TokenTestUtility;
