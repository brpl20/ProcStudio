#!/usr/bin/env node

/**
 * Authenticator Tool for Testing
 * 
 * This tool provides authentication functionality for testing the API
 * with predefined test users and stores the auth token for reuse.
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

// Configuration
const API_BASE_URL = 'http://localhost:3000';
const AUTH_ENDPOINT = '/api/v1/login';
const TOKEN_STORE_PATH = path.join(__dirname, '.auth-token.json');

// Test users
const TEST_USERS = {
  user1: {
    auth: {
      email: "u1@gmail.com",
      password: "123456"
    }
  },
  user2: {
    auth: {
      email: "u2@gmail.com",
      password: "123456"
    }
  }
};

/**
 * AuthTokenStore - Manages auth token persistence
 */
class AuthTokenStore {
  constructor(storePath = TOKEN_STORE_PATH) {
    this.storePath = storePath;
  }

  /**
   * Save token to file
   * @param {string} user - User identifier
   * @param {string} token - Auth token
   * @param {object} userData - Additional user data
   */
  save(user, token, userData = {}) {
    let store = this.load();
    store[user] = {
      token,
      userData,
      timestamp: new Date().toISOString()
    };
    fs.writeFileSync(this.storePath, JSON.stringify(store, null, 2));
    console.log(`✅ Token saved for ${user}`);
  }

  /**
   * Load tokens from file
   * @returns {object} Stored tokens
   */
  load() {
    if (fs.existsSync(this.storePath)) {
      const data = fs.readFileSync(this.storePath, 'utf8');
      return JSON.parse(data);
    }
    return {};
  }

  /**
   * Get token for specific user
   * @param {string} user - User identifier
   * @returns {object|null} Token data or null
   */
  get(user) {
    const store = this.load();
    return store[user] || null;
  }

  /**
   * Clear all tokens
   */
  clear() {
    if (fs.existsSync(this.storePath)) {
      fs.unlinkSync(this.storePath);
      console.log('🗑️  Token store cleared');
    }
  }

  /**
   * List all stored tokens
   */
  list() {
    const store = this.load();
    console.log('\n📋 Stored Tokens:');
    console.log('================');
    
    if (Object.keys(store).length === 0) {
      console.log('No tokens stored');
      return;
    }

    for (const [user, data] of Object.entries(store)) {
      console.log(`\n👤 ${user}:`);
      console.log(`   Token: ${data.token.substring(0, 20)}...`);
      console.log(`   Email: ${data.userData.email || 'N/A'}`);
      console.log(`   Saved: ${data.timestamp}`);
    }
  }
}

/**
 * Authenticator - Handles authentication requests
 */
class Authenticator {
  constructor() {
    this.tokenStore = new AuthTokenStore();
  }

  /**
   * Make HTTP request
   * @param {object} options - Request options
   * @param {object} data - Request data
   * @returns {Promise} Response promise
   */
  makeRequest(options, data = null) {
    return new Promise((resolve, reject) => {
      const protocol = options.protocol === 'https:' ? https : http;
      
      const req = protocol.request(options, (res) => {
        let responseData = '';

        res.on('data', (chunk) => {
          responseData += chunk;
        });

        res.on('end', () => {
          try {
            const parsed = JSON.parse(responseData);
            resolve({
              statusCode: res.statusCode,
              headers: res.headers,
              data: parsed
            });
          } catch (e) {
            resolve({
              statusCode: res.statusCode,
              headers: res.headers,
              data: responseData
            });
          }
        });
      });

      req.on('error', reject);

      if (data) {
        req.write(JSON.stringify(data));
      }

      req.end();
    });
  }

  /**
   * Authenticate user
   * @param {string} userKey - Key from TEST_USERS
   * @returns {Promise} Authentication result
   */
  async authenticate(userKey) {
    const user = TEST_USERS[userKey];
    
    if (!user) {
      throw new Error(`User ${userKey} not found. Available: ${Object.keys(TEST_USERS).join(', ')}`);
    }

    console.log(`\n🔐 Authenticating ${userKey} (${user.auth.email})...`);

    const url = new URL(API_BASE_URL + AUTH_ENDPOINT);
    
    const options = {
      hostname: url.hostname,
      port: url.port || (url.protocol === 'https:' ? 443 : 80),
      path: url.pathname + url.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      protocol: url.protocol
    };

    try {
      const response = await this.makeRequest(options, user);
      
      if (response.statusCode === 200 || response.statusCode === 201) {
        // Handle nested token structure
        const token = response.data?.data?.token || response.data?.token || response.headers['authorization'];
        
        if (token) {
          const userData = response.data?.data || response.data || {};
          
          this.tokenStore.save(userKey, token, {
            email: user.auth.email,
            ...userData
          });
          
          console.log(`✅ Authentication successful!`);
          console.log(`📝 Token: ${token.substring(0, 30)}...`);
          
          // Show additional user info if available
          if (userData.name) {
            console.log(`👤 User: ${userData.name} ${userData.last_name || ''}`);
            console.log(`📋 Role: ${userData.role || 'N/A'}`);
          }
          
          return {
            success: true,
            token,
            data: response.data
          };
        } else {
          console.error('❌ No token in response');
          console.error('Response structure:', JSON.stringify(response.data, null, 2));
          return {
            success: false,
            error: 'No token in response',
            response: response.data
          };
        }
      } else {
        console.error(`❌ Authentication failed: ${response.statusCode}`);
        console.error('Response:', response.data);
        
        return {
          success: false,
          statusCode: response.statusCode,
          error: response.data
        };
      }
    } catch (error) {
      console.error('❌ Request failed:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Test API with stored token
   * @param {string} userKey - User key
   * @param {string} endpoint - API endpoint to test
   * @returns {Promise} Test result
   */
  async testWithToken(userKey, endpoint = '/api/v1/user') {
    const tokenData = this.tokenStore.get(userKey);
    
    if (!tokenData) {
      console.error(`❌ No token found for ${userKey}. Please authenticate first.`);
      return null;
    }

    console.log(`\n🧪 Testing ${endpoint} with ${userKey}'s token...`);

    const url = new URL(API_BASE_URL + endpoint);
    
    const options = {
      hostname: url.hostname,
      port: url.port || (url.protocol === 'https:' ? 443 : 80),
      path: url.pathname + url.search,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': `Bearer ${tokenData.token}`
      },
      protocol: url.protocol
    };

    try {
      const response = await this.makeRequest(options);
      
      if (response.statusCode === 200) {
        console.log('✅ API test successful!');
        console.log('Response:', JSON.stringify(response.data, null, 2));
      } else {
        console.error(`❌ API test failed: ${response.statusCode}`);
        console.error('Response:', response.data);
      }
      
      return response;
    } catch (error) {
      console.error('❌ Request failed:', error.message);
      return null;
    }
  }

  /**
   * Authenticate all test users
   */
  async authenticateAll() {
    console.log('\n🔄 Authenticating all test users...\n');
    
    const results = {};
    
    for (const userKey of Object.keys(TEST_USERS)) {
      results[userKey] = await this.authenticate(userKey);
      console.log('---');
    }
    
    return results;
  }
}

/**
 * CLI Interface
 */
function printUsage() {
  console.log(`
📚 Authenticator Tool Usage:
============================

Commands:
  auth <user>      - Authenticate a specific user (user1 or user2)
  auth-all         - Authenticate all test users
  test <user>      - Test API with user's stored token
  list             - List all stored tokens
  clear            - Clear all stored tokens
  help             - Show this help message

Examples:
  node authenticator.js auth user1
  node authenticator.js auth-all
  node authenticator.js test user1
  node authenticator.js list
  node authenticator.js clear

Test Users:
  user1: u1@gmail.com / 123456
  user2: u2@gmail.com / 123456
`);
}

/**
 * Main CLI handler
 */
async function main() {
  const args = process.argv.slice(2);
  const command = args[0];
  const authenticator = new Authenticator();

  if (!command || command === 'help') {
    printUsage();
    return;
  }

  switch (command) {
    case 'auth':
      const userKey = args[1];
      if (!userKey) {
        console.error('❌ Please specify a user (user1 or user2)');
        printUsage();
        return;
      }
      await authenticator.authenticate(userKey);
      break;

    case 'auth-all':
      await authenticator.authenticateAll();
      break;

    case 'test':
      const testUser = args[1];
      const endpoint = args[2] || '/api/v1/user';
      if (!testUser) {
        console.error('❌ Please specify a user');
        return;
      }
      await authenticator.testWithToken(testUser, endpoint);
      break;

    case 'list':
      authenticator.tokenStore.list();
      break;

    case 'clear':
      authenticator.tokenStore.clear();
      break;

    default:
      console.error(`❌ Unknown command: ${command}`);
      printUsage();
  }
}

// Export for programmatic use
module.exports = {
  Authenticator,
  AuthTokenStore,
  TEST_USERS
};

// Run CLI if executed directly
if (require.main === module) {
  main().catch(console.error);
}